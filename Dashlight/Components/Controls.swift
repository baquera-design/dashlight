import SwiftUI

// MARK: Button

/// Pill button. Primary is the brightest glass on the screen; secondary is control glass.
struct DLButton: View {
    enum Variant { case primary, secondary }
    enum Size { case large, regular }

    let title: String
    var variant: Variant = .primary
    var size: Size = .large
    var showsArrow: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                if showsArrow {
                    DLIcon.arrow.image.font(.system(size: 15, weight: .semibold))
                }
            }
            .font(size == .large ? DLFont.button : .system(size: 15, weight: .semibold))
            .foregroundStyle(DL.ink)
            .frame(maxWidth: .infinity)
            .frame(height: size == .large ? 58 : 48)
            .contentShape(Capsule())
        }
        .buttonStyle(DLPressStyle())
        .dlGlass(variant == .primary ? .prime : .control, in: Capsule())
    }
}

/// Shared press feedback: a slight sink and dim, on the standard curve.
struct DLPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(Motion.quick, value: configuration.isPressed)
    }
}

// MARK: Icon button

struct DLIconButton: View {
    let icon: DLIcon
    let label: String
    var weight: GlassWeight = .control
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            icon.image
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(DL.ink)
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(DLPressStyle())
        .dlGlass(weight, in: Circle())
        .accessibilityLabel(label)
    }
}

// MARK: Status chip

struct DLChip: View {
    let label: String
    /// Nil is a neutral chip (time, difficulty).
    var status: ServiceStatus? = nil

    var body: some View {
        HStack(spacing: 6) {
            if let status {
                Circle()
                    .fill(status.color)
                    .frame(width: 6, height: 6)
                    .shadow(color: status.color, radius: 4)
            }
            Text(label)
                .font(.system(size: 12.5, weight: .medium))
                .foregroundStyle(status == nil ? DL.ink2 : DL.ink)
        }
        .padding(.horizontal, 11)
        .frame(height: 28)
        .background {
            if let status {
                Capsule().fill(status.color.opacity(0.14))
            }
        }
        .dlGlass(.control, in: Capsule())
    }
}

// MARK: Screen header

struct DLHeader: View {
    var eyebrow: String? = nil
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let eyebrow { DLLabel(eyebrow) }
            ChromeText(text: title, font: DLFont.title(40), tracking: -1.5)
                .accessibilityAddTraits(.isHeader)
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle).font(.system(size: 14)).foregroundStyle(DL.ink3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Space.gutter)
    }
}

/// Section heading with an optional trailing note, e.g. "Service · 6 items".
struct DLSectionHeader: View {
    let title: String
    var trailing: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(DLFont.section)
                .tracking(-0.5)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            if let trailing {
                Text(trailing).font(DLFont.callout).foregroundStyle(DL.ink3)
            }
        }
    }
}
