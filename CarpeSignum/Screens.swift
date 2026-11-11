import SwiftUI

/// Skärm 1 · Första gången.
struct StartScreen: View {
    let pair: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("✶  PARKOPPLAD MED ÖDET")
                .labelStyle()
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 12)
            Signalkarta()
            Spacer().frame(height: 48)
            Text("Carpe Signum")
                .font(Theme.mono(34, .light))
                .tracking(-1.02)
                .foregroundStyle(Theme.text)
            Spacer().frame(height: 12)
            Text("Stjärnorna var aldrig nära nog.")
                .italicStyle()
            Spacer().frame(height: 24)
            Text("Ett horoskop som bygger på vilka enheter du varit nära idag, hur nära och hur länge.")
                .smallStyle()
                .multilineTextAlignment(.center)
            Spacer(minLength: 12)
            Knapp(etikett: "Koppla till Bluetooth", action: pair)
            Spacer().frame(height: 16)
            Text("Bara astrologen får se din data.")
                .labelStyle(Theme.faint)
        }
        .padding(.horizontal, Theme.gutter)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }
}

/// Skärm 2 · Hämtar signaler. Lyssnar några sekunder och visar vad den hör.
struct ScanningScreen: View {
    @Environment(SignalScanner.self) private var scanner
    @Environment(ReadingStore.self) private var store
    let done: () -> Void

    static let duration: TimeInterval = 7
    @State private var startedAt = Date()
    @State private var finished = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.5)) { context in
            let elapsed = min(Self.duration, context.date.timeIntervalSince(startedAt))
            let signals = scanner.currentSignals
            let names = Astrology.displayNames(for: signals)
            let houses = Set(signals.map { Astrology.house(for: $0.rssi).room }).count

            VStack(spacing: 0) {
                Text(String(format: "SKANNAR · %02d:%02d", Int(elapsed) / 60, Int(elapsed) % 60))
                    .labelStyle(Theme.faint)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer(minLength: 12)
                Signalkarta(spinning: true)
                Spacer().frame(height: 40)
                Text("Hämtar signaler…").titleStyle()
                Spacer().frame(height: 8)
                Text("\(signals.count) enheter · \(houses) hus hittills").smallStyle()
                Spacer().frame(height: 32)
                VStack(spacing: 0) {
                    ForEach(signals.prefix(4)) { signal in
                        Enhetsrad(enhet: names[signal.id] ?? "Okänd enhet", varde: Astrology.dbm(signal.rssi))
                    }
                }
                .overlay(alignment: .top) { Rectangle().fill(Theme.line).frame(height: 1) }
                .frame(height: 185, alignment: .top)
                Spacer(minLength: 12)
            }
            .padding(.horizontal, Theme.gutter)
            .padding(.top, 20)
        }
        .onAppear {
            startedAt = Date()
            scanner.start()
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.duration) {
                guard !finished else { return }
                finished = true
                store.set(Astrologer.read(scanner.currentSignals))
                done()
            }
        }
    }
}

/// Skärm 5 · Tar fram din guide.
struct ConsultingScreen: View {
    let weighing: String
    let done: () -> Void
    @Environment(MotionWatcher.self) private var motion

    static let duration: TimeInterval = 2.8
    @State private var progress: CGFloat = 0
    @State private var timeIsUp = false
    @State private var finished = false

    /// Guiden visas när tiden gått och telefonen ligger med skärmen uppåt.
    private func finishIfReady() {
        guard timeIsUp, !motion.isFaceDown, !finished else { return }
        finished = true
        done()
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("KONSULTERAR SIGNALERNA")
                .labelStyle(Theme.faint)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 12)
            Signalkarta(spinning: true)
            Spacer().frame(height: 40)
            Text("Tar fram din guide…").titleStyle()
            Spacer().frame(height: 8)
            Text(weighing).smallStyle()
            Spacer().frame(height: 32)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Theme.line)
                    Rectangle().fill(Theme.accent).frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 1)
            Spacer(minLength: 12)
        }
        .padding(.horizontal, Theme.gutter)
        .padding(.top, 20)
        .onAppear {
            withAnimation(.easeInOut(duration: Self.duration)) { progress = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.duration + 0.2) {
                timeIsUp = true
                finishIfReady()
            }
        }
        .onChange(of: motion.isFaceDown) { _, _ in finishIfReady() }
    }
}
