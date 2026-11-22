import SwiftUI

/// One guide step: a 2D view that dollies into the spot on the car, and a
/// glass sheet with the instruction and a swipe to confirm.
/// The RealityKit 3D scene replaces the 2D view later, same layout.
struct GuideStepView: View {
    let guide: Guide
    let vehicle: Vehicle
    let index: Int
    let onClose: () -> Void
    let onBack: () -> Void
    let onNext: () -> Void

    private var step: GuideStep { guide.steps[index] }

    var body: some View {
        DLScreen {
            VStack(spacing: 0) {
                StepViewport(imageName: vehicle.heroImageName, step: step)
                    .frame(height: 430)
                Spacer(minLength: 0)
            }
            .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                Spacer(minLength: 0)
                VStack(spacing: 14) {
                    DLStepSheet(
                        step: index + 1,
                        total: guide.steps.count,
                        time: step.minutes.map { "~\($0) min" } ?? "",
                        title: step.title,
                        text: step.body,
                        caution: step.caution
                    )
                    DLSwipe(label: step.confirm, doneLabel: index + 1 == guide.steps.count ? "Done. Clean up" : "Done. Next step", onComplete: onNext)
                    Button(action: onBack) {
                        Text(index == 0 ? "Back to overview" : "Previous step")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(DL.ink3)
                            .frame(minHeight: 44)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Space.gutter)
                .padding(.top, 10)
                .padding(.bottom, 4)
                .background {
                    UnevenRoundedRectangle(topLeadingRadius: Radius.sheet, topTrailingRadius: Radius.sheet, style: .continuous)
                        .fill(Color(hex: 0x0E1218, opacity: 0.70))
                        .dlGlass(.control, in: UnevenRoundedRectangle(topLeadingRadius: Radius.sheet, topTrailingRadius: Radius.sheet, style: .continuous))
                        .ignoresSafeArea(edges: .bottom)
                }
            }
        }
        .overlay(alignment: .topLeading) {
            DLIconButton(icon: .close, label: "Close guide", action: onClose)
                .padding(.leading, 16)
                .padding(.top, 8)
        }
    }
}

/// The 2D step scene: Astrid's photo, zoomed so the step's spot sits in the
/// middle, with a pulsing marker and a label.
private struct StepViewport: View {
    let imageName: String
    let step: GuideStep

    @State private var zoomed = false
    @State private var pulse = false
    @Environment(\.vehicleTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let aspect: CGFloat = 559.0 / 1440.0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let target = CGPoint(x: w / 2, y: h * 0.52)
            let scale: CGFloat = zoomed ? 2.6 : 1.7
            let imageWidth = w * scale
            let imageHeight = imageWidth * aspect

            ZStack {
                EllipticalGradient(colors: [theme.accentGlow, .clear], center: .center, endRadiusFraction: 0.5)
                    .frame(width: w * 1.6, height: h * 0.9)
                    .position(target)

                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageWidth, height: imageHeight)
                    .position(
                        x: target.x - (step.focus.x - 0.5) * imageWidth,
                        y: target.y - (step.focus.y - 0.5) * imageHeight
                    )
                    .opacity(step.isHidden ? 0.55 : 0.95)

                // Fade into the sheet and the status bar.
                LinearGradient(
                    stops: [
                        .init(color: DL.bg.opacity(0.7), location: 0),
                        .init(color: .clear, location: 0.22),
                        .init(color: .clear, location: 0.70),
                        .init(color: DL.bg, location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                marker.position(target)
            }
            .clipped()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Picture: \(step.focusLabel)\(step.isHidden ? ", hidden from this view" : "")")
        .onAppear {
            if reduceMotion {
                zoomed = true
            } else {
                withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.9)) { zoomed = true }
                withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false)) { pulse = true }
            }
        }
    }

    private var marker: some View {
        ZStack {
            Circle()
                .stroke(theme.accent, style: StrokeStyle(lineWidth: 1.5, dash: step.isHidden ? [4, 4] : []))
                .frame(width: 64, height: 64)
                .scaleEffect(pulse ? 1.5 : 0.8)
                .opacity(pulse ? 0 : 0.9)
            Circle()
                .stroke(theme.accent.opacity(0.8), style: StrokeStyle(lineWidth: 1.5, dash: step.isHidden ? [4, 4] : []))
                .frame(width: 44, height: 44)
            Circle()
                .fill(theme.accent)
                .frame(width: 12, height: 12)
                .shadow(color: theme.accent, radius: 8)
        }
        .overlay(alignment: .bottom) {
            VStack(spacing: 2) {
                Text(step.focusLabel)
                    .font(.system(size: 12.5, weight: .semibold))
                if step.isHidden {
                    Text("Hidden in this view")
                        .font(.system(size: 11))
                        .foregroundStyle(DL.ink2)
                }
            }
            .fixedSize()
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .dlGlass(.control, in: Capsule())
            .offset(y: 52)
        }
    }
}
