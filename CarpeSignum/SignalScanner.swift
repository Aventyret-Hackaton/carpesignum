import Foundation
import CoreBluetooth

/// En pryl som telefonen har hört.
struct Signal: Identifiable, Codable, Hashable {
    let id: UUID
    var advertisedName: String?
    var manufacturerID: UInt16?
    var rssi: Int
    var firstSeen: Date
    var lastSeen: Date
}

/// Lyssnar efter Bluetooth-signaler omkring telefonen.
/// Om Bluetooth inte finns (till exempel i simulatorn) eller om demoläget är på,
/// används påhittade signaler istället.
@Observable
final class SignalScanner: NSObject, CBCentralManagerDelegate {
    private(set) var signals: [UUID: Signal] = [:]
    private(set) var bluetoothAvailable = false
    private(set) var statusText = "Väntar på kosmos"

    /// Reservläget: påhittade signaler om tekniken strular under demon.
    var demoMode: Bool {
        didSet {
            UserDefaults.standard.set(demoMode, forKey: "demoMode")
            restart()
        }
    }

    private var central: CBCentralManager?
    private var demoTimer: Timer?
    private var pruneTimer: Timer?

    override init() {
        demoMode = UserDefaults.standard.bool(forKey: "demoMode")
        super.init()
    }

    /// Signaler som hörts de senaste 30 sekunderna, starkast först.
    var currentSignals: [Signal] {
        let cutoff = Date().addingTimeInterval(-30)
        return signals.values
            .filter { $0.lastSeen > cutoff }
            .sorted { $0.rssi > $1.rssi }
    }

    func start() {
        pruneTimer?.invalidate()
        pruneTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.prune()
        }
        if demoMode {
            startDemo()
        } else if central == nil {
            central = CBCentralManager(delegate: self, queue: .main)
        } else if central?.state == .poweredOn {
            beginScan()
        }
    }

    private func restart() {
        central?.stopScan()
        demoTimer?.invalidate()
        demoTimer = nil
        signals = [:]
        start()
    }

    // MARK: Riktig Bluetooth

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            bluetoothAvailable = true
            if !demoMode { beginScan() }
        case .unauthorized:
            bluetoothAvailable = false
            statusText = "Kosmos saknar tillstånd att lyssna"
            fallBackToDemo()
        case .poweredOff:
            bluetoothAvailable = false
            statusText = "Bluetooth är avstängt"
            fallBackToDemo()
        case .unsupported:
            bluetoothAvailable = false
            statusText = "Enheten saknar Bluetooth"
            fallBackToDemo()
        default:
            break
        }
    }

    private func beginScan() {
        statusText = "Lyssnar efter signaler"
        central?.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        guard !demoMode else { return }
        let value = RSSI.intValue
        // 127 betyder att signalstyrkan inte gick att läsa.
        guard value < 0, value > -110 else { return }

        let name = (advertisementData[CBAdvertisementDataLocalNameKey] as? String) ?? peripheral.name
        var maker: UInt16?
        if let data = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data, data.count >= 2 {
            maker = UInt16(data[data.startIndex]) | (UInt16(data[data.startIndex + 1]) << 8)
        }
        record(id: peripheral.identifier, name: name, maker: maker, rssi: value)
    }

    private func record(id: UUID, name: String?, maker: UInt16?, rssi: Int) {
        let now = Date()
        if var existing = signals[id] {
            // Jämnar ut signalen lite så att siffrorna inte hoppar för mycket.
            existing.rssi = Int((Double(existing.rssi) * 0.6 + Double(rssi) * 0.4).rounded())
            existing.lastSeen = now
            if let name, !name.isEmpty { existing.advertisedName = name }
            if let maker { existing.manufacturerID = maker }
            signals[id] = existing
        } else {
            signals[id] = Signal(id: id, advertisedName: name, manufacturerID: maker,
                                 rssi: rssi, firstSeen: now, lastSeen: now)
        }
    }

    private func prune() {
        let cutoff = Date().addingTimeInterval(-120)
        signals = signals.filter { $0.value.lastSeen > cutoff }
    }

    // MARK: Reservläge med påhittade signaler

    private func fallBackToDemo() {
        if !demoMode { startDemo() }
    }

    private func startDemo() {
        statusText = demoMode ? "Demoläge" : statusText
        demoTimer?.invalidate()
        seedDemoSignals()
        demoTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.jitterDemoSignals()
        }
    }

    private func seedDemoSignals() {
        let now = Date()
        let samples: [(String?, UInt16?, Int, TimeInterval)] = [
            ("Fridas iPhone", 0x004C, -41, 3 * 3600 + 300),
            ("Apple Watch", 0x004C, -45, 2 * 3600),
            (nil, 0x004C, -52, 3 * 3600 + 5 * 60),
            ("AirPods", 0x004C, -64, 1800),
            (nil, 0x0075, -71, 900),
            (nil, 0x0006, -76, 600),
            (nil, 0x00C4, -68, 2400),
            (nil, 0x0065, -83, 300),
            (nil, 0x004C, -88, 120),
            (nil, nil, -92, 60),
            (nil, 0x004C, -95, 60),
            (nil, 0x0075, -81, 400),
        ]
        var result: [UUID: Signal] = [:]
        for (index, sample) in samples.enumerated() {
            let id = UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", index + 1))!
            result[id] = Signal(id: id, advertisedName: sample.0, manufacturerID: sample.1,
                                rssi: sample.2, firstSeen: now.addingTimeInterval(-sample.3),
                                lastSeen: now)
        }
        // Fler namnlösa prylar i bakgrunden, som i ett riktigt kontor.
        for index in 0..<29 {
            let id = UUID(uuidString: String(format: "00000000-0000-0000-0001-%012d", index))!
            result[id] = Signal(id: id, advertisedName: nil,
                                manufacturerID: index % 4 == 0 ? 0x0006 : 0x004C,
                                rssi: -84 - (index % 14), firstSeen: now.addingTimeInterval(-60),
                                lastSeen: now)
        }
        signals = result
    }

    private func jitterDemoSignals() {
        let now = Date()
        for (id, var signal) in signals {
            signal.rssi = max(-100, min(-35, signal.rssi + Int.random(in: -2...2)))
            signal.lastSeen = now
            signals[id] = signal
        }
    }
}
