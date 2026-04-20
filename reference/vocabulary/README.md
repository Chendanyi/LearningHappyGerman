# Reference vocabulary (PDFs)

Place Goethe word-list PDFs here before running the extractor. **`*.pdf` in this folder is gitignored** so licensed files stay local and are not pushed to the remote.

**Preferred** exact names:

- `Goethe-Zertifikat_A1_Start_Wortliste.pdf`
- `Goethe-Zertifikat_A1_Fit1_Wortliste.pdf`
- `Goethe-Zertifikat_A2_Wortliste.pdf`

The script also picks up **any other `*.pdf` in this folder`** if the filename suggests the level (for example `…A2…`, `…Start…`, `…Fit1…`). If a PDF is skipped, rename it so it contains `A1`/`A2`/`Start`/`Fit1` as appropriate.

You may instead place PDFs under **`04_LearningGerman/reference/vocabulary/`** (parent of this repo); the extractor checks that path as well. Text is read with **`pypdf`**.

Then from the repository root:

```bash
python3 -m pip install -r Data/scripts/requirements-pdf-extract.txt
python3 Data/scripts/extract_vocab.py
```

Output is written to **`Data/german_vocabulary.json`** (the path the Xcode app target bundles from `../Data/`). Rebuild the app after regenerating. Grammar rules are edited in **`Data/grammar_rules.json`**.
