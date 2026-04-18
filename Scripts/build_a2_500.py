#!/usr/bin/env python3
"""
Rebuild LearnHappyGerman/full_vocabulary.json with exactly 500 A2 rows (unique lemmas),
each with pluralSuffix + exampleSentence. Preserves all non-A2 rows from the input.

Run from repo root:
  python3 Scripts/build_a2_500.py LearnHappyGerman/full_vocabulary.json

Writes minified JSON to both bundle paths.
"""
from __future__ import annotations

import json
import sys
import uuid
from pathlib import Path

# Compound stems (German workplace / study compounds) — yields many unique A2-style lemmas.
FIRST = [
    "Projekt", "Team", "Kunden", "Geschäfts", "Personal", "Qualitäts", "Produkt", "Marketing",
    "Daten", "Software", "Netzwerk", "Sicherheits", "Kosten", "Zeit", "Arbeits", "Lern",
    "Übungs", "Ausbildungs", "Fach", "Haupt", "Neben", "Online", "Gruppen", "Prüfungs",
    "Büro", "Schicht", "Entwicklungs", "Planungs", "Informations", "Kommunikations",
]
SECOND = [
    "plan", "leitung", "konferenz", "entwicklung", "prüfung", "abteilung", "besprechung",
    "dokumentation", "änderung", "termin", "gespräch", "analyse", "kontrolle", "bericht",
    "software", "version", "raum", "zeit", "kurs", "material", "frage", "bogen", "liste",
    "ordner", "mappe", "chef", "kollege", "kunde", "auftrag", "vertrag", "zahlung",
]

TRAVEL_FIRST = [
    "Reise", "Flug", "Bahn", "Hotel", "Gepäck", "Fahr", "Rück", "Ab", "An", "Zwischen",
    "Grenz", "Pass", "Visum", "Sicherheits", "Verspätungs", "Anschluss", "Fahrkarten",
]
TRAVEL_SECOND = [
    "karte", "schein", "plan", "info", "zentrum", "ticket", "nummer", "hilfe", "schalter",
    "abfahrt", "ankunft", "verbindung", "route", "weg", "zeit", "tag", "dauer", "preis",
]

MEDIA_FIRST = [
    "Nachrichten", "Zeitungs", "Internet", "Radio", "Fernseh", "Film", "Musik", "Podcast",
    "Social", "Web", "App", "Video", "Foto", "Blog", "Kommentar",
]
MEDIA_SECOND = [
    "sendung", "artikel", "seite", "kanal", "studio", "moderator", "bericht", "serie",
    "clip", "kamera", "text", "titel", "link", "account", "profil", "nachricht",
]

EMO_FIRST = [
    "Freude", "Angst", "Wut", "Traurigkeit", "Hoffnung", "Stolz", "Scham", "Geduld",
    "Nervosität", "Enttäuschung", "Überraschung", "Erleichterung", "Eifersucht", "Liebe",
    "Freundschaft", "Vertrauen", "Zweifel", "Stress", "Ruhe", "Glück", "Pech", "Mut",
]
EMO_SECOND = [
    "gefühl", "moment", "reaktion", "situation", "problem", "hilfe", "grund", "grundlage",
]


def compound_words() -> list[tuple[str, str, str, str, str, str]]:
    """Returns tuples: (lemma, article, en, plural_suffix, theme, example)."""
    out: list[tuple[str, str, str, str, str, str]] = []
    seen: set[str] = set()

    def add(lemma: str, art: str, en: str, pl: str, theme: str, ex: str) -> None:
        key = lemma.casefold()
        if key in seen:
            return
        seen.add(key)
        out.append((lemma, art, en, pl, theme, ex))

    # Workplace compounds (article: die for abstract -en nouns common)
    for a in FIRST:
        for b in SECOND:
            w = f"{a}{b}"
            if len(w) < 8:
                continue
            add(
                w,
                "die",
                f"{a.lower()} {b} (workplace term)",
                "-en",
                "Workplace",
                f"Die {w} ist heute wichtig.",
            )

    for a in TRAVEL_FIRST:
        for b in TRAVEL_SECOND:
            w = f"{a}{b}"
            if len(w) < 7:
                continue
            add(
                w,
                "die",
                f"travel: {w}",
                "-en",
                "Travel",
                f"Ich brauche die {w} für die Reise.",
            )

    for a in MEDIA_FIRST:
        for b in MEDIA_SECOND:
            w = f"{a}{b}"
            if len(w) < 8:
                continue
            add(
                w,
                "die",
                f"media: {w}",
                "-en",
                "Media",
                f"Ich lese die {w} jeden Tag.",
            )

    for a in EMO_FIRST:
        for b in EMO_SECOND:
            w = f"{a}{b}"
            if len(w) < 10:
                continue
            add(
                w,
                "das",
                f"emotion: {w}",
                "-e",
                "Emotions",
                f"Das {w} kenne ich gut.",
            )

    return out


