import Foundation

struct TodoItem: Codable, Identifiable, Hashable {
    let id: Int
    let text: String
    let source: String   // t.ex. "SAMSUNG-ENHET · −81 dBm"
    let level: Int       // 1 = vardagligt, 5 = drastiskt
    var done: Bool = false
}

/// En rad i "Så räknade vi".
struct BasisRow: Codable, Hashable {
    let name: String
    let detail: String   // t.ex. "3 h 05 min · −67" eller "VII · kök · −71"
}

/// Dagens läsning: horoskopet och guiden.
struct Reading: Codable {
    let date: Date
    let headline: String       // "Kaffemaskinen står i ditt sjunde hus"
    let paragraphs: [String]   // två stycken i serif
    let quote: String          // "Något dramatiskt" i guld
    let chips: [String]
    let basis: [BasisRow]
    let weighing: String       // "Väger kaffemaskinen mot skrivaren"
    var todos: [TodoItem]
    let deviceCount: Int

    var isFromToday: Bool { Calendar.current.isDateInToday(date) }
}

/// Sparar dagens läsning så att den är densamma hela dagen.
@Observable
final class ReadingStore {
    private(set) var reading: Reading?
    private let key = "todaysReading.v2"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode(Reading.self, from: data),
           saved.isFromToday {
            reading = saved
        }
    }

    func set(_ new: Reading) {
        reading = new
        save()
    }

    func toggle(_ todo: TodoItem) {
        guard var current = reading,
              let index = current.todos.firstIndex(where: { $0.id == todo.id }) else { return }
        current.todos[index].done.toggle()
        reading = current
        save()
    }

    func clear() {
        reading = nil
        UserDefaults.standard.removeObject(forKey: key)
    }

    private func save() {
        if let reading, let data = try? JSONEncoder().encode(reading) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

/// AI-astrologen. Väljer texter ur biblioteket och fyller dem med riktiga signaler.
enum Astrologer {

    static func read(_ input: [Signal], now: Date = Date()) -> Reading {
        let signals = input.isEmpty
            ? [Signal(id: UUID(), advertisedName: nil, manufacturerID: nil, rssi: -90,
                      firstSeen: now.addingTimeInterval(-600), lastSeen: now)]
            : input
        let names = Astrology.displayNames(for: signals)
        func name(_ s: Signal) -> String { names[s.id] ?? "Okänd enhet" }

        let sorted = signals.sorted { $0.rssi > $1.rssi }
        let strongest = sorted[0]
        let weakest = sorted[sorted.count - 1]
        let sign = Astrology.sign(for: strongest)

        // Planeterna: kontorsplaneter om det finns, annars de näst starkaste prylarna.
        let planetSignals = sorted.filter { Astrology.isOfficePlanet(name($0)) }
        let fallback = sorted.dropFirst()
        let first = planetSignals.first ?? fallback.first ?? strongest
        let second = planetSignals.dropFirst().first
            ?? fallback.first { $0.id != first.id }
            ?? first

        // Följaren: prylen som varit nära längst.
        let follower = signals.min { $0.firstSeen < $1.firstSeen } ?? strongest
        let followerName = name(follower)
        let followerDuration = now.timeIntervalSince(follower.firstSeen)
        let followerPhrase = followerName.hasPrefix("Okänd ")
            ? "en o" + followerName.dropFirst()
            : followerName

        func values(planet: Signal) -> [String: String] {
            let house = Astrology.house(for: planet.rssi)
            return [
                "dbm": Astrology.dbm(strongest.rssi),
                "svagast": Astrology.dbm(weakest.rssi),
                "tecken": sign.name,
                "teckenhus": "\(sign.genitive) hus",
                "rum": Astrology.house(for: strongest.rssi).room,
                // Liten bokstav mitt i meningen ("hälsa på kaffemaskinen"); meningar börjar ändå med stor.
                "planet": lowerFirst(name(planet)),
                "planethus": house.roman,
                "planetrum": house.room,
                "planetord": house.ordinal,
                "foljare": followerPhrase,
                "tid": Astrology.durationWords(followerDuration),
                "antal": "\(signals.count)",
            ]
        }
        let main = values(planet: first)
        let other = values(planet: second)

        // Samma dag och samma tecken ger samma läsning.
        var rng = SeededRandom(seed: seed(for: now, sign: sign.name, planet: name(first)))

        let headline = fill(Library.headlines.randomElement(using: &rng)!, main)
        let paragraphs = [
            fill(Library.openings.randomElement(using: &rng)!, main),
            fill(Library.planets.randomElement(using: &rng)!, other),
        ]
        let quote = fill(Library.followers.randomElement(using: &rng)!, main)

        let firstHouse = Astrology.house(for: first.rssi)
        let chips = [
            Astrology.dbm(strongest.rssi),
            "\(name(first)) i \(firstHouse.roman)",
            "\(followerName.replacingOccurrences(of: "Okänd ", with: "")) · \(Astrology.duration(followerDuration))",
        ]

        // Underlaget: följaren, planeterna och den starkaste prylen.
        var basisSignals: [Signal] = []
        for s in [follower, first, second, strongest] + sorted where !basisSignals.contains(where: { $0.id == s.id }) {
            basisSignals.append(s)
            if basisSignals.count == 4 { break }
        }
        let basis = basisSignals.map { s -> BasisRow in
            let house = Astrology.house(for: s.rssi)
            if Astrology.isOfficePlanet(name(s)) {
                return BasisRow(name: name(s), detail: "\(house.roman) · \(house.roomPlain) · \(Astrology.dbmShort(s.rssi))")
            }
            return BasisRow(name: name(s),
                            detail: "\(Astrology.duration(now.timeIntervalSince(s.firstSeen))) · \(Astrology.dbmShort(s.rssi))")
        }

        let weighing = "Väger \(lowerFirst(name(first))) mot \(lowerFirst(name(second)))"

        var todos: [TodoItem] = []
        for level in 1...5 {
            let template = Library.todos[level - 1].randomElement(using: &rng)!
            let source: String
            if template.contains("{planet}") || template.contains("{planetrum}") {
                source = "\(name(first)) i \(firstHouse.roman)"
            } else if level == 4 {
                source = "Merkurius i retrograd"
            } else {
                // Nivå 5 knyts till den starkaste prylen, resten till slumpvisa prylar.
                let pick = level == 5 ? strongest : sorted[Int.random(in: 0..<min(sorted.count, 8), using: &rng)]
                source = "\(name(pick)) · \(Astrology.dbm(pick.rssi))"
            }
            todos.append(TodoItem(id: level, text: fill(template, main),
                                  source: source.uppercased().replacingOccurrences(of: "DBM", with: "dBm"),
                                  level: level))
        }

        return Reading(date: now, headline: headline, paragraphs: paragraphs, quote: quote,
                       chips: chips, basis: basis, weighing: weighing, todos: todos,
                       deviceCount: signals.count)
    }

    private static func lowerFirst(_ text: String) -> String {
        // Egennamn som "Fridas iPhone" behåller stor bokstav.
        guard Astrology.isOfficePlanet(text) || text.hasPrefix("Okänd ") else { return text }
        return text.prefix(1).lowercased() + text.dropFirst()
    }

    private static func fill(_ template: String, _ values: [String: String]) -> String {
        var text = template
        for (key, value) in values {
            text = text.replacingOccurrences(of: "{\(key)}", with: value)
        }
        // Stor bokstav i början av varje mening.
        var result = ""
        var capitalizeNext = true
        for char in text {
            if capitalizeNext, char.isLetter {
                result.append(contentsOf: String(char).uppercased())
                capitalizeNext = false
            } else {
                result.append(char)
                if char == "." || char == "!" || char == "?" { capitalizeNext = true }
                else if !char.isWhitespace && char != "”" { capitalizeNext = false }
            }
        }
        return result
    }

    private static func seed(for date: Date, sign: String, planet: String) -> UInt64 {
        let day = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let text = "\(day.year ?? 0)-\(day.month ?? 0)-\(day.day ?? 0)|\(sign)|\(planet)"
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in text.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }
        return hash
    }
}

/// Slumptal som blir desamma varje gång för samma frö.
struct SeededRandom: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
