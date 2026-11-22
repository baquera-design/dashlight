import SwiftUI

// Fastback v3 · "Night garage" + liquid glass.
// Mirrors tokens.css on the design canvas, in the same three layers:
//   1. Raw paint (FB)       never used directly by components
//   2. Semantic roles (DL)  what components use
//   3. Vehicle theme        each car brings its own accent, glow and photo

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

// MARK: 1. Raw paint

enum FB {
    static let black1000 = Color(hex: 0x030405)
    static let black950 = Color(hex: 0x06080B)
    static let black900 = Color(hex: 0x0B0E12)
    static let black850 = Color(hex: 0x10141A)
    static let black800 = Color(hex: 0x161B22)
    static let black700 = Color(hex: 0x1F252E)
    static let silver100 = Color(hex: 0xF3F5F7)
    static let brittany200 = Color(hex: 0xCFE4EC)
    static let brittany400 = Color(hex: 0x8FB8C9)
    static let brittany600 = Color(hex: 0x4E7F95)
    static let amber = Color(hex: 0xF2B544)
    static let red = Color(hex: 0xFF5A47)
    static let green = Color(hex: 0x5ED19A)
    static let steel = Color(hex: 0x6B7581)
}

// MARK: 2. Semantic roles

enum DL {
    // Surfaces
    static let bg = FB.black950
    static let sheet = FB.black850
    static let surface = Color.white.opacity(0.045)
    static let surface2 = Color.white.opacity(0.08)

    // Ink
    static let ink = FB.silver100
    static let ink2 = FB.silver100.opacity(0.64)
    static let ink3 = FB.silver100.opacity(0.40)

    // Lines
    static let line = Color.white.opacity(0.08)
    static let lineStrong = Color.white.opacity(0.16)

    // Status: color always paired with a word
    static let ok = FB.green
    static let due = FB.amber
    static let overdue = FB.red
    static let unknown = FB.steel

    // Chrome type for the one big number or title per screen
    static let chromeText = LinearGradient(
        stops: [
            .init(color: .white, location: 0.35),
            .init(color: Color(hex: 0xEBF2F6, opacity: 0.62), location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // Hairline under sheets and the hero floor
    static let chromeLine = LinearGradient(
        stops: [
            .init(color: .clear, location: 0),
            .init(color: .white.opacity(0.55), location: 0.30),
            .init(color: FB.brittany200.opacity(0.35), location: 0.70),
            .init(color: .clear, location: 1)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: Spacing, radius, motion

enum Space {
    static let s1: CGFloat = 4
    static let s2: CGFloat = 8
    static let s3: CGFloat = 12
    static let s4: CGFloat = 16
    static let s5: CGFloat = 20
    static let s6: CGFloat = 32
    /// Screen side gutter
    static let gutter: CGFloat = 20
}

enum Radius {
    static let s: CGFloat = 10
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let sheet: CGFloat = 28
}

enum Motion {
    /// cubic-bezier(0.2, 0.8, 0.2, 1), 450 ms
    static let standard = Animation.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.45)
    static let quick = Animation.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.25)

    /// Reduce Motion swaps movement for a crossfade.
    static func standard(reduced: Bool) -> Animation {
        reduced ? .easeInOut(duration: 0.2) : standard
    }
}

// MARK: 3. Vehicle theme

struct VehicleTheme: Equatable {
    var accent: Color
    var accentHi: Color
    var accentDeep: Color
    var accentInk: Color
    var accentGlow: Color

    /// Astrid: white sedan, Brittany Blue.
    static let astrid = VehicleTheme(
        accent: FB.brittany400,
        accentHi: FB.brittany200,
        accentDeep: FB.brittany600,
        accentInk: FB.black950,
        accentGlow: FB.brittany400.opacity(0.30)
    )
}

private struct VehicleThemeKey: EnvironmentKey {
    static let defaultValue = VehicleTheme.astrid
}

extension EnvironmentValues {
    var vehicleTheme: VehicleTheme {
        get { self[VehicleThemeKey.self] }
        set { self[VehicleThemeKey.self] = newValue }
    }
}

// MARK: Status

enum ServiceStatus: String, CaseIterable {
    case ok, due, overdue, unknown

    var color: Color {
        switch self {
        case .ok: DL.ok
        case .due: DL.due
        case .overdue: DL.overdue
        case .unknown: DL.unknown
        }
    }

    /// The word that always travels with the color.
    var word: String {
        switch self {
        case .ok: "Good"
        case .due: "Due"
        case .overdue: "Overdue"
        case .unknown: "Not logged"
        }
    }

    var needsAttention: Bool { self == .due || self == .overdue }
}
