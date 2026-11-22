import SwiftUI

/// One guide step: a live 3D scene (or the 2D photo) that dollies to the spot
/// on the car, and a glass sheet with the instruction and a swipe to confirm.
struct GuideStepView: View {
    let guide: Guide
    let vehicle: Vehicle
    let index: Int
    let onClose: () -> Void
    let onBack: () -> Void
    let onNext: () -> Void

    @State private var show3D = true
    @State private var xRay = false
    @State private var recenterToken = 0
    @Environment(\.vehicleTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var step: GuideStep { guide.steps[index] }

    var body: some View {
        DLScreen {
            VStack(spacing: 0) {
                viewport
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
        .overlay(alignment: .topTrailing) {
            sceneControls
                .padding(.trailing, 16)
                .padding(.top, 8)
        }
        .onAppear { xRay = step.part.needsXRay }
        .onChange(of: index) { xRay = step.part.needsXRay }
    }

    @ViewBuilder
    private var viewport: some View {
        if show3D {
            ZStack(alignment: .bottom) {
                GuideSceneView(
                    part: step.part,
                    xRay: xRay,
                    showsRamps: guide.kind == .oil,
                    recenterToken: recenterToken,
                    reduceMotion: reduceMotion,
                    accent: UIColor(theme.accent)
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("3D view: \(step.focusLabel). Drag to turn the car.")

                LinearGradient(colors: [.clear, DL.bg], startPoint: .top, endPoint: .bottom)
                    .frame(height: 90)
                    .allowsHitTesting(false)

                partChip
                    .padding(.bottom, 96)
            }
            .transition(.opacity)
        } else {
            StepViewport(imageName: vehicle.heroImageName, step: step)
                .id(index)
                .transition(.opacity)
        }
    }

    private var partChip: some View {
        HStack(spacing: 6) {
            Circle().fill(theme.accent).frame(width: 7, height: 7)
            Text(step.focusLabel)
                .font(.system(size: 12.5, weight: .semibold))
            if xRay {
                Text("X-ray")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(DL.ink2)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .dlGlass(.control, in: Capsule())
        .allowsHitTesting(false)
    }

    private var sceneControls: some View {
        HStack(spacing: 8) {
            if show3D {
                sceneButton(symbol: "viewfinder", label: "Recenter", on: false) {
                    recenterToken += 1
                }
                sceneButton(symbol: "eye.trianglebadge.exclamationmark", label: xRay ? "X-ray on" : "X-ray off", on: xRay) {
                    xRay.toggle()
                }
            }
            sceneButton(symbol: show3D ? "photo" : "cube", label: show3D ? "Show photo" : "Show 3D", on: false) {
                withAnimation(reduceMotion ? nil : Motion.standard) { show3D.toggle() }
            }
        }
    }

    private func sceneButton(symbol: String, label: String, on: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(on ? theme.accent : DL.ink)
                .frame(width: 44, height: 44)
                .dlGlass(.control, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
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
