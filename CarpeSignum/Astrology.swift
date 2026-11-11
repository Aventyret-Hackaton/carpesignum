import Foundation

/// Carpe Signums "astrologi": hur signaler blir hus, tecken och planeter.
enum Astrology {

    // MARK: Hus (I–XII) och rum (fem rum i hemmet)

    struct House {
        let number: Int        // 1–12
        let roman: String      // "VII"
        let ordinal: String    // "sjunde"
        let room: String       // "köket"
        let roomPlain: String  // "kök"
    }

    private static let romans = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"]
    private static let ordinals = ["första", "andra", "tredje", "fjärde", "femte", "sjätte",
                                   "sjunde", "åttonde", "nionde", "tionde", "elfte", "tolfte"]

    /// Husnumret följer signalstyrkan: −71 dBm hamnar i VII, −88 dBm i III.
    /// Rummet är ett av hemmets fem, ju närmare desto mer privat.
    static func house(for rssi: Int) -> House {
        let number = max(1, min(12, (rssi + 100) / 4))
        let room: (String, String)
        switch rssi {
        case (-50)...: room = ("badrummet", "badrum")
        case (-60)..<(-50): room = ("sovrummet", "sovrum")
        case (-75)..<(-60): room = ("köket", "kök")
        case (-85)..<(-75): room = ("vardagsrummet", "vardagsrum")
        default: room = ("hallen", "hall")
        }
        return House(number: number, roman: romans[number - 1], ordinal: ordinals[number - 1],
                     room: room.0, roomPlain: room.1)
    }

    // MARK: Avstånd

    static func distance(for rssi: Int) -> String {
        switch rssi {
        case (-60)...: return "nära"
        case (-80)..<(-60): return "mellan"
        default: return "långt"
        }
    }

    // MARK: Tillverkare

    static func manufacturer(_ id: UInt16?) -> String? {
        guard let id else { return nil }
        switch id {
        case 0x004C: return "Apple"
        case 0x0006: return "Microsoft"
        case 0x0075: return "Samsung"
        case 0x00C4: return "LG"
        case 0x0065: return "HP"
        case 0x00E0: return "Google"
        case 0x0087: return "Garmin"
        case 0x0157: return "Huami"
        case 0x038F: return "Xiaomi"
        case 0x0171: return "Amazon"
        case 0x012D: return "Sony"
        case 0x009E: return "Bose"
        default: return nil
        }
    }

    // MARK: Tecken (byts när du byter pryl)

    struct Sign {
        let name: String       // "Oxen"
        let genitive: String   // "Oxens"
    }

    static func sign(for signal: Signal?) -> Sign {
        switch manufacturer(signal?.manufacturerID) {
        case "Apple": return Sign(name: "Oxen", genitive: "Oxens")
        case "Samsung": return Sign(name: "Skorpionen", genitive: "Skorpionens")
        case "Microsoft": return Sign(name: "Vattumannen", genitive: "Vattumannens")
        case "LG": return Sign(name: "Kräftan", genitive: "Kräftans")
        case "HP": return Sign(name: "Stenbocken", genitive: "Stenbockens")
        case "Google": return Sign(name: "Tvillingarna", genitive: "Tvillingarnas")
        case "Garmin", "Huami", "Xiaomi": return Sign(name: "Skytten", genitive: "Skyttens")
        case "Sony", "Bose": return Sign(name: "Vågen", genitive: "Vågens")
        case .some: return Sign(name: "Lejonet", genitive: "Lejonets")
        case .none: return Sign(name: "Fiskarna", genitive: "Fiskarnas")
        }
    }

    // MARK: Namn på prylar

    /// Kontorsplaneter: några namnlösa prylar får i hemlighet nya namn.
    static let officePlanets = ["Kaffemaskinen", "Skrivaren", "Mikron", "Diskmaskinen", "Kylskåpet"]
    private static var planetCache: [UUID: String] = [:]

    /// Ger varje signal ett visningsnamn. Namnlösa prylar blir "Apple-enhet"
    /// eller, för några av dem, en kontorsplanet.
    static func displayNames(for signals: [Signal]) -> [UUID: String] {
        var names: [UUID: String] = [:]
        let unnamed = signals
            .filter { ($0.advertisedName ?? "").isEmpty }
            .sorted { $0.id.uuidString < $1.id.uuidString }
        // Välj ut några namnlösa prylar på medelavstånd som planeter.
        // En pryl som en gång blivit en planet behåller sitt namn.
        let present = Set(signals.map(\.id))
        var free = officePlanets.filter { name in
            !planetCache.contains { present.contains($0.key) && $0.value == name }
        }
        for signal in unnamed where planetCache[signal.id] == nil && !free.isEmpty {
            if signal.rssi > -85 && signal.rssi < -55 {
                planetCache[signal.id] = free.removeFirst()
            }
        }
        let planetFor = planetCache
        for signal in signals {
            if let name = signal.advertisedName, !name.isEmpty {
                names[signal.id] = name
            } else if let planet = planetFor[signal.id] {
                names[signal.id] = planet
            } else if let maker = manufacturer(signal.manufacturerID) {
                names[signal.id] = "Okänd \(maker)-enhet"
            } else {
                names[signal.id] = "Okänd enhet"
            }
        }
        return names
    }

    static func isOfficePlanet(_ name: String) -> Bool {
        officePlanets.contains(name)
    }

    // MARK: Format

    /// "−67 dBm" med riktigt minustecken.
    static func dbm(_ rssi: Int) -> String {
        "\(dbmShort(rssi)) dBm"
    }

    /// "−67" utan enhet.
    static func dbmShort(_ rssi: Int) -> String {
        rssi < 0 ? "\u{2212}\(abs(rssi))" : "\(rssi)"
    }

    static func duration(_ seconds: TimeInterval) -> String {
        let minutes = max(1, Int(seconds / 60))
        if minutes < 60 { return "\(minutes) min" }
        return String(format: "%d h %02d min", minutes / 60, minutes % 60)
    }

    /// "tre timmar", "tolv minuter" – för löptext.
    static func durationWords(_ seconds: TimeInterval) -> String {
        let words = ["noll", "en", "två", "tre", "fyra", "fem", "sex", "sju", "åtta", "nio", "tio",
                     "elva", "tolv", "tretton", "fjorton", "femton", "sexton", "sjutton", "arton", "nitton", "tjugo"]
        let minutes = max(1, Int(seconds / 60))
        if minutes >= 60 {
            let hours = minutes / 60
            if hours == 1 { return "en timme" }
            return hours <= 20 ? "\(words[hours]) timmar" : "\(hours) timmar"
        }
        if minutes == 1 { return "en minut" }
        return minutes <= 20 ? "\(words[minutes]) minuter" : "\(minutes) minuter"
    }
}
