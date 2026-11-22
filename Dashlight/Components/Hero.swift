import SwiftUI

/// A status point pinned to a spot on the car photo.
struct HeroSpot: Identifiable {
    let id: String
    let name: String
    /// Position on the image, 0...1.
    let point: CGPoint
    let status: ServiceStatus
    var showsTag: Bool = false
}

/// Hero car: the real photo cutout with a reflection, floor glow, a chrome
/// floor line and glowing status points. Per vehicle: photo and spots.
struct DLHero: View {
    let imageName: String
    let carName: String
    var spots: [HeroSpot] = []
    var height: CGFloat = 240
    var onSelect: (HeroSpot) -> Void = { _ in }

    @Environment(\.vehicleTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Cutout aspect ratio (1440 x 559).
    private let aspect: CGFloat = 559.0 / 1440.0

    var body: some View {
        GeometryReader { geo in
            let carWidth = geo.size.width - 30
            let carHeight = carWidth * aspect
            let carTop = max(10, (height - carHeight) / 2 - 6)

            ZStack(alignment: .topLeading) {
                // Accent glow behind the car
                EllipticalGradient(
                    stops: [
                        .init(color: theme.accentGlow, location: 0),
                        .init(color: theme.accent.opacity(0.06), location: 0.55),
                        .init(color: .clear, location: 0.75)
                    ],
                    center: .center
                )
                .frame(width: geo.size.width * 1.45, height: 200)
                .position(x: geo.size.width / 2, y: carTop + 70)

                // Floor shadow
                EllipticalGradient(colors: [.black.opacity(0.85), .clear], center: .center, endRadiusFraction: 0.35)
                    .frame(width: geo.size.width - 60, height: 26)
                    .position(x: geo.size.width / 2, y: carTop + carHeight - 14)

                // Chrome floor line
                Rectangle()
                    .fill(DL.chromeLine)
                    .frame(width: geo.size.width - 80, height: 1)
                    .opacity(0.55)
                    .position(x: geo.size.width / 2, y: carTop + carHeight - 4)

                // Car and reflection
                VStack(spacing: -8) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: carWidth)
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: carWidth)
                        .scaleEffect(x: 1, y: -1)
                        .opacity(0.18)
                        .mask {
                            LinearGradient(stops: [.init(color: .black, location: 0), .init(color: .clear, location: 0.42)], startPoint: .top, endPoint: .bottom)
                        }
                        .accessibilityHidden(true)
                }
                .offset(x: 15, y: carTop)
                .accessibilityHidden(true)

                // Status points
                ForEach(spots) { spot in
                    Button { onSelect(spot) } label: {
                        HeroSpotView(spot: spot, animate: !reduceMotion)
                    }
                    .buttonStyle(.plain)
                    .position(x: 15 + carWidth * spot.point.x, y: carTop + carHeight * spot.point.y)
                    .accessibilityLabel("\(spot.name), \(spot.status.word)")
                }
            }
        }
        .frame(height: height)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Photo of \(carName)")
    }
}

private struct HeroSpotView: View {
    let spot: HeroSpot
    let animate: Bool
    @State private var pulse = false

    var body: some View {
        ZStack {
            if spot.status.needsAttention {
                Circle()
                    .stroke(spot.status.color, lineWidth: 1.5)
                    .frame(width: 24, height: 24)
                    .scaleEffect(pulse ? 1.9 : 0.6)
                    .opacity(pulse ? 0 : 0.9)
            }
            Circle()
                .fill(spot.status.color)
                .frame(width: 10, height: 10)
                .background(Circle().fill(FB.black950.opacity(0.65)).frame(width: 16, height: 16))
                .shadow(color: spot.status.color, radius: 7)
        }
        .frame(width: 44, height: 44)
        .contentShape(Circle())
        .overlay(alignment: .top) {
            if spot.showsTag {
                Text(spot.name)
                    .font(.system(size: 11.5, weight: .semibold))
                    .fixedSize()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .dlGlass(.control, in: Capsule())
                    .offset(y: -24)
            }
        }
        .onAppear {
            guard animate, spot.status.needsAttention else { return }
            withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 1.8).repeatForever(autoreverses: false)) {
                pulse = true
            }
        }
    }
}
