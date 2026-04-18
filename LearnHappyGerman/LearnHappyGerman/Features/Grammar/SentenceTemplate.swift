import Foundation

/// A1 present-tense cloze pattern: learner supplies the **conjugated** verb form.
struct SentenceTemplate: Identifiable, Equatable {
    let id: UUID
    /// German sentence with `___` marking the blank (A1 scope: present indicative).
    let displayText: String
    /// Lemma (dictionary form) for learner hint only.
    let infinitive: String
    /// One or more accepted typed answers after normalization (lowercase, ß→ss).
    let acceptedAnswers: [String]
    /// Short English gloss for the sentence.
    let englishHint: String

    init(
        id: UUID = UUID(),
        displayText: String,
        infinitive: String,
        acceptedAnswers: [String],
        englishHint: String
    ) {
        self.id = id
        self.displayText = displayText
        self.infinitive = infinitive
        self.acceptedAnswers = acceptedAnswers
        self.englishHint = englishHint
    }
}

/// Curated A1 **Präsens** patterns (grammatically simple: high-frequency verbs, no subjunctive).
enum A1GrammarSentenceLibrary {
    static let templates: [SentenceTemplate] = [
        SentenceTemplate(
            displayText: "Ich ___ nach Hause.",
            infinitive: "gehen",
            acceptedAnswers: ["gehe"],
            englishHint: "I go home."
        ),
        SentenceTemplate(
            displayText: "Du ___ gern Musik.",
            infinitive: "hören",
            acceptedAnswers: ["hörst"],
            englishHint: "You like to listen to music."
        ),
        SentenceTemplate(
            displayText: "Er ___ Deutsch in der Schule.",
            infinitive: "lernen",
            acceptedAnswers: ["lernt"],
            englishHint: "He learns German at school."
        ),
        SentenceTemplate(
            displayText: "Wir ___ im Park.",
            infinitive: "spielen",
            acceptedAnswers: ["spielen"],
            englishHint: "We play in the park."
        ),
        SentenceTemplate(
            displayText: "Ihr ___ Wasser.",
            infinitive: "trinken",
            acceptedAnswers: ["trinkt"],
            englishHint: "You (pl.) drink water."
        ),
        SentenceTemplate(
            displayText: "Sie ___ aus Berlin.",
            infinitive: "kommen",
            acceptedAnswers: ["kommen"],
            englishHint: "They / you (formal) come from Berlin."
        ),
        SentenceTemplate(
            displayText: "Ich ___ müde.",
            infinitive: "sein",
            acceptedAnswers: ["bin"],
            englishHint: "I am tired."
        ),
        SentenceTemplate(
            displayText: "Du ___ sehr nett.",
            infinitive: "sein",
            acceptedAnswers: ["bist"],
            englishHint: "You are very nice."
        ),
        SentenceTemplate(
            displayText: "Es ___ kalt heute.",
            infinitive: "sein",
            acceptedAnswers: ["ist"],
            englishHint: "It is cold today."
        ),
        SentenceTemplate(
            displayText: "Wir ___ Pizza.",
            infinitive: "essen",
            acceptedAnswers: ["essen"],
            englishHint: "We eat pizza."
        ),
        SentenceTemplate(
            displayText: "Ich ___ ein Buch.",
            infinitive: "lesen",
            acceptedAnswers: ["lese"],
            englishHint: "I read a book."
        ),
        SentenceTemplate(
            displayText: "Du ___ jeden Tag.",
            infinitive: "arbeiten",
            acceptedAnswers: ["arbeitest"],
            englishHint: "You work every day."
        ),
        SentenceTemplate(
            displayText: "Sie ___ den Bus.",
            infinitive: "nehmen",
            acceptedAnswers: ["nimmt"],
            englishHint: "She takes the bus."
        ),
        SentenceTemplate(
            displayText: "Ich ___ früh auf.",
            infinitive: "aufstehen",
            acceptedAnswers: ["stehe"],
            englishHint: "I get up early. (aufstehen)"
        ),
        SentenceTemplate(
            displayText: "Wir ___ frühstücken.",
            infinitive: "müssen",
            acceptedAnswers: ["müssen"],
            englishHint: "We have to have breakfast."
        )
    ]
}
