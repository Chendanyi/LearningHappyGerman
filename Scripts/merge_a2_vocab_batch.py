#!/usr/bin/env python3
"""One-off merge: append A2 vocabulary to full_vocabulary.json (both bundle paths)."""
from __future__ import annotations

import json
import uuid
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]

# (germanWord, article or "none", englishTranslation, category)
# Nouns: capitalized, category Noun. Verbs/Adjectives: lowercase lemma, category Verb/Adjective.
# Verbs: english includes infinitive gloss + Partizip II.
RAW_A2: list[tuple[str, str, str, str]] = [
    # Nouns (45)
    ("Abitur", "das", "school-leaving certificate", "Noun"),
    ("Abteilungsleitung", "die", "department management", "Noun"),
    ("Abschied", "der", "farewell", "Noun"),
    ("Absatz", "der", "paragraph / heel", "Noun"),
    ("Abstimmung", "die", "vote", "Noun"),
    ("Abteil", "das", "compartment", "Noun"),
    ("Abwesenheit", "die", "absence", "Noun"),
    ("Adventskalender", "der", "Advent calendar", "Noun"),
    ("Agentur", "die", "agency", "Noun"),
    ("Akademie", "die", "academy", "Noun"),
    ("Alarm", "der", "alarm", "Noun"),
    ("Alkohol", "der", "alcohol", "Noun"),
    ("Alternative", "die", "alternative", "Noun"),
    ("Amt", "das", "office / authority", "Noun"),
    ("Analyse", "die", "analysis", "Noun"),
    ("Anfrage", "die", "inquiry", "Noun"),
    ("Anhänger", "der", "trailer / supporter", "Noun"),
    ("Anleitung", "die", "instructions", "Noun"),
    ("Anmeldung", "die", "registration", "Noun"),
    ("Anpassung", "die", "adaptation", "Noun"),
    ("Anschrift", "die", "address", "Noun"),
    ("Anspannung", "die", "tension", "Noun"),
    ("Anstrengung", "die", "effort", "Noun"),
    ("Antrag", "der", "application", "Noun"),
    ("Anwalt", "der", "lawyer", "Noun"),
    ("Anzeige", "die", "advertisement / display", "Noun"),
    ("Apotheke", "die", "pharmacy", "Noun"),
    ("Appetithappen", "der", "appetizer", "Noun"),
    ("Arbeitsamt", "das", "job center", "Noun"),
    ("Arbeitsbedingung", "die", "working condition", "Noun"),
    ("Arbeitsplatzwechsel", "der", "job change", "Noun"),
    ("Architekt", "der", "architect", "Noun"),
    ("Armatur", "die", "fitting / tap", "Noun"),
    ("Artikel", "der", "article", "Noun"),
    ("Aspirin", "das", "aspirin", "Noun"),
    ("Assistent", "der", "assistant", "Noun"),
    ("Atmosphäre", "die", "atmosphere", "Noun"),
    ("Aufenthalt", "der", "stay", "Noun"),
    ("Aufgabenbereich", "der", "area of responsibility", "Noun"),
    ("Auftrag", "der", "order / commission", "Noun"),
    ("Ausbildung", "die", "training / apprenticeship", "Noun"),
    ("Ausdruck", "der", "expression / printout", "Noun"),
    ("Ausnahme", "die", "exception", "Noun"),
    ("Ausstellung", "die", "exhibition", "Noun"),
    ("Auswahl", "die", "selection", "Noun"),
    ("Autor", "der", "author", "Noun"),
    # Verbs (45) — Partizip II in englishTranslation
    ("abbrechen", "none", "to cancel; Partizip II: abgebrochen", "Verb"),
    ("abgeben", "none", "to hand in; Partizip II: abgegeben", "Verb"),
    ("abhängen", "none", "to depend; Partizip II: abgehangen", "Verb"),
    ("abholen", "none", "to pick up; Partizip II: abgeholt", "Verb"),
    ("ablehnen", "none", "to reject; Partizip II: abgelehnt", "Verb"),
    ("absagen", "none", "to cancel; Partizip II: abgesagt", "Verb"),
    ("abschließen", "none", "to lock / finish; Partizip II: abgeschlossen", "Verb"),
    ("abwarten", "none", "to wait for; Partizip II: abgewartet", "Verb"),
    ("achtgeben", "none", "to pay attention; Partizip II: achtgegeben", "Verb"),
    ("anbieten", "none", "to offer; Partizip II: angeboten", "Verb"),
    ("anfangen", "none", "to begin; Partizip II: angefangen", "Verb"),
    ("ankommen", "none", "to arrive; Partizip II: angekommen", "Verb"),
    ("anmachen", "none", "to turn on; Partizip II: angemacht", "Verb"),
    ("anmelden", "none", "to register; Partizip II: angemeldet", "Verb"),
    ("annehmen", "none", "to accept; Partizip II: angenommen", "Verb"),
    ("anrufen", "none", "to call; Partizip II: angerufen", "Verb"),
    ("antworten", "none", "to answer; Partizip II: geantwortet", "Verb"),
    ("anzeigen", "none", "to report / display; Partizip II: angezeigt", "Verb"),
    ("arbeiten", "none", "to work; Partizip II: gearbeitet", "Verb"),
    ("aufräumen", "none", "to tidy up; Partizip II: aufgeräumt", "Verb"),
    ("aufstehen", "none", "to get up; Partizip II: aufgestanden", "Verb"),
    ("ausfüllen", "none", "to fill out; Partizip II: ausgefüllt", "Verb"),
    ("ausgehen", "none", "to go out; Partizip II: ausgegangen", "Verb"),
    ("ausprobieren", "none", "to try out; Partizip II: ausprobiert", "Verb"),
    ("auswählen", "none", "to select; Partizip II: ausgewählt", "Verb"),
    ("bedeuten", "none", "to mean; Partizip II: bedeutet", "Verb"),
    ("beginnen", "none", "to begin; Partizip II: begonnen", "Verb"),
    ("bekommen", "none", "to receive; Partizip II: bekommen", "Verb"),
    ("benutzen", "none", "to use; Partizip II: benutzt", "Verb"),
    ("beschreiben", "none", "to describe; Partizip II: beschrieben", "Verb"),
    ("besichtigen", "none", "to visit / tour; Partizip II: besichtigt", "Verb"),
    ("besuchen", "none", "to visit; Partizip II: besucht", "Verb"),
    ("bestellen", "none", "to order; Partizip II: bestellt", "Verb"),
    ("bezahlen", "none", "to pay; Partizip II: bezahlt", "Verb"),
    ("bitten", "none", "to ask / request; Partizip II: gebeten", "Verb"),
    ("brauchen", "none", "to need; Partizip II: gebraucht", "Verb"),
    ("buchstabieren", "none", "to spell; Partizip II: buchstabiert", "Verb"),
    ("danken", "none", "to thank; Partizip II: gedankt", "Verb"),
    ("diskutieren", "none", "to discuss; Partizip II: diskutiert", "Verb"),
    ("einpacken", "none", "to pack; Partizip II: eingepackt", "Verb"),
    ("einsteigen", "none", "to board; Partizip II: eingestiegen", "Verb"),
    ("empfehlen", "none", "to recommend; Partizip II: empfohlen", "Verb"),
    ("entdecken", "none", "to discover; Partizip II: entdeckt", "Verb"),
    ("entscheiden", "none", "to decide; Partizip II: entschieden", "Verb"),
    ("entschuldigen", "none", "to apologize; Partizip II: entschuldigt", "Verb"),
    ("erklären", "none", "to explain; Partizip II: erklärt", "Verb"),
    ("erlauben", "none", "to allow; Partizip II: erlaubt", "Verb"),
    ("erreichen", "none", "to reach; Partizip II: erreicht", "Verb"),
    ("erwarten", "none", "to expect; Partizip II: erwartet", "Verb"),
    ("erzählen", "none", "to tell; Partizip II: erzählt", "Verb"),
    # Adjectives (25)
    ("allgemein", "none", "general", "Adjective"),
    ("anstrengend", "none", "tiring", "Adjective"),
    ("aufregend", "none", "exciting", "Adjective"),
    ("bedeutend", "none", "significant", "Adjective"),
    ("beliebt", "none", "popular", "Adjective"),
    ("bereit", "none", "ready", "Adjective"),
    ("auffällig", "none", "conspicuous / noticeable", "Adjective"),
    ("dankbar", "none", "grateful", "Adjective"),
    ("ehrlich", "none", "honest", "Adjective"),
    ("eindeutig", "none", "unambiguous", "Adjective"),
    ("einverstanden", "none", "in agreement", "Adjective"),
    ("enttäuscht", "none", "disappointed", "Adjective"),
    ("erfahren", "none", "experienced", "Adjective"),
    ("erfolgreich", "none", "successful", "Adjective"),
    ("fähig", "none", "capable", "Adjective"),
    ("fleißig", "none", "diligent", "Adjective"),
    ("freundlich", "none", "friendly", "Adjective"),
    ("frustriert", "none", "frustrated", "Adjective"),
    ("geduldig", "none", "patient", "Adjective"),
    ("gefährlich", "none", "dangerous", "Adjective"),
    ("gemütlich", "none", "cozy", "Adjective"),
    ("genau", "none", "exact", "Adjective"),
    ("gesund", "none", "healthy", "Adjective"),
    ("glücklich", "none", "happy", "Adjective"),
    ("höflich", "none", "polite", "Adjective"),
    ("interessant", "none", "interesting", "Adjective"),
]


