import SwiftUI

// One family (SF Pro), two cuts. Mono caps labels are the only second cut.
enum DLFont {
    /// 64–88 pt Light. One per screen.
    static func numeral(_ size: CGFloat = 68) -> Font {
        .system(size: size, weight: .light).monospacedDigit()
    }
    /// 34–46 pt Semibold screen titles.
    static func title(_ size: CGFloat = 36) -> Font {
        .system(size: size, weight: .semibold)
    }
    static let section = Font.system(size: 20, weight: .semibold)
    static let sheetTitle = Font.system(size: 25, weight: .semibold)
    static let rowTitle = Font.system(size: 15.5, weight: .medium)
    static let body = Font.system(size: 15)
    static let callout = Font.system(size: 13)
    static let caption = Font.system(size: 12.5)
    static let button = Font.system(size: 16, weight: .semibold)
    /// 10.5 pt mono caps label.
    static let label = Font.system(size: 10.5, weight: .medium, design: .monospaced)
}

extension View {
    /// Title tracking used on the canvas (letter-spacing about -0.035em).
    func dlTitleTracking(_ size: CGFloat) -> some View {
        tracking(-size * 0.035)
    }
}

/// Mono caps eyebrow label, e.g. "GUIDE 01 · UNDER THE HOOD".
struct DLLabel: View {
    let text: String
    var color: Color = DL.ink3

    init(_ text: String, color: Color = DL.ink3) {
        self.text = text
        self.color = color
    }

    var body: some View {
        Text(text.uppercased())
            .font(DLFont.label)
            .tracking(1.4)
            .foregroundStyle(color)
    }
}

/// Chrome-gradient text for the one big number or title on a screen.
struct ChromeText: View {
    let text: String
    let font: Font
    var tracking: CGFloat = 0

    var body: some View {
        Text(text)
            .font(font)
            .tracking(tracking)
            .foregroundStyle(DL.chromeText)
    }
}
