#!/usr/bin/env python3
"""
Post-process `Data/german_vocabulary.json` (Goethe extractor output):

1. **Structural cleanup** (PDF noise):
   - German nouns: ensure lemma starts with an uppercase letter without lowercasing the rest
     (avoids `str.capitalize()` mangling ß/umlaut tails).
   - `plural` sometimes contains a suffix plus a leaked example sentence; split suffix → `plural`,
     move sentence into `examples` if not already present.
   - `article` / `plural` that are blank after strip → JSON null.

2. **CJK removal**: strip Chinese/Japanese/Korean script ranges from all string fields (and each
   `examples[]` line). This does **not** call a translator—if a gloss was Chinese-only, the field may
   become empty; re-run `extract_vocab.py --translate-only` to refill `englishTranslation` from German.

Run from repo root:

  python3 Data/scripts/cleanup_german_vocabulary.py
  python3 Data/scripts/cleanup_german_vocabulary.py --in-place
  python3 Data/scripts/cleanup_german_vocabulary.py -i Data/german_vocabulary.json -o Data/german_vocabulary_cleaned.json
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

SCRIPT_PATH = Path(__file__).resolve()
REPO_ROOT = SCRIPT_PATH.parents[2]
DEFAULT_JSON = REPO_ROOT / "Data" / "german_vocabulary.json"

# Plural field: suffix (e.g. -en, ¨-e, -n) then whitespace then leaked example text.
PLURAL_LEAK_PATTERN = re.compile(r"^([\w¨·\-]+)\s+(.*)", re.UNICODE)

# Han/Hiragana/Katakana and related fullwidth punctuation — remove from corpus strings.
_CJK_RE = re.compile(
    "["
    "\u3000-\u303f"  # CJK symbols and punctuation
    "\u3040-\u30ff"  # Hiragana, Katakana
    "\u3400-\u4dbf"  # CJK Extension A
    "\u4e00-\u9fff"  # CJK Unified
    "\uf900-\ufaff"  # Compatibility ideographs
    "\uff00-\uffef"  # Fullwidth forms
    "]"
)


def capitalize_german_lemma(word: str) -> str:
    if not word:
        return word
    return word[0].upper() + word[1:]


def strip_cjk(text: str) -> str:
    if not text:
        return text
    cleaned = _CJK_RE.sub("", text)
    cleaned = re.sub(r"[ \t]+", " ", cleaned)
    return cleaned.strip()


def clean_string_value(key: str, value: str | None) -> str | None:
    if value is None:
        return None
    s = strip_cjk(value)
    if not s:
        return None
    return s


def ensure_examples_list(entry: dict[str, Any]) -> list[str]:
    ex = entry.get("examples")
    if ex is None:
        return []
    if not isinstance(ex, list):
        return []
    return [e for e in ex if isinstance(e, str)]


def structural_plural_and_examples(entry: dict[str, Any]) -> None:
    plural_val = entry.get("plural")
    if not plural_val or not isinstance(plural_val, str):
        return
    match = PLURAL_LEAK_PATTERN.match(plural_val.strip())
    if not match:
        return
    suffix, leaked = match.group(1), match.group(2).strip()
    entry["plural"] = suffix
    if not leaked:
        return
    examples = ensure_examples_list(entry)
    if leaked not in examples:
        examples.append(leaked)
    entry["examples"] = examples


def normalize_empty_optional_strings(entry: dict[str, Any], keys: tuple[str, ...]) -> None:
    for key in keys:
        val = entry.get(key)
        if val is None:
            continue
        if isinstance(val, str) and not val.strip():
            entry[key] = None


def clean_entry_strings(entry: dict[str, Any]) -> None:
    """Apply CJK strip to all string fields; normalize examples list."""
    string_keys = (
        "word",
        "type",
        "article",
        "plural",
        "level",
        "englishTranslation",
        "conjugation",
        "auxiliary",
        "perfect",
        "source_file",
    )
    for key in string_keys:
        if key not in entry:
            continue
        val = entry[key]
        if val is None:
            continue
        if isinstance(val, str):
            entry[key] = clean_string_value(key, val)

    ex = entry.get("examples")
    if isinstance(ex, list):
        cleaned_lines: list[str] = []
        seen: set[str] = set()
        for line in ex:
            if not isinstance(line, str):
                continue
            s = clean_string_value("examples", line)
            if not s or s in seen:
                continue
            seen.add(s)
            cleaned_lines.append(s)
        entry["examples"] = cleaned_lines


def cleanup_record(entry: dict[str, Any], *, structural: bool, strip_cjk_chars: bool) -> None:
    if structural:
        if entry.get("type") == "noun" and entry.get("word"):
            w = entry["word"]
            if isinstance(w, str) and w:
                entry["word"] = capitalize_german_lemma(w)
        structural_plural_and_examples(entry)
        normalize_empty_optional_strings(entry, ("article", "plural"))

    if strip_cjk_chars:
        clean_entry_strings(entry)
        normalize_empty_optional_strings(entry, ("article", "plural"))


def load_records(path: Path) -> list[dict[str, Any]]:
    with path.open(encoding="utf-8") as f:
        data = json.load(f)
    if not isinstance(data, list):
        raise ValueError(f"Expected a JSON array in {path}")
    out: list[dict[str, Any]] = []
    for item in data:
        if isinstance(item, dict):
            out.append(item)
    return out


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Clean structural noise and CJK characters in german_vocabulary.json.")
    p.add_argument(
        "-i",
        "--input",
        type=Path,
        default=DEFAULT_JSON,
        help=f"Input JSON (default: {DEFAULT_JSON.relative_to(REPO_ROOT)})",
    )
    p.add_argument(
        "-o",
        "--output",
        type=Path,
        default=None,
        help="Output JSON (default: stdout path hint only; use --in-place or pass -o).",
    )
    p.add_argument(
        "--in-place",
        action="store_true",
        help="Overwrite the input file.",
    )
    p.add_argument(
        "--no-structural",
        action="store_true",
        help="Skip plural leak / noun-case fixes.",
    )
    p.add_argument(
        "--no-cjk",
        action="store_true",
        help="Do not strip CJK characters.",
    )
    return p.parse_args()


def main() -> None:
    args = parse_args()
    in_path = args.input if args.input.is_absolute() else (REPO_ROOT / args.input)

    if not in_path.is_file():
        print(f"Input not found: {in_path}", file=sys.stderr)
        sys.exit(1)

    records = load_records(in_path)
    structural = not args.no_structural
    strip_cjk_chars = not args.no_cjk

    for entry in records:
        cleanup_record(entry, structural=structural, strip_cjk_chars=strip_cjk_chars)

    if args.in_place:
        out_path = in_path
    elif args.output:
        out_path = args.output if args.output.is_absolute() else (REPO_ROOT / args.output)
    else:
        out_path = in_path.with_name(in_path.stem + "_cleaned.json")

    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", encoding="utf-8") as f:
        json.dump(records, f, ensure_ascii=False, indent=4)

    try:
        display = out_path.relative_to(REPO_ROOT)
    except ValueError:
        display = out_path
    print(f"Wrote {len(records)} records → {display}")


if __name__ == "__main__":
    main()