def article_for_json(article: str) -> str | None:
    a = article.strip().lower()
    if a == "none":
        return "none"
    return article


def row(gw: str, art: str, en: str, cat: str) -> dict:
    return {
        "id": str(uuid.uuid4()),
        "germanWord": gw,
        "article": article_for_json(art),
        "englishTranslation": en,
        "level": "A2",
        "category": cat,
        "version": 1,
    }


def main() -> None:
    paths = [
        REPO / "LearnHappyGerman" / "full_vocabulary.json",
        REPO / "LearnHappyGerman" / "LearnHappyGerman" / "full_vocabulary.json",
    ]
    for path in paths:
        payload = json.loads(path.read_text(encoding="utf-8"))
        words = payload["words"]
        keys = {(w["germanWord"], w["level"]) for w in words}
        existing_gw = {w["germanWord"] for w in words}

        added = 0
        for gw, art, en, cat in RAW_A2:
            if (gw, "A2") in keys:
                continue
            if gw in existing_gw:
                # Skip if lemma already present at any level (keep corpus one lemma per row policy)
                continue
            words.append(row(gw, art, en, cat))
            keys.add((gw, "A2"))
            existing_gw.add(gw)
            added += 1

        payload["words"] = words
        path.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
        print(f"{path.relative_to(REPO)}: +{added} A2 rows, total {len(words)}")


if __name__ == "__main__":
    main()
