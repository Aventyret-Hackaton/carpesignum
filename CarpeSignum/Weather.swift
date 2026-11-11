import Foundation

/// Bonusteknik: data från ett öppet API (Open-Meteo, gratis och utan nyckel).
/// Hämtar vädret i en avlägsen stad och låter det påverka ett av dina hus.
/// Utan internet visas helt enkelt ingenting.
@Observable
final class WeatherOracle {
    struct Reading {
        let label: String   // "FJÄRRSIGNAL · ULAANBAATAR"
        let line: String    // "Det snöar, −12 °C. Det påverkar ditt sjätte hus."
    }

    private(set) var reading: Reading?
    private var fetchedDay: String?

    private struct City { let name: String; let lat: Double; let lon: Double }
    private static let cities = [
        City(name: "Brasília", lat: -15.79, lon: -47.88),
        City(name: "Ulaanbaatar", lat: 47.92, lon: 106.92),
        City(name: "Reykjavik", lat: 64.15, lon: -21.94),
        City(name: "Nairobi", lat: -1.29, lon: 36.82),
        City(name: "Lima", lat: -12.05, lon: -77.04),
        City(name: "Wellington", lat: -41.29, lon: 174.78),
        City(name: "Tasjkent", lat: 41.30, lon: 69.24),
        City(name: "Anchorage", lat: 61.22, lon: -149.90),
        City(name: "Hobart", lat: -42.88, lon: 147.33),
        City(name: "Timbuktu", lat: 16.77, lon: -3.01),
        City(name: "Longyearbyen", lat: 78.22, lon: 15.65),
        City(name: "Kiruna", lat: 67.86, lon: 20.23),
    ]

    private static let ordinals = ["första", "andra", "tredje", "fjärde", "femte", "sjätte",
                                   "sjunde", "åttonde", "nionde", "tionde", "elfte", "tolfte"]

    func fetch(for date: Date = Date()) {
        let day = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let key = "\(day.year ?? 0)-\(day.month ?? 0)-\(day.day ?? 0)"
        guard fetchedDay != key else { return }

        // Samma stad och samma hus hela dagen.
        var rng = SeededRandom(seed: UInt64(abs(key.hashValueStable)))
        let city = Self.cities.randomElement(using: &rng)!
        let house = Self.ordinals.randomElement(using: &rng)!

        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(city.lat)),
            URLQueryItem(name: "longitude", value: String(city.lon)),
            URLQueryItem(name: "current", value: "temperature_2m,weather_code"),
        ]
        var request = URLRequest(url: components.url!)
        request.timeoutInterval = 6

        Task { @MainActor in
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let decoded = try JSONDecoder().decode(Response.self, from: data)
                let temp = Int(decoded.current.temperature_2m.rounded())
                let tempText = temp < 0 ? "\u{2212}\(abs(temp)) °C" : "\(temp) °C"
                let phrase = Self.phrase(for: decoded.current.weather_code)
                reading = Reading(
                    label: "FJÄRRSIGNAL · \(city.name.uppercased())",
                    line: "\(phrase), \(tempText). Det påverkar ditt \(house) hus."
                )
                fetchedDay = key
            } catch {
                reading = nil   // Inget internet: raden syns inte.
            }
        }
    }

    /// WMO-väderkoder till svenska.
    private static func phrase(for code: Int) -> String {
        switch code {
        case 0: return "Det är klart"
        case 1, 2: return "Det är halvklart"
        case 3: return "Det är mulet"
        case 45, 48: return "Det är dimmigt"
        case 51...57: return "Det duggar"
        case 61...67, 80...82: return "Det regnar"
        case 71...77, 85, 86: return "Det snöar"
        case 95...99: return "Det åskar"
        default: return "Vädret är obestämbart"
        }
    }

    private struct Response: Decodable {
        struct Current: Decodable {
            let temperature_2m: Double
            let weather_code: Int
        }
        let current: Current
    }
}

private extension String {
    /// Stabil hash (Swifts egen hash ändras varje gång appen startar).
    var hashValueStable: Int64 {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in utf8 { hash = (hash ^ UInt64(byte)) &* 0x100000001b3 }
        return Int64(bitPattern: hash >> 1)
    }
}
