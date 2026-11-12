import SwiftUI
import CoreText

/// Alla färger, typsnitt och mått på ett ställe, hämtade från Figma
/// ("Carpe Signum – första utkast"). Ändra här när designen ändras.
enum Theme {
    // Färger (Figma-variabler color/…)
    static let background = Color(hex: 0x0A0A0B)  // color/bg
    static let surface = Color(hex: 0x141416)     // color/surface
    static let line = Color(hex: 0x2A2A2E)        // color/line
    static let accent = Color(hex: 0xBCA7FF)      // color/accent (ljuslila)
    static let action = Color(hex: 0x311098)      // color/action (knappar, ikryssade rutor)
    static let text = Color(hex: 0xECE8DF)        // color/text
    static let muted = Color(hex: 0xDBD8DE)       // color/muted
    static let faint = Color(hex: 0x898681)       // color/faint

    static let gutter: CGFloat = 32

    // Typsnitt. Designen använder Geist Mono (i mappen Fonts) och Geist för
    // brödtext. Istället för Geist används systemets typsnitt, som är mycket likt.
    // Kibernetyk Mono Medium används för citat och underrubriker.
    static let monoFamily = "Geist Mono"
    static let kibernetykName = "KibernetykMono-Medium"
    static let kibernetykRegularName = "KibernetykMono-Regular"

    static func kibernetyk(_ size: CGFloat, regular: Bool = false) -> Font {
        let name = regular ? kibernetykRegularName : kibernetykName
        return Fonts.available(name) ? .custom(name, fixedSize: size) : mono(size, regular ? .regular : .medium)
    }

    static func mono(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        if Fonts.available(monoFamily) {
            return .custom(monoFamily, fixedSize: size).weight(weight)
        }
        return .system(size: size, weight: weight, design: .monospaced)
    }

    static func sans(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }
}

/// Textstilar från Figma: Mono/Label, Mono/Title osv.
extension View {
    /// Mono/Label: 11 pt, versaler, spärrad 12 %.
    func labelStyle(_ color: Color = Theme.muted) -> some View {
        font(Theme.mono(11)).tracking(1.32).textCase(.uppercase).foregroundStyle(color)
    }
    /// Mono/Title: Kibernetyk Mono Regular 24 pt.
    func titleStyle() -> some View {
        font(Theme.kibernetyk(24, regular: true)).tracking(-0.24).lineSpacing(1).foregroundStyle(Theme.text)
    }
    /// Mono/Small: 12 pt Light.
    func smallStyle(_ color: Color = Theme.muted) -> some View {
        font(Theme.mono(12, .light)).lineSpacing(2).foregroundStyle(color)
    }
    /// Mono/Body: 14 pt.
    func bodyStyle(_ color: Color = Theme.text) -> some View {
        font(Theme.mono(14)).lineSpacing(3).foregroundStyle(color)
    }
    /// Reading: Geist Light 16 pt (systemets typsnitt).
    func readingStyle() -> some View {
        font(Theme.sans(15, .light)).lineSpacing(0).foregroundStyle(Theme.text)
    }
    /// Accent: Kibernetyk Mono Medium 14 pt.
    func accentStyle(_ color: Color = Theme.accent) -> some View {
        font(Theme.kibernetyk(14)).tracking(-0.14).lineSpacing(5).foregroundStyle(color)
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
}

/// Laddar typsnittsfiler som ligger i appen.
enum Fonts {
    private static var registered = false
    private static var names: Set<String> = []

    static func registerBundled() {
        guard !registered else { return }
        registered = true
        let urls = (Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? [])
            + (Bundle.main.urls(forResourcesWithExtension: "otf", subdirectory: nil) ?? [])
        for url in urls {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
        for family in UIFont.familyNames {
            names.insert(family)
            UIFont.fontNames(forFamilyName: family).forEach { names.insert($0) }
        }
    }

    static func available(_ name: String) -> Bool {
        registerBundled()
        return names.contains(name)
    }
}

extension Date {
    /// "ONS 11 NOV"
    var swedishShortDay: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "sv_SE")
        formatter.dateFormat = "EEE d MMM"
        return formatter.string(from: self).replacingOccurrences(of: ".", with: "").uppercased()
    }

    /// "ONSDAG 11 NOVEMBER"
    var swedishDayHeader: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "sv_SE")
        formatter.dateFormat = "EEEE d MMMM"
        return formatter.string(from: self).uppercased()
    }
}

// MARK: Komponenter från Figma

/// Komponent "Knapp", varianterna Primär och Kontur.
struct Knapp: View {
    enum Variant { case primar, kontur }
    let etikett: String
    var variant: Variant = .primar
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(etikett.uppercased())
                .font(Theme.mono(14, .medium))
                .tracking(1.12)
                .foregroundStyle(Theme.text)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background {
                    if variant == .primar {
                        RoundedRectangle(cornerRadius: 24).fill(Theme.action)
                    } else {
                        RoundedRectangle(cornerRadius: 24).stroke(Theme.line, lineWidth: 1)
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Komponent "Datachip".
struct Datachip: View {
    let text: String
    var body: some View {
        Text(text)
            .labelStyle(Theme.faint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Theme.line, lineWidth: 1))
    }
}

/// Komponent "Enhetsrad".
struct Enhetsrad: View {
    let enhet: String
    let varde: String
    var body: some View {
        HStack(spacing: 12) {
            Image("IkonPunkt").resizable().frame(width: 6, height: 6)
            Text(enhet).bodyStyle().lineLimit(1)
            Spacer(minLength: 8)
            Text(varde).labelStyle()
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) { Rectangle().fill(Theme.line).frame(height: 1) }
    }
}

/// Komponent "Signalkarta". Snurrar sakta när kosmos arbetar.
struct Signalkarta: View {
    var spinning = false
    var size: CGFloat = 326
    @State private var angle: Double = 0

    var body: some View {
        Image("Signalkarta")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size * 261.972 / 260)
            .rotationEffect(.degrees(angle), anchor: UnitPoint(x: 0.5, y: 130 / 261.972))
            .onAppear {
                guard spinning else { return }
                withAnimation(.linear(duration: 24).repeatForever(autoreverses: false)) { angle = 360 }
            }
    }
}

/// Lägger barn på rader som bryts, som ordbrytning.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, maxX: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > 0, x + size.width > width {
                x = 0; y += rowHeight + spacing; rowHeight = 0
            }
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxX, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX; y += rowHeight + spacing; rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
