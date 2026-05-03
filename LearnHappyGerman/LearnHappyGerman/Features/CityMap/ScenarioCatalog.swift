import Foundation

// swiftlint:disable type_body_length trailing_comma
// Large static script table: twelve locations × multi-turn dialogue.

/// All CityWalk location scripts (A1/A2 German, present tense; content matches learner-facing examples).
enum ScenarioCatalog {
    static func config(for location: CityMapHotspotLayout.Building) -> ScenarioConfig {
        switch location {
        case .trainStation: return trainStation
        case .bakery: return bakery
        case .restaurant: return restaurant
        case .coffeeShop: return coffeeShop
        case .hospital: return hospital
        case .centralHotel: return centralHotel
        case .supermarket: return supermarket
        case .shoppingCenter: return shoppingCenter
        case .postOffice: return postOffice
        case .cinema: return cinema
        case .school: return school
        case .townHall: return townHall
        }
    }

    // MARK: - Train Station

    private static let trainStation = ScenarioConfig(
        locationID: .trainStation,
        clerkRoleLabel: "Mitarbeiter",
        initialGreeting: "Wohin möchten Sie fahren?",
        dialogueRounds: [
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Nach München, bitte.",
                    "Ich möchte nach München.",
                    "Nach München bitte",
                    "Ein Ticket nach München, bitte.",
                ],
                clerkReply: "Einfach oder hin und zurück?"
            ),
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Hin und zurück.",
                    "Hin und zurück, bitte.",
                    "Hin und zurueck.",
                ],
                clerkReply: "Gut. Hin und zurück nach München kostet heute zweiundachtzig Euro. Gleis 6, bitte."
            ),
        ],
        topicVocabulary: ["Gleis", "Ticket", "Fahrplan", "Zug", "bahnhof", "München"],
        farewellClerkLine: nil,
        symbolName: "tram.fill",
        backgroundImageName: nil
    )

    // MARK: - Bakery

    private static let bakery = ScenarioConfig(
        locationID: .bakery,
        clerkRoleLabel: "Verkäufer",
        initialGreeting: "Was möchten Sie?",
        dialogueRounds: [
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Drei Brötchen, bitte.",
                    "drei brötchen bitte",
                    "Ich möchte drei Brötchen.",
                ],
                clerkReply: "Sonst noch etwas?"
            ),
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Nein, danke. Das ist alles.",
                    "Nein danke das ist alles",
                    "Nein, danke.",
                    "Das ist alles.",
                ],
                clerkReply: "Alles klar. Das macht fünf Euro zehn. Auf Wiedersehen!"
            ),
        ],
        topicVocabulary: ["Brezel", "Brot", "bezahlen", "Brötchen", "bitte", "danke"],
        farewellClerkLine: nil,
        symbolName: "birthday.cake",
        backgroundImageName: nil
    )

    // MARK: - Restaurant

    private static let restaurant = ScenarioConfig(
        locationID: .restaurant,
        clerkRoleLabel: "Kellner",
        initialGreeting: "Haben Sie einen Tisch reserviert?",
        dialogueRounds: [
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Nein, für zwei Personen bitte.",
                    "Für zwei Personen, bitte.",
                    "Nein. Für zwei Personen, bitte.",
                ],
                clerkReply: "Was möchten Sie trinken?"
            ),
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Ein Mineralwasser, bitte.",
                    "Mineralwasser, bitte.",
                    "Ein Wasser, bitte.",
                ],
                clerkReply: "Sehr gern. Ich bringe es gleich. Guten Appetit!"
            ),
        ],
        topicVocabulary: ["Speisekarte", "Kellner", "Rechnung", "Tisch", "trinken", "Personen"],
        farewellClerkLine: nil,
        symbolName: "fork.knife",
        backgroundImageName: nil
    )

    // MARK: - Coffee Shop

    private static let coffeeShop = ScenarioConfig(
        locationID: .coffeeShop,
        clerkRoleLabel: "Barista",
        initialGreeting: "Bitte schön?",
        dialogueRounds: [
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Einen Cappuccino und ein Stück Kuchen.",
                    "Cappuccino und Kuchen, bitte.",
                    "Einen Cappuccino und Kuchen, bitte.",
                ],
                clerkReply: "Mit Zucker und Milch?"
            ),
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Nur mit Milch, bitte.",
                    "Nur Milch, bitte.",
                    "Mit Milch, ohne Zucker.",
                ],
                clerkReply: "Gut. Sieben Euro fünfzig, bitte. Schönen Tag!"
            ),
        ],
        topicVocabulary: ["Kaffee", "Tasse", "Gebäck", "Milch", "Zucker", "Kuchen"],
        farewellClerkLine: nil,
        symbolName: "cup.and.saucer.fill",
        backgroundImageName: nil
    )

    // MARK: - Hospital

    private static let hospital = ScenarioConfig(
        locationID: .hospital,
        clerkRoleLabel: "Empfang",
        initialGreeting: "Was fehlt Ihnen?",
        dialogueRounds: [
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Ich habe Kopfschmerzen und Fieber.",
                    "Kopfschmerzen und Fieber.",
                    "Ich habe Fieber und Kopfschmerzen.",
                ],
                clerkReply: "Haben Sie Ihre Versicherungskarte?"
            ),
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Ja, hier bitte.",
                    "Ja. Hier, bitte.",
                    "Hier bitte.",
                ],
                clerkReply: "Danke. Bitte nehmen Sie Platz im Wartezimmer. Der Arzt kommt gleich."
            ),
        ],
        topicVocabulary: ["Arzt", "Termin", "Rezept", "Fieber", "Kopfschmerzen", "Karte"],
        farewellClerkLine: nil,
        symbolName: "cross.case.fill",
        backgroundImageName: nil
    )

    // MARK: - Hotel

    private static let centralHotel = ScenarioConfig(
        locationID: .centralHotel,
        clerkRoleLabel: "Rezeption",
        initialGreeting: "Guten Tag, kann ich Ihnen helfen?",
        dialogueRounds: [
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Ich habe ein Zimmer reserviert.",
                    "Ich habe reserviert.",
                    "Eine Reservierung, bitte.",
                ],
                clerkReply: "Auf welchen Namen, bitte?"
            ),
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Mein Name ist Schmidt.",
                    "Mein Name ist Müller.",
                    "Auf den Namen Schmidt.",
                    "Der Name ist Schmidt.",
                ],
                clerkReply: "Danke, Herr Schmidt. Hier ist Ihr Schlüssel für Zimmer 212. Schönen Aufenthalt!"
            ),
        ],
        topicVocabulary: ["Schlüssel", "Frühstück", "Nacht", "Zimmer", "Reservierung", "Name"],
        farewellClerkLine: nil,
        symbolName: "bed.double.fill",
        backgroundImageName: nil
    )

    // MARK: - Supermarket

    private static let supermarket = ScenarioConfig(
        locationID: .supermarket,
        clerkRoleLabel: "Mitarbeiter",
        initialGreeting: "Brauchen Sie eine Tüte?",
        dialogueRounds: [
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Ja, bitte. Wo finde ich Milch?",
                    "Ja bitte wo finde ich milch",
                    "Ja. Wo ist die Milch?",
                ],
                clerkReply: "Im Regal drei, neben dem Käse."
            ),
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Danke schön.",
                    "Danke.",
                    "Vielen Dank.",
                ],
                clerkReply: "Gern geschehen. Noch etwas?"
            ),
        ],
        topicVocabulary: ["Angebot", "Kasse", "Lebensmittel", "Milch", "Tüte", "Regal"],
        farewellClerkLine: nil,
        symbolName: "cart.fill",
        backgroundImageName: nil
    )

    // MARK: - Post Office

    private static let postOffice = ScenarioConfig(
        locationID: .postOffice,
        clerkRoleLabel: "Mitarbeiter",
        initialGreeting: "Bitte schön?",
        dialogueRounds: [
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Ich möchte dieses Paket verschicken.",
                    "Dieses Paket verschicken, bitte.",
                    "Ich will dieses Paket schicken.",
                ],
                clerkReply: "Wohin geht das Paket?"
            ),
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Nach Spanien.",
                    "Das Paket geht nach Spanien.",
                    "Spanien, bitte.",
                ],
                clerkReply: "Gut. Das wiegt ein Kilo. Mit Briefmarke kostet es zwölf Euro. Auf Wiedersehen!"
            ),
        ],
        topicVocabulary: ["Briefmarke", "Gewicht", "Adresse", "Paket", "schicken", "Spanien"],
        farewellClerkLine: nil,
        symbolName: "envelope.open.fill",
        backgroundImageName: nil
    )

    // MARK: - Shopping Center

    private static let shoppingCenter = ScenarioConfig(
        locationID: .shoppingCenter,
        clerkRoleLabel: "Mitarbeiter",
        initialGreeting: "Kann ich Ihnen helfen?",
        dialogueRounds: [
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Ich suche eine Jeans in Größe M.",
                    "Jeans Größe M, bitte.",
                    "Eine Jeans in M, bitte.",
                ],
                clerkReply: "Die Umkleidekabine ist dort hinten."
            ),
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Danke, die passt gut.",
                    "Danke, es passt.",
                    "Super, danke.",
                ],
                clerkReply: "Freut mich! Schönen Einkauf noch!"
            ),
        ],
        topicVocabulary: ["Rabatt", "Kleidung", "Umtausch", "Jeans", "Größe", "Umkleidekabine"],
        farewellClerkLine: nil,
        symbolName: "bag.fill",
        backgroundImageName: nil
    )

    // MARK: - Cinema

    private static let cinema = ScenarioConfig(
        locationID: .cinema,
        clerkRoleLabel: "Kasse",
        initialGreeting: "Für welchen Film möchten Sie Karten?",
        dialogueRounds: [
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Zwei Karten für den neuen Actionfilm.",
                    "Zwei Karten, den neuen Actionfilm, bitte.",
                    "Zwei Karten für den Actionfilm.",
                ],
                clerkReply: "Vorne oder hinten sitzen?"
            ),
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "In der Mitte, bitte.",
                    "Mitte, bitte.",
                    "Wir sitzen gern in der Mitte.",
                ],
                clerkReply: "Gut. Zusammen achtzehn Euro. Viel Spaß bei der Vorstellung!"
            ),
        ],
        topicVocabulary: ["Popcorn", "Sitzplatz", "Vorstellung", "Film", "Karten", "Kino"],
        farewellClerkLine: nil,
        symbolName: "film.fill",
        backgroundImageName: nil
    )

    // MARK: - School

    private static let school = ScenarioConfig(
        locationID: .school,
        clerkRoleLabel: "Lehrerin",
        initialGreeting: "Hallo! Bist du neu im Deutschkurs?",
        dialogueRounds: [
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Ja, ich lerne jetzt A1.2.",
                    "Ja, ich bin neu im Kurs A1.2.",
                    "Ja, A1.2.",
                ],
                clerkReply: "Super! Wo ist dein Kursraum?"
            ),
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Raum 204.",
                    "In Raum 204.",
                    "Mein Kurs ist in Raum 204.",
                ],
                clerkReply: "Perfekt. Bis später im Unterricht!"
            ),
        ],
        topicVocabulary: ["Lehrer", "Hausaufgabe", "Prüfung", "Kurs", "Raum", "Deutsch"],
        farewellClerkLine: nil,
        symbolName: "book.fill",
        backgroundImageName: nil
    )

    // MARK: - Town Hall

    private static let townHall = ScenarioConfig(
        locationID: .townHall,
        clerkRoleLabel: "Mitarbeiter",
        initialGreeting: "Guten Tag. Was kann ich für Sie tun?",
        dialogueRounds: [
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Ich möchte mich anmelden.",
                    "Ich will mich anmelden.",
                    "Anmeldung, bitte.",
                ],
                clerkReply: "Haben Sie Ihren Pass und Mietvertrag?"
            ),
            ScenarioDialogueRound(
                possibleUserResponses: [
                    "Ja, hier sind die Dokumente.",
                    "Ja, hier bitte.",
                    "Hier sind Pass und Vertrag.",
                ],
                clerkReply: "Danke. Bitte unterschreiben Sie hier. Sie bekommen einen Termin nächste Woche."
            ),
        ],
        topicVocabulary: ["Formular", "Ausweis", "Termin", "Pass", "Mietvertrag", "anmelden"],
        farewellClerkLine: nil,
        symbolName: "building.columns.fill",
        backgroundImageName: nil
    )
}

// swiftlint:enable type_body_length trailing_comma
