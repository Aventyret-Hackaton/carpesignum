import SwiftUI

@main
struct CarpeSignumApp: App {
    @State private var scanner = SignalScanner()
    @State private var store = ReadingStore()
    @State private var motion = MotionWatcher()
    @State private var weather = WeatherOracle()

    init() { Fonts.registerBundled() }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(scanner)
                .environment(store)
                .environment(motion)
                .environment(weather)
                .preferredColorScheme(.dark)
                .onAppear { scanner.start(); motion.start() }
        }
    }
}

enum Tab { case horoscope, guide }

/// Var i flödet vi är. Skärmnumren följer Figma.
enum Phase: Equatable {
    case start          // Skärm 1 · Första gången
    case scanning       // Skärm 2 · Hämtar signaler
    case main(Tab)      // Skärm 3 · Dagens horoskop / Skärm 6 · Guide
    case consulting     // Skärm 5 · Tar fram din guide
}

struct ContentView: View {
    @Environment(ReadingStore.self) private var store
    @Environment(MotionWatcher.self) private var motion
    @AppStorage("hasSeenIntro") private var hasSeenIntro = false
    @State private var phase: Phase = .start

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            switch phase {
            case .start:
                StartScreen { hasSeenIntro = true; phase = .scanning }
                    .transition(.opacity)
            case .scanning:
                ScanningScreen { phase = .main(.horoscope) }
                    .transition(.opacity)
            case .consulting:
                ConsultingScreen(weighing: store.reading?.weighing ?? "") { phase = .main(.guide) }
                    .transition(.opacity)
            case .main(let tab):
                if let reading = store.reading {
                    VStack(spacing: 0) {
                        Group {
                            switch tab {
                            case .horoscope:
                                HoroscopeView(reading: reading,
                                              guideMe: { phase = .consulting },
                                              readAgain: { store.clear(); phase = .scanning })
                            case .guide:
                                GuideView(reading: reading)
                            }
                        }
                        .frame(maxHeight: .infinity)
                        Flikrad(tab: tab) { phase = .main($0) }
                    }
                    .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: phase)
        // Skärmen nedåt på horoskopet: konsultera signalerna.
        .onChange(of: motion.isFaceDown) { _, faceDown in
            if faceDown, phase == .main(.horoscope), store.reading != nil {
                phase = .consulting
            }
        }
        .onAppear {
            if store.reading != nil { phase = .main(.horoscope) }
            else if hasSeenIntro { phase = .scanning }
            else { phase = .start }
        }
    }
}

/// Komponent "Flikrad".
struct Flikrad: View {
    let tab: Tab
    let select: (Tab) -> Void

    var body: some View {
        HStack(spacing: 0) {
            item(.horoscope, icon: "IkonHoroskop", title: "HOROSKOP")
            item(.guide, icon: "IkonGuide", title: "GUIDE")
        }
        .frame(height: 72, alignment: .top)
        .padding(.bottom, 0)
        .background(Theme.background)
        .overlay(alignment: .top) { Rectangle().fill(Theme.line).frame(height: 1) }
    }

    private func item(_ value: Tab, icon: String, title: String) -> some View {
        let color = tab == value ? Theme.accent : Theme.faint
        return Button { select(value) } label: {
            VStack(spacing: 6) {
                Image(icon).renderingMode(.template).resizable().frame(width: 18, height: 18)
                Text(title).font(Theme.mono(11)).tracking(1.32)
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .padding(.top, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