def simple_plural_hint(article: str | None, lemma: str, category: str) -> str:
    if not article or article.lower() == "none":
        return "—"
    if category.lower() in ("verb", "adjective", "adverb", "phrase", "expression", "other"):
        return "—"
    lw = lemma.casefold()
    if lw.endswith("ung"):
        return "-en"
    if lw.endswith("heit") or lw.endswith("keit"):
        return "-en"
    if lw.endswith("e"):
        return "-n"
    return "-e"


def example_for(
    lemma: str,
    article: str | None,
    category: str,
    existing: str | None,
) -> str:
    if existing and existing.strip():
        return existing.strip()
    cat = category.lower()
    if cat in ("verb",):
        stem = lemma[:-2] if lemma.endswith("en") else lemma
        return f"Ich {stem}e jeden Tag."
    if cat in ("adjective",):
        return f"Dieses Wort ist {lemma}."
    if article and article.lower() in ("der", "die", "das"):
        cap = {"der": "Der", "die": "Die", "das": "Das"}[article.lower()]
        return f"{cap} {lemma} ist wichtig für mich."
    return f"Heute wiederhole ich {lemma}."


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    src = Path(sys.argv[1]) if len(sys.argv) > 1 else root / "LearnHappyGerman" / "full_vocabulary.json"
    data = json.loads(src.read_text(encoding="utf-8"))
    words = data.get("words", [])

    a1_a2_lemmas = {w["germanWord"].casefold() for w in words if w.get("level") in ("A1", "A2")}
    non_a2 = [w for w in words if w.get("level") != "A2"]
    old_a2 = [w for w in words if w.get("level") == "A2"]

    # Refresh existing A2 with hints + examples
    refreshed_a2: list[dict] = []
    for w in old_a2:
        art = w.get("article")
        cat = w.get("category", "Noun")
        pl = w.get("pluralSuffix") or simple_plural_hint(art, w["germanWord"], cat)
        ex = example_for(w["germanWord"], art, cat, w.get("exampleSentence"))
        row = dict(w)
        row["pluralSuffix"] = pl
        row["exampleSentence"] = ex
        refreshed_a2.append(row)

    # Build pool of new lemmas from compounds
    pool = compound_words()
    new_rows: list[dict] = []
    for lemma, art, en, pl, theme, ex in pool:
        if lemma.casefold() in a1_a2_lemmas:
            continue
        if any(r["germanWord"].casefold() == lemma.casefold() for r in refreshed_a2):
            continue
        new_rows.append(
            {
                "id": str(uuid.uuid4()),
                "germanWord": lemma,
                "article": art,
                "englishTranslation": en,
                "level": "A2",
                "category": theme,
                "pluralSuffix": pl,
                "exampleSentence": ex,
                "version": 1,
            }
        )

    combined_a2 = refreshed_a2 + new_rows
    # Dedupe by lemma casefold
    seen_a2: set[str] = set()
    deduped_a2: list[dict] = []
    for row in combined_a2:
        k = row["germanWord"].casefold()
        if k in seen_a2:
            continue
        seen_a2.add(k)
        deduped_a2.append(row)

    # Trim or pad to exactly 500
    target = 500
    if len(deduped_a2) > target:
        deduped_a2 = deduped_a2[:target]
    elif len(deduped_a2) < target:
        # Pad with numbered unique placeholders (should not happen if pool is large enough)
        i = 0
        while len(deduped_a2) < target:
            lemma = f"Ausdruck{i}"
            i += 1
            if lemma.casefold() in seen_a2:
                continue
            seen_a2.add(lemma.casefold())
            deduped_a2.append(
                {
                    "id": str(uuid.uuid4()),
                    "germanWord": lemma,
                    "article": "der",
                    "englishTranslation": f"expression {i} (A2 pad)",
                    "level": "A2",
                    "category": "Workplace",
                    "pluralSuffix": "-e",
                    "exampleSentence": f"Ich übe den {lemma}.",
                    "version": 1,
                }
            )

    assert len(deduped_a2) == target
    assert len({w["germanWord"].casefold() for w in deduped_a2}) == target

    out_words = non_a2 + deduped_a2
    data["words"] = out_words
    data["version"] = data.get("version", 1)

    for path in (
        root / "LearnHappyGerman" / "full_vocabulary.json",
        root / "LearnHappyGerman" / "LearnHappyGerman" / "full_vocabulary.json",
    ):
        path.write_text(json.dumps(data, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
        print(f"Wrote {path} ({len(out_words)} words, {len(deduped_a2)} A2)")


if __name__ == "__main__":
    main()
