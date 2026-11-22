import SwiftUI

/// Garage-black background with soft blue light pools for the glass to refract.
/// Mirrors `--dl-stage` in tokens.css.
struct DLStage: View {
    @Environment(\.vehicleTheme) private var theme

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                DL.bg
                pool(
                    stops: [(theme.accent.opacity(0.26), 0), (theme.accent.opacity(0.06), 0.5), (.clear, 0.75)],
                    center: CGPoint(x: w * 0.5, y: h * 0.24),
                    size: CGSize(width: w * 1.4, height: h * 0.68)
                )
                pool(
                    stops: [(Color(hex: 0x5678AA, opacity: 0.18), 0), (.clear, 0.7)],
                    center: CGPoint(x: w, y: h * 0.62),
                    size: CGSize(width: w * 1.2, height: h * 0.60)
                )
                pool(
                    stops: [(Color(hex: 0x7896AF, opacity: 0.14), 0), (.clear, 0.7)],
                    center: CGPoint(x: 0, y: h * 0.88),
                    size: CGSize(width: w * 1.1, height: h * 0.56)
                )
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private func pool(stops: [(Color, CGFloat)], center: CGPoint, size: CGSize) -> some View {
        EllipticalGradient(
            stops: stops.map { Gradient.Stop(color: $0.0, location: $0.1) },
            center: .center,
            startRadiusFraction: 0,
            endRadiusFraction: 0.5
        )
        .frame(width: size.width, height: size.height)
        .position(center)
    }
}

/// Screen container: stage behind, content on top.
struct DLScreen<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            DLStage()
            content
        }
        .foregroundStyle(DL.ink)
    }
}
