import SwiftUI
import CoreText

/// Alla färger, typsnitt och mått på ett ställe, hämtade från Figma
/// ("Carpe Signum – första utkast"). Ändra här när designen ändras.
enum Theme {
    // Färger (Figma-variabler color/…)
    static let background = Color(hex: 0x0A0A0B)  // color/bg
    static let surface = Color(hex: 0x141416)     // color/surface
    static let line = Color(hex: 0x2A2A2E)        // color/line
    static let accent = Color(hex: 0xD8B46A)      // color/accent
    static let onAccent = Color(hex: 0x0A0A0B)    // color/on-accent
    static let text = Color(hex: 0xECE8DF)        // color/text
    static let muted = Color(hex: 0x8C8981)       // color/muted
    static let faint = Color(hex: 0x55534E)       // color/faint

    static let gutter: CGFloat = 32

    // Typsnitt. Designen använder Geist Mono och Instrument Serif.
    // Om typsnittsfilerna finns i mappen Fonts används de, annars systemets
    // närmaste motsvarighet (SF Mono och New York).
    static let monoFamily = "Geist Mono"
    static let serifName = "InstrumentSerif-Regular"
    static let serifItalicName = "InstrumentSerif-Italic"

    static func mono(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        if Fonts.available(monoFamily) {
            return .custom(monoFamily, fixedSize: size).weight(weight)
        }
        return .system(size: size, weight: weight, design: .monospaced)
    }

    static func serif(_ size: CGFloat) -> Font {
        Fonts.available(serifName) ? .custom(serifName, fixedSize: size)
            : .system(size: size, weight: .regular, design: .serif)
    }

    static func serifItalic(_ size: CGFloat) -> Font {
        Fonts.available(serifItalicName) ? .custom(serifItalicName, fixedSize: size)
            : .system(size: size, weight: .regular, design: .serif).italic()
    }
}

/// Textstilar från Figma: Mono/Label, Mono/Title osv.
extension View {
    /// Mono/Label: 11 pt, spärrad 12 %.
    func labelStyle(_ color: Color = Theme.muted) -> some View {
        font(Theme.mono(11)).tracking(1.32).foregroundStyle(color)
    }
    /// Mono/Title: 28 pt Light.
    func titleStyle() -> some View {
        font(Theme.mono(28, .light)).tracking(-0.56).lineSpacing(28 * 0.2 - 4).foregroundStyle(Theme.text)
    }
    /// Mono/Small: 12 pt Light.
    func smallStyle(_ color: Color = Theme.muted) -> some View {
        font(Theme.mono(12, .light)).lineSpacing(2).foregroundStyle(color)
    }
    /// Mono/Body: 14 pt.
    func bodyStyle(_ color: Color = Theme.text) -> some View {
        font(Theme.mono(14)).lineSpacing(3).foregroundStyle(color)
    }
    /// Serif/Reading: 22 pt.
    func readingStyle() -> some View {
        font(Theme.serif(22)).lineSpacing(Fonts.available(Theme.serifName) ? 0 : 5).foregroundStyle(Theme.text)
    }
    /// Serif/Italic: 18 pt.
    func italicStyle(_ color: Color = Theme.muted) -> some View {
        font(Theme.serifItalic(18)).lineSpacing(Fonts.available(Theme.serifItalicName) ? 0 : 4).foregroundStyle(color)
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
                .foregroundStyle(variant == .primar ? Theme.onAccent : Theme.text)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background {
                    if variant == .primar {
                        RoundedRectangle(cornerRadius: 24).fill(Theme.accent)
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
            .font(Theme.mono(11))
            .tracking(1.32)
            .foregroundStyle(Theme.muted)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .overlay(RoundedRectangle(cornerRadius: 2).stroke(Theme.line, lineWidth: 1))
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
    @State private var angle: Double = 0

    var body: some View {
        Image("Signalkarta")
            .resizable()
            .scaledToFit()
            .frame(width: 260, height: 262)
            .rotationEffect(.degrees(angle), anchor: UnitPoint(x: 0.5, y: 130 / 262))
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
