import SwiftUI
import UIKit

// MARK: Step sheet

/// Glass bottom sheet for a guide step: segmented progress, step count and
/// time, title, body and an inline caution.
struct DLStepSheet: View {
    let step: Int
    let total: Int
    let time: String
    let title: String
    let text: String
    var caution: String? = nil
    @Environment(\.vehicleTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Capsule()
                .fill(DL.lineStrong)
                .frame(width: 36, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 14)
                .accessibilityHidden(true)

            HStack(spacing: 3) {
                ForEach(0..<total, id: \.self) { i in
                    Capsule()
                        .fill(i < step - 1 ? DL.ink : (i == step - 1 ? theme.accent : DL.lineStrong))
                        .frame(height: 3)
                        .shadow(color: i == step - 1 ? theme.accent : .clear, radius: 4)
                }
            }
            .accessibilityHidden(true)

            HStack {
                DLLabel(String(format: "Step %02d / %02d", step, total))
                Spacer()
                DLLabel(time)
            }
            .padding(.top, 12)

            Text(title)
                .font(DLFont.sheetTitle)
                .tracking(-0.8)
                .padding(.top, 6)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel("Step \(step) of \(total): \(title)")

            Text(text)
                .font(DLFont.body)
                .lineSpacing(3)
                .foregroundStyle(DL.ink2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)

            if let caution {
                HStack(alignment: .top, spacing: 10) {
                    DLIcon.caution.image
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(DL.due)
                        .padding(.top, 1)
                    Text(caution)
                        .font(DLFont.callout)
                        .foregroundStyle(DL.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: Radius.m, style: .continuous)
                        .fill(DL.due.opacity(0.10))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.m, style: .continuous)
                        .strokeBorder(DL.due.opacity(0.22), lineWidth: 1)
                )
                .padding(.top, 14)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Caution: \(caution)")
            }
        }
        .overlay(alignment: .top) {
            Rectangle().fill(DL.chromeLine).frame(height: 1).padding(.horizontal, 4).offset(y: -10)
        }
    }
}

// MARK: Swipe to confirm

/// Slide a glass marble across to confirm a physical step is done.
/// VoiceOver users get a single "confirm" action instead of the drag.
struct DLSwipe: View {
    let label: String
    var doneLabel: String = "Done"
    let onComplete: () -> Void

    @State private var offset: CGFloat = 0
    @State private var done = false
    @Environment(\.vehicleTheme) private var theme

    private let height: CGFloat = 64
    private let knob: CGFloat = 54
    private let inset: CGFloat = 5

    var body: some View {
        GeometryReader { geo in
            track(travel: max(0, geo.size.width - knob - inset * 2))
        }
        .frame(height: height)
    }

    private func track(travel: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            fill
            labelText(progress: travel > 0 ? offset / travel : 0)
            knobView(travel: travel)
        }
        .frame(height: height)
        .dlGlass(.card, in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(done ? doneLabel : label)
        .accessibilityHint("Confirms this step is done")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { complete(travel: travel) }
    }

    private var fill: some View {
        let gradient = LinearGradient(
            colors: [theme.accent.opacity(0.18), theme.accent.opacity(0.62)],
            startPoint: .leading,
            endPoint: .trailing
        )
        let width: CGFloat = offset + knob + inset * 2
        return Capsule()
            .fill(gradient)
            .frame(width: width)
            .opacity(offset > 0 ? 1 : 0)
    }

    private func labelText(progress: CGFloat) -> some View {
        let fade: Double = done ? 1 : 1 - Double(progress) * 0.8
        return Text(done ? doneLabel : label)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(done ? DL.ink : DL.ink2)
            .opacity(fade)
            .frame(maxWidth: .infinity)
            .padding(.leading, 40)
    }

    private func knobView(travel: CGFloat) -> some View {
        let icon: DLIcon = done ? .check : .arrow
        let x: CGFloat = inset + offset
        return Color.clear
            .frame(width: knob, height: knob)
            .dlGlass(.orb, in: Circle())
            .overlay {
                icon.image
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(FB.black900)
            }
            .offset(x: x)
            .gesture(drag(travel: travel))
    }

    private func drag(travel: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard !done else { return }
                offset = min(max(0, value.translation.width), travel)
            }
            .onEnded { _ in
                guard !done else { return }
                if offset > travel * 0.8 {
                    complete(travel: travel)
                } else {
                    withAnimation(Motion.standard) { offset = 0 }
                }
            }
    }

    private func complete(travel: CGFloat) {
        guard !done else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(Motion.standard) {
            offset = travel
            done = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            onComplete()
        }
    }
}

// MARK: Tab bar

enum DLTab: String, CaseIterable, Identifiable {
    case care, guides, history, car
    var id: String { rawValue }

    var title: String {
        switch self {
        case .care: "Care"
        case .guides: "Guides"
        case .history: "History"
        case .car: "Car"
        }
    }

    var icon: DLIcon {
        switch self {
        case .care: .care
        case .guides: .guides
        case .history: .history
        case .car: .car
        }
    }
}

/// Floating glass pill. The active tab is prime glass with its label.
struct DLTabBar: View {
    @Binding var selection: DLTab
    @Namespace private var pill

    var body: some View {
        HStack(spacing: 2) {
            ForEach(DLTab.allCases) { tab in
                let on = tab == selection
                Button {
                    withAnimation(Motion.standard) { selection = tab }
                } label: {
                    HStack(spacing: 8) {
                        tab.icon.image.font(.system(size: 19, weight: .medium))
                        if on {
                            Text(tab.title).font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .foregroundStyle(on ? DL.ink : DL.ink2)
                    .padding(.horizontal, on ? 20 : 16)
                    .frame(minWidth: 56, minHeight: 52)
                    .background {
                        if on {
                            Capsule()
                                .fill(.clear)
                                .dlGlass(.prime, in: Capsule())
                                .matchedGeometryEffect(id: "pill", in: pill)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(on ? [.isSelected] : [])
            }
        }
        .padding(6)
        .dlGlass(.control, in: Capsule())
    }
}
