#!/usr/bin/env python3
"""
Convert external German vocabulary CSV/JSON files into a minified
`full_vocabulary.json` payload for LearnHappyGerman.

Output shape:
{"version":1,"words":[{"germanWord":"...","article":"...","englishTranslation":"...","level":"A1","category":"Noun"}]}

Notes:
- Uses only Python standard library.
- Supports raw CSV rows and JSON arrays / {"words":[...]} payloads.
- Header mapping can be overridden with --mapping-json.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

CEFR_LEVELS = {"A1", "A2", "B1", "B2", "C1", "C2"}
VALID_ARTICLES = {"der", "die", "das"}
NONE_ARTICLES = {"", "none", "-", "n/a", "na", "null"}

# Known aliases for external datasets.
FIELD_ALIASES: dict[str, tuple[str, ...]] = {
    "germanWord": (
        "germanword",
        "german_word",
        "german",
        "de",
        "lemma",
        "headword",
        "word",
        "term",
        "vocab",
        "vocabulary",
    ),
    "article": (
        "article",
        "artikel",
        "gender",
        "genus",
        "det",
        "determiner",
    ),
    "englishTranslation": (
        "englishtranslation",
        "english_translation",
        "english",
        "en",
        "translation",
        "meaning",
        "gloss",
        "definition",
    ),
    "level": (
        "level",
        "cefr",
        "cefrlevel",
        "cefr_level",
        "difficulty",
    ),
    "category": (
        "category",
        "pos",
        "partofspeech",
        "part_of_speech",
        "wordclass",
        "type",
        "class",
        "topic",
    ),
}


@dataclass
class Stats:
    loaded_rows: int = 0
    kept_rows: int = 0
    dropped_rows: int = 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build minified full_vocabulary.json from external CSV/JSON datasets."
    )
    parser.add_argument(
        "--input",
        action="append",
        required=True,
        help="Input file path(s). Repeat for multiple sources.",
    )
    parser.add_argument(
        "--output",
        default="full_vocabulary.json",
        help="Output JSON path (default: full_vocabulary.json).",
    )
    parser.add_argument(
        "--mapping-json",
        default="",
        help=(
            "Optional JSON string mapping app fields to source headers, e.g. "
            '\'{"germanWord":"lemma","englishTranslation":"en","level":"cefr","category":"pos","article":"artikel"}\''
        ),
    )
    parser.add_argument(
        "--default-category",
        default="Noun",
        help="Fallback category when not provided by source (default: Noun).",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Fail on rows missing required fields instead of skipping them.",
    )
    return parser.parse_args()


def load_rows(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        raise FileNotFoundError(f"Input file does not exist: {path}")

    suffix = path.suffix.lower()
    if suffix == ".csv":
        with path.open("r", encoding="utf-8-sig", newline="") as handle:
            return list(csv.DictReader(handle))

    if suffix == ".json":
        with path.open("r", encoding="utf-8") as handle:
            payload = json.load(handle)
        if isinstance(payload, list):
            return [row for row in payload if isinstance(row, dict)]
        if isinstance(payload, dict):
            words = payload.get("words")
            if isinstance(words, list):
                return [row for row in words if isinstance(row, dict)]
            # accept {"data":[...]} style
            data = payload.get("data")
            if isinstance(data, list):
                return [row for row in data if isinstance(row, dict)]
        raise ValueError(f"Unsupported JSON structure in {path}")

    raise ValueError(f"Unsupported input type {suffix} for {path}")


def normalize_header(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "", name.strip().lower())


def infer_mapping(rows: list[dict[str, Any]]) -> dict[str, str]:
    if not rows:
        return {}
    keys = list(rows[0].keys())
    normalized = {normalize_header(k): k for k in keys}
    resolved: dict[str, str] = {}
    for target_field, aliases in FIELD_ALIASES.items():
        for alias in aliases:
            if alias in normalized:
                resolved[target_field] = normalized[alias]
                break
    return resolved


def merge_mapping(inferred: dict[str, str], override_json: str) -> dict[str, str]:
    merged = dict(inferred)
    if override_json:
        override = json.loads(override_json)
        if not isinstance(override, dict):
            raise ValueError("--mapping-json must decode to an object.")
        for key, value in override.items():
            if key not in FIELD_ALIASES:
                raise ValueError(f"Unknown mapping field: {key}")
            if not isinstance(value, str):
                raise ValueError(f"Mapping for {key} must be a string.")
            merged[key] = value
    return merged


def norm_text(value: Any) -> str:
    if value is None:
        return ""
    return str(value).strip()


def normalize_level(raw: str) -> str:
    token = norm_text(raw).upper().replace(" ", "")
    if token in CEFR_LEVELS:
        return token
    # Accept e.g. "A1.1", "B2+" -> A1 / B2
    match = re.match(r"^(A1|A2|B1|B2|C1|C2)", token)
    return match.group(1) if match else ""


def normalize_article(raw: str) -> str | None:
    t = norm_text(raw).lower()
    if t in NONE_ARTICLES:
        return None
    if t in VALID_ARTICLES:
        return t
    return None


def infer_category(raw_category: str, german_word: str, article: str | None, default_category: str) -> str:
    c = norm_text(raw_category)
    if c:
        return c
    if article in VALID_ARTICLES:
        return "Noun"
    if german_word.lower().startswith("zu "):
        return "Verb"
    return default_category


def row_to_record(
    row: dict[str, Any],
    mapping: dict[str, str],
    default_category: str,
) -> dict[str, str] | None:
    german_word = norm_text(row.get(mapping.get("germanWord", ""), ""))
    english = norm_text(row.get(mapping.get("englishTranslation", ""), ""))
    level = normalize_level(norm_text(row.get(mapping.get("level", ""), "")))
    raw_category = norm_text(row.get(mapping.get("category", ""), ""))
    raw_article = norm_text(row.get(mapping.get("article", ""), ""))
    article = normalize_article(raw_article)

    if not german_word or not english or not level:
        return None

    category = infer_category(raw_category, german_word, article, default_category)
    return {
        "germanWord": german_word,
        "article": article if article is not None else "none",
        "englishTranslation": english,
        "level": level,
        "category": category,
    }


def dedupe(records: list[dict[str, str]]) -> list[dict[str, str]]:
    seen: set[tuple[str, str]] = set()
    out: list[dict[str, str]] = []
    for r in records:
        key = (r["germanWord"].casefold(), r["level"])
        if key in seen:
            continue
        seen.add(key)
        out.append(r)
    return out


def main() -> int:
    args = parse_args()
    stats = Stats()
    processed: list[dict[str, str]] = []

    for raw_path in args.input:
        path = Path(raw_path)
        rows = load_rows(path)
        stats.loaded_rows += len(rows)
        inferred = infer_mapping(rows)
        mapping = merge_mapping(inferred, args.mapping_json)

        required = {"germanWord", "englishTranslation", "level"}
        missing = [field for field in required if field not in mapping]
        if missing:
            raise ValueError(
                f"{path}: could not infer required mapping {missing}. "
                "Use --mapping-json to provide explicit source columns."
            )

        for row in rows:
            rec = row_to_record(row, mapping, args.default_category)
            if rec is None:
                stats.dropped_rows += 1
                if args.strict:
                    raise ValueError(f"Invalid row in {path}: {row}")
                continue
            processed.append(rec)
            stats.kept_rows += 1

    output_records = dedupe(processed)
    payload = {"version": 1, "words": output_records}

    out_path = Path(args.output)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(
        json.dumps(payload, ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )

    level_counts: dict[str, int] = {level: 0 for level in sorted(CEFR_LEVELS)}
    for r in output_records:
        level_counts[r["level"]] += 1

    print(f"Processed rows: loaded={stats.loaded_rows} kept={stats.kept_rows} dropped={stats.dropped_rows}")
    print(f"Output records (deduped): {len(output_records)} -> {out_path}")
    print("Level distribution:", ", ".join(f"{k}:{v}" for k, v in level_counts.items()))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:  # pylint: disable=broad-except
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
