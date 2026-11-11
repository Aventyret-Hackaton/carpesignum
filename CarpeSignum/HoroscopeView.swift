import SwiftUI

/// Skärm 3 · Dagens horoskop.
struct HoroscopeView: View {
    let reading: Reading
    let guideMe: () -> Void
    let readAgain: () -> Void
    @Environment(SignalScanner.self) private var scanner
    @Environment(WeatherOracle.self) private var weather
    @State private var showBasis = false
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(reading.date.swedishDayHeader)
                            .labelStyle()
                            // Dolt reglage för demon: håll inne på datumet.
                            .onLongPressGesture(minimumDuration: 1.2) { showSettings = true }
                        Spacer()
                        Button { showBasis = true } label: {
                            Image("IkonForklaring").resizable().frame(width: 32, height: 32)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Så räknade vi")
                    }

                    Spacer().frame(height: 40)
                    Text("DAGENS HOROSKOP").labelStyle(Theme.accent)
                    Spacer().frame(height: 10)
                    Text(reading.headline)
                        .titleStyle()
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer().frame(height: 28)
                    ForEach(Array(reading.paragraphs.enumerated()), id: \.offset) { index, paragraph in
                        if index > 0 { Spacer().frame(height: 16) }
                        Text(paragraph)
                            .readingStyle()
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer().frame(height: 24)
                    // "Något dramatiskt"
                    Text(reading.quote)
                        .accentStyle()
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.leading, 18)
                        .overlay(alignment: .leading) { Rectangle().fill(Theme.accent).frame(width: 2) }

                    if let weather = weather.reading {
                        Spacer().frame(height: 24)
                        Text(weather.label).labelStyle(Theme.faint)
                        Spacer().frame(height: 6)
                        Text(weather.line)
                            .smallStyle()
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer().frame(height: 24)
                    FlowLayout(spacing: 8) {
                        ForEach(reading.chips, id: \.self) { Datachip(text: $0) }
                    }
                    Spacer().frame(height: 24)
                }
                .padding(.horizontal, Theme.gutter)
                .padding(.top, 20)
            }
            .scrollIndicators(.hidden)

            Knapp(etikett: "Guida mig rätt", action: guideMe)
                .padding(.horizontal, Theme.gutter)
            Text("ELLER LÄGG TELEFONEN MED SKÄRMEN NEDÅT")
                .labelStyle(Theme.faint)
                .padding(.top, 12)
                .padding(.bottom, 20)
        }
        .onAppear { weather.fetch() }
        .sheet(isPresented: $showBasis) {
            BasisSheet(reading: reading) { showBasis = false }
                .presentationDetents([.height(560)])
                .presentationBackground(Theme.surface)
                .presentationCornerRadius(0)
        }
        .confirmationDialog("Kosmos", isPresented: $showSettings) {
            Button("Läs signalerna igen", action: readAgain)
            Button(scanner.demoMode ? "Stäng av demoläge" : "Slå på demoläge") {
                scanner.demoMode.toggle()
            }
            Button("Avbryt", role: .cancel) {}
        } message: {
            Text(scanner.demoMode ? "Demoläget är på." : "Riktiga signaler används.")
        }
    }
}

/// Skärm 4 · Så räknade vi (arket som öppnas med frågetecknet).
struct BasisSheet: View {
    let reading: Reading
    let close: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle().fill(Theme.faint).frame(width: 32, height: 2)
                .frame(maxWidth: .infinity)
            Spacer().frame(height: 28)
            Text("SÅ RÄKNADE VI").labelStyle(Theme.accent)
            Spacer().frame(height: 10)
            Text("Underlaget för dagens horoskop")
                .titleStyle()
                .fixedSize(horizontal: false, vertical: true)
            Spacer().frame(height: 12)
            Text("Varje enhet du varit nära har vägts efter signalstyrka och tid. Ditt hus är rummet där signalen var starkast.")
                .smallStyle()
                .fixedSize(horizontal: false, vertical: true)
            Spacer().frame(height: 24)
            VStack(spacing: 0) {
                ForEach(reading.basis, id: \.self) { row in
                    Enhetsrad(enhet: row.name, varde: row.detail)
                }
            }
            .overlay(alignment: .top) { Rectangle().fill(Theme.line).frame(height: 1) }
            Spacer().frame(height: 28)
            Knapp(etikett: "Stäng", variant: .kontur, action: close)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, Theme.gutter)
        .padding(.top, 20)
        .padding(.bottom, 40)
        .overlay(alignment: .top) { Rectangle().fill(Theme.line).frame(height: 1) }
    }
}
