import pypdf
import json
import re
import os

class GermanVocabProcessor:
    """
    Processor for adult-level Goethe-Zertifikat A1 and A2 wordlists.
    Optimized for multi-line verb conjugations and strict level hierarchy.
    """
    def __init__(self):
        # Database structure: { "Word": { data_dictionary } }
        self.data = {}
        
        # Regex for Nouns: (der/die/das) + Word + (Optional Plural)
        self.re_noun = re.compile(r'^(der|die|das)\s+([A-ZÄÖÜ][\w-]+)(?:,\s+([\w\s¨-]+))?')
        
        # Regex for Verbs/Adjectives: Starts with lowercase letter
        self.re_other = re.compile(r'^([a-zäöü][\w-]+)(?:,)?')
        
        # Regex for A2 Verb Auxiliaries (Perfect Tense)
        self.re_verb_aux = re.compile(r'^(ist|hat)\s+([\w\s]+)')

    def extract_from_pdf(self, pdf_path, level):
        """Extracts text and populates the database from a single PDF."""
        if not os.path.exists(pdf_path):
            print(f"File skipped: {pdf_path} (Not found)")
            return

        print(f"Extracting level {level} from: {pdf_path}")
        reader = pypdf.PdfReader(pdf_path)
        current_word = None
        
        for page in reader.pages:
            text = page.extract_text()
            if not text: continue
            
            for line in text.split('\n'):
                line = line.strip()
                
                # Filter out PDF headers/footers and noise
                if not line or any(x in line for x in ["Seite", "WORTLISTE", "INVENTARE", "VS_"]):
                    continue

                # 1. Process Nouns
                m_noun = self.re_noun.match(line)
                if m_noun:
                    word = m_noun.group(2)
                    self._upsert_entry(
                        word=word,
                        level=level,
                        pos='noun',
                        article=m_noun.group(1),
                        plural=m_noun.group(3).strip() if m_noun.group(3) else None
                    )
                    current_word = word
                    continue

                # 2. Process Verbs/Other (Lowercase start)
                m_other = self.re_other.match(line)
                # Ensure it's not just a continuation of an auxiliary line
                if m_other and not any(line.startswith(art + " ") for art in ['der', 'die', 'das']):
                    word = m_other.group(1)
                    self._upsert_entry(word=word, level=level, pos='other')
                    current_word = word
                    continue

                # 3. Handle A2 Multi-line Verb Forms (e.g., hat gemacht)
                m_aux = self.re_verb_aux.match(line)
                if m_aux and current_word:
                    self.data[current_word]["auxiliary"] = m_aux.group(1)
                    self.data[current_word]["perfect"] = m_aux.group(2)
                    continue

                # 4. Process Example Sentences (Context capture)
                if current_word and len(line) > 5:
                    if line not in self.data[current_word]['examples']:
                        self.data[current_word]['examples'].append(line)

    def _upsert_entry(self, word, level, pos, article=None, plural=None):
        """Adds a new entry or updates existing one while preserving lowest level."""
        if word in self.data:
            # If word already exists (e.g. from A1), keep the level as A1
            if level == "A1":
                self.data[word]["level"] = "A1"
            # Update attributes if they were missing
            if article: self.data[word]["article"] = article
            if plural: self.data[word]["plural"] = plural
        else:
            self.data[word] = {
                "word": word,
                "type": pos,
                "article": article,
                "plural": plural,
                "level": level,
                "examples": []
            }

    def export_json(self, output_file):
        """Saves the database to a structured JSON file."""
        # Convert dictionary to a sorted list for consistent indexing
        final_list = sorted(self.data.values(), key=lambda x: (x['level'], x['word']))
        
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(final_list, f, ensure_ascii=False, indent=4)
        return len(final_list)

if __name__ == "__main__":
    # Setup directories
    os.makedirs('Data', exist_ok=True)
    
    processor = GermanVocabProcessor()
    
    # Task configuration (Adult focus)
    tasks = [
        ("reference/vocabulary/Goethe-Zertifikat_A1_Wortliste.pdf", "A1"),
        ("reference/vocabulary/Goethe-Zertifikat_A2_Wortliste.pdf", "A2")
    ]

    for pdf, lvl in tasks:
        processor.extract_from_pdf(pdf, lvl)

    total_count = processor.export_json("Data/german_vocabulary.json")
    print(f"--- Processing Complete ---")
    print(f"Final unique entries: {total_count}")
    print(f"File saved to: Data/german_vocabulary.json")
