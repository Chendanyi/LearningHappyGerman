"""
Extract Goethe A1/A2 vocabulary PDFs and optionally fill `englishTranslation` via googletrans.

Run from the **repository root** (LearningHappyGerman):

  python3 -m pip install -r Data/scripts/requirements-pdf-extract.txt
  python3 Data/scripts/extract_vocab.py              # PDF → JSON (englishTranslation null)
  python3 Data/scripts/extract_vocab.py --translate  # PDF → JSON, then translate gaps (needs network)
  python3 Data/scripts/extract_vocab.py --translate-only   # update existing JSON only

Re-extracting PDFs preserves non-empty englishTranslation values already in the output file
before overwriting, then --translate only requests translations for still-missing rows.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import time
from pathlib import Path

import pypdf

SCRIPT_PATH = Path(__file__).resolve()
REPO_ROOT = SCRIPT_PATH.parents[2]
DATA_DIR = REPO_ROOT / "Data"
DEFAULT_JSON = DATA_DIR / "german_vocabulary.json"
# Licensed PDFs live outside this repo clone (sibling `reference/vocabulary/` under `04_LearningGerman/`).
VOCAB_REF_DIR = REPO_ROOT.parent / "reference" / "vocabulary"


class GermanVocabProcessor:
    """
    Processor for adult-level Goethe-Zertifikat A1 and A2 wordlists.
    Optimized for multi-line verb conjugations and strict level hierarchy.
    """

    def __init__(self):
        self.data: dict[str, dict] = {}
        self.re_noun = re.compile(r"^(der|die|das)\s+([A-ZÄÖÜ][\w-]+)(?:,\s+([\w\s¨-]+))?")
        self.re_other = re.compile(r"^([a-zäöü][\w-]+)(?:,)?")
        self.re_verb_aux = re.compile(r"^(ist|hat)\s+([\w\s]+)")

    def extract_from_pdf(self, pdf_path: Path, level: str) -> None:
        if not pdf_path.is_file():
            print(f"File skipped: {pdf_path} (not found)")
            return

        print(f"Extracting level {level} from: {pdf_path}")
        reader = pypdf.PdfReader(str(pdf_path))
        current_word: str | None = None

        for page in reader.pages:
            text = page.extract_text()
            if not text:
                continue

            for line in text.split("\n"):
                line = line.strip()
                if not line or any(x in line for x in ["Seite", "WORTLISTE", "INVENTARE", "VS_"]):
                    continue

                m_noun = self.re_noun.match(line)
                if m_noun:
                    word = m_noun.group(2)
                    self._upsert_entry(
                        word=word,
                        level=level,
                        pos="noun",
                        article=m_noun.group(1),
                        plural=m_noun.group(3).strip() if m_noun.group(3) else None,
                    )
                    current_word = word
                    continue

                m_other = self.re_other.match(line)
                if m_other and not any(line.startswith(art + " ") for art in ["der", "die", "das"]):
                    word = m_other.group(1)
                    self._upsert_entry(word=word, level=level, pos="other")
                    current_word = word
                    continue

                m_aux = self.re_verb_aux.match(line)
                if m_aux and current_word:
                    self.data[current_word]["auxiliary"] = m_aux.group(1)
                    self.data[current_word]["perfect"] = m_aux.group(2)
                    continue

                if current_word and len(line) > 5:
                    if line not in self.data[current_word]["examples"]:
                        self.data[current_word]["examples"].append(line)

    def _upsert_entry(self, word: str, level: str, pos: str, article=None, plural=None) -> None:
        if word in self.data:
            if level == "A1":
                self.data[word]["level"] = "A1"
            if article:
                self.data[word]["article"] = article
            if plural:
                self.data[word]["plural"] = plural
        else:
            self.data[word] = {
                "word": word,
                "type": pos,
                "article": article,
                "plural": plural,
                "level": level,
                "examples": [],
                "englishTranslation": None,
            }

    def build_records(self) -> list[dict]:
        return sorted(self.data.values(), key=lambda x: (x["level"], x["word"]))


def load_translation_map(path: Path) -> dict[tuple[str, str], str]:
    """Map (word, level) -> english gloss for preservation across PDF re-runs."""
    if not path.is_file():
        return {}
    try:
        with open(path, encoding="utf-8") as f:
            rows = json.load(f)
    except (json.JSONDecodeError, OSError) as e:
        print(f"Warning: could not load existing JSON for preservation: {e}", file=sys.stderr)
        return {}
    out: dict[tuple[str, str], str] = {}
    for row in rows:
        w = row.get("word")
        lvl = row.get("level")
        en = row.get("englishTranslation")
        if w is None or lvl is None or en is None:
            continue
        s = str(en).strip()
        if s:
            out[(str(w), str(lvl))] = s
    return out


def apply_preservation(records: list[dict], preserved: dict[tuple[str, str], str]) -> None:
    for row in records:
        key = (row["word"], row["level"])
        if key in preserved:
            row["englishTranslation"] = preserved[key]


def german_phrase_for_translation(row: dict) -> str:
    """Short German cue for machine translation (article + lemma for nouns)."""
    w = str(row.get("word", "")).strip()
    t = str(row.get("type", "")).strip().lower()
    if t == "noun":
        art = row.get("article")
        if art and str(art).strip():
            return f"{str(art).strip()} {w}"
    return w


def translate_records(
    records: list[dict],
    *,
    dest: str = "en",
    sleep_s: float = 0.35,
    max_rows: int | None = None,
    retries: int = 4,
) -> int:
    """Fill missing `englishTranslation` using googletrans. Returns count translated."""
    try:
        from googletrans import Translator
    except ImportError:
        print(
            "googletrans is not installed. Run: python3 -m pip install -r Data/scripts/requirements-pdf-extract.txt",
            file=sys.stderr,
        )
        sys.exit(1)

    translator = Translator()
    done = 0
    for row in records:
        if max_rows is not None and done >= max_rows:
            break
        en = row.get("englishTranslation")
        if en is not None and str(en).strip():
            continue
        phrase = german_phrase_for_translation(row)
        if not phrase:
            continue

        attempt = 0
        while attempt < retries:
            try:
                result = translator.translate(phrase, src="de", dest=dest)
                text = (result.text or "").strip()
                if text:
                    row["englishTranslation"] = text
                    done += 1
                    if done % 50 == 0:
                        print(f"  translated {done} rows…")
                break
            except Exception as e:
                attempt += 1
                wait = min(2.0 * attempt, 30.0)
                print(f"  translate retry {attempt}/{retries} for {phrase!r}: {e}", file=sys.stderr)
                time.sleep(wait)
        time.sleep(sleep_s)

    return done


def export_json(records: list[dict], output_file: Path) -> int:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(records, f, ensure_ascii=False, indent=4)
    return len(records)


def run_extract(pdf_tasks: list[tuple[Path, str]]) -> list[dict]:
    processor = GermanVocabProcessor()
    for pdf, lvl in pdf_tasks:
        processor.extract_from_pdf(pdf, lvl)
    return processor.build_records()


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Goethe PDF vocabulary extract + optional EN gloss via googletrans.")
    p.add_argument(
        "--translate",
        action="store_true",
        help="After export, fill empty englishTranslation via googletrans (network).",
    )
    p.add_argument(
        "--translate-only",
        action="store_true",
        help="Skip PDFs; load JSON, translate missing rows, save.",
    )
    p.add_argument(
        "--output",
        type=Path,
        default=None,
        help=f"JSON path (default: {DEFAULT_JSON})",
    )
    p.add_argument(
        "--sleep",
        type=float,
        default=0.35,
        help="Seconds between translate calls (default: 0.35).",
    )
    p.add_argument(
        "--max-rows",
        type=int,
        default=None,
        help="Translate at most this many rows (for testing).",
    )
    p.add_argument(
        "--no-preserve",
        action="store_true",
        help="Do not carry over existing englishTranslation when re-extracting PDFs.",
    )
    return p.parse_args()


def main() -> None:
    args = parse_args()
    out_path = Path(args.output) if args.output else DEFAULT_JSON

    if args.translate_only:
        if not out_path.is_file():
            print(f"No file to translate: {out_path}", file=sys.stderr)
            sys.exit(1)
        with open(out_path, encoding="utf-8") as f:
            records = json.load(f)
        n = translate_records(
            records, sleep_s=args.sleep, max_rows=args.max_rows
        )
        export_json(records, out_path)
        print(f"--- Translate-only complete ---\nUpdated {n} rows in {out_path}")
        return

    tasks = [
        (VOCAB_REF_DIR / "Goethe-Zertifikat_A1_Wortliste.pdf", "A1"),
        (VOCAB_REF_DIR / "Goethe-Zertifikat_A2_Wortliste.pdf", "A2"),
    ]

    preserved: dict[tuple[str, str], str] = {}
    if not args.no_preserve:
        preserved = load_translation_map(out_path)

    records = run_extract(tasks)
    apply_preservation(records, preserved)

    export_json(records, out_path)
    print(f"Extracted {len(records)} entries → {out_path}")

    if args.translate:
        n = translate_records(
            records, sleep_s=args.sleep, max_rows=args.max_rows
        )
        export_json(records, out_path)
        print(f"Translated {n} new/missing rows → {out_path}")


if __name__ == "__main__":
    main()
