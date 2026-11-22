import SwiftUI

/// The one material in Fastback v3: translucent, blurred, saturated glass with
/// a chrome rim that catches light top-left and bottom-right, plus a soft
/// specular highlight on top. Mirrors `.dl-lg` and its variants in tokens.css.
enum GlassWeight {
    /// Quiet glass for cards and lists.
    case card
    /// Default glass for controls (icon buttons, chips, the tab bar).
    case control
    /// Brightest clear glass for the main action on a screen.
    case prime
    /// The car's accent, for "you are here" and done states.
    case tint
    /// A glass marble for knobs and toggles.
    case orb
}

struct LiquidGlass<S: InsettableShape>: ViewModifier {
    let weight: GlassWeight
    let shape: S
    @Environment(\.vehicleTheme) private var theme

    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    // Blur and saturation of what sits behind.
                    if weight != .orb {
                        shape.fill(.ultraThinMaterial)
                    }
                    shape.fill(fill)
                    if weight != .orb {
                        specular
                    }
                }
                .compositingGroup()
                .shadow(color: shadowColor, radius: shadowRadius, y: shadowY)
                .shadow(color: bloomColor, radius: 20)
            }
            .overlay {
                shape
                    .strokeBorder(rim, lineWidth: 1)
                    .allowsHitTesting(false)
            }
            .overlay {
                // Inner top highlight (inset 0 1px 1px).
                shape
                    .inset(by: 0.5)
                    .stroke(
                        LinearGradient(
                            stops: [
                                .init(color: .white.opacity(innerHighlight), location: 0),
                                .init(color: .clear, location: 0.18)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
                    .allowsHitTesting(false)
            }
    }

    // MARK: Layers

    private var fill: AnyShapeStyle {
        switch weight {
        case .card:
            AnyShapeStyle(LinearGradient(colors: [.white.opacity(0.075), .white.opacity(0.025)], startPoint: .top, endPoint: .bottom))
        case .control:
            AnyShapeStyle(LinearGradient(colors: [.white.opacity(0.13), .white.opacity(0.04)], startPoint: .top, endPoint: .bottom))
        case .prime:
            AnyShapeStyle(LinearGradient(
                stops: [
                    .init(color: .white.opacity(0.30), location: 0),
                    .init(color: .white.opacity(0.10), location: 0.55),
                    .init(color: theme.accentHi.opacity(0.16), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            ))
        case .tint:
            AnyShapeStyle(LinearGradient(colors: [theme.accent.opacity(0.55), theme.accentDeep.opacity(0.30)], startPoint: .top, endPoint: .bottom))
        case .orb:
            AnyShapeStyle(RadialGradient(
                stops: [
                    .init(color: .white.opacity(0.85), location: 0),
                    .init(color: .white.opacity(0.32), location: 0.26),
                    .init(color: theme.accentHi.opacity(0.14), location: 0.62),
                    .init(color: .white.opacity(0.22), location: 1)
                ],
                center: UnitPoint(x: 0.34, y: 0.28),
                startRadius: 0,
                endRadius: 40
            ))
        }
    }

    /// Soft highlight across the top 45%.
    private var specular: some View {
        shape
            .fill(LinearGradient(
                colors: [.white.opacity(specularOpacity), .clear],
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.45)
            ))
            .padding(.horizontal, 6)
            .padding(.top, 1)
            .allowsHitTesting(false)
    }

    /// Chrome rim: bright top-left, quiet middle, blue-tinted then bright bottom-right.
    private var rim: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .white.opacity(weight == .card ? 0.45 : 0.75), location: 0),
                .init(color: .white.opacity(0.12), location: 0.28),
                .init(color: .white.opacity(0), location: 0.52),
                .init(color: theme.accentHi.opacity(0.30), location: 0.80),
                .init(color: .white.opacity(weight == .card ? 0.35 : 0.55), location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var specularOpacity: Double {
        switch weight {
        case .card: 0.07
        case .prime: 0.34
        default: 0.16
        }
    }

    private var innerHighlight: Double {
        switch weight {
        case .prime, .orb: 0.65
        case .tint: 0.55
        case .card: 0.10
        case .control: 0.30
        }
    }

    private var shadowColor: Color {
        .black.opacity(weight == .card ? 0.30 : 0.40)
    }

    private var shadowRadius: CGFloat {
        switch weight {
        case .card: 20
        case .orb: 11
        default: 17
        }
    }

    private var shadowY: CGFloat {
        switch weight {
        case .card: 18
        case .orb: 8
        default: 14
        }
    }

    private var bloomColor: Color {
        switch weight {
        case .prime: theme.accent.opacity(0.22)
        case .tint: theme.accent.opacity(0.25)
        default: .clear
        }
    }
}

extension View {
    func dlGlass<S: InsettableShape>(_ weight: GlassWeight = .control, in shape: S) -> some View {
        modifier(LiquidGlass(weight: weight, shape: shape))
    }

    func dlGlass(_ weight: GlassWeight = .card, cornerRadius: CGFloat) -> some View {
        modifier(LiquidGlass(weight: weight, shape: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)))
    }
}
