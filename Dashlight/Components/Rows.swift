import SwiftUI

// MARK: Service row

/// One maintenance item: glass icon, name, status value, detail and life bar.
struct DLServiceRow: View {
    let kind: MaintenanceKind
    let health: ItemHealth

    var body: some View {
        HStack(spacing: 14) {
            iconBadge
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(kind.title).font(DLFont.rowTitle).tracking(-0.2)
                    Spacer(minLength: 0)
                    Text(health.value)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(valueColor)
                        .lineLimit(1)
                }
                Text(health.detail)
                    .font(DLFont.caption)
                    .foregroundStyle(DL.ink3)
                    .lineLimit(1)
                DLLifeBar(fraction: health.lifeLeft, color: health.status.color)
                    .padding(.top, 7)
            }
            DLIcon.chevron.image
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DL.ink3)
        }
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Rectangle().fill(DL.line).frame(height: 1)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(kind.title), \(health.status.word). \(health.value). \(health.detail)")
    }

    private var valueColor: Color {
        health.status == .unknown ? DL.ink3 : health.status.color
    }

    private var iconBadge: some View {
        let hot = health.status.needsAttention
        return kind.icon.image
            .font(.system(size: 18, weight: .regular))
            .foregroundStyle(hot ? health.status.color : DL.ink2)
            .frame(width: 42, height: 42)
            .dlGlass(.control, in: Circle())
            .overlay {
                if hot {
                    Circle()
                        .strokeBorder(health.status.color.opacity(0.6), lineWidth: 1.5)
                        .shadow(color: health.status.color.opacity(0.35), radius: 8)
                }
            }
    }
}

// MARK: Attention banner

struct DLAlert: View {
    let status: ServiceStatus
    let title: String
    let text: String
    var cta: String = "Start"
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
                .shadow(color: status.color, radius: 6)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.system(size: 15, weight: .semibold)).tracking(-0.2)
                Text(text).font(DLFont.caption).foregroundStyle(DL.ink2)
            }
            Spacer(minLength: 0)
            Button(action: action) {
                Text(cta)
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundStyle(DL.ink)
                    .padding(.horizontal, 18)
                    .frame(height: 44)
                    .contentShape(Capsule())
            }
            .buttonStyle(DLPressStyle())
            .dlGlass(.prime, in: Capsule())
            .accessibilityLabel("\(cta): \(title)")
        }
        .padding(.leading, 16)
        .padding(.trailing, 10)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                .fill(LinearGradient(colors: [status.color.opacity(0.24), .white.opacity(0.04)], startPoint: .leading, endPoint: UnitPoint(x: 0.65, y: 0.5)))
        }
        .dlGlass(.card, cornerRadius: Radius.l)
    }
}

// MARK: Note

struct DLNote: View {
    enum Tone { case caution, tip, clean }

    let tone: Tone
    let title: String
    let text: String
    @Environment(\.vehicleTheme) private var theme

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            icon.image
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(color)
                .frame(width: 34, height: 34)
                .background(Circle().fill(color.opacity(0.16)))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 14.5, weight: .semibold)).tracking(-0.2)
                Text(text).font(DLFont.callout).foregroundStyle(DL.ink2).fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .dlGlass(.card, cornerRadius: Radius.l)
        .accessibilityElement(children: .combine)
    }

    private var color: Color {
        switch tone {
        case .caution: DL.due
        case .tip: theme.accent
        case .clean: DL.ok
        }
    }

    private var icon: DLIcon {
        switch tone {
        case .caution: .caution
        case .tip: .tip
        case .clean: .clean
        }
    }
}

// MARK: Kit row

struct DLKitRow: View {
    let name: String
    let cost: Double
    @Binding var owned: Bool
    @Environment(\.vehicleTheme) private var theme

    var body: some View {
        Button {
            withAnimation(Motion.quick) { owned.toggle() }
        } label: {
            HStack(spacing: 14) {
                DLCheckMark(isOn: owned)
                Text(name)
                    .font(.system(size: 15))
                    .foregroundStyle(owned ? DL.ink3 : DL.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(owned ? "Have it" : Fmt.money(cost))
                    .font(.system(size: 13.5, weight: .medium).monospacedDigit())
                    .foregroundStyle(owned ? theme.accent : DL.ink2)
            }
            .frame(minHeight: 56)
            .overlay(alignment: .bottom) { Rectangle().fill(DL.line).frame(height: 1) }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(name)
        .accessibilityValue(owned ? "Have it" : Fmt.money(cost))
        .accessibilityAddTraits(owned ? [.isSelected] : [])
        .accessibilityHint("Marks whether you already own this")
    }
}

// MARK: Check row

/// A checklist line, e.g. clean-up steps. Same check as the kit row, no price.
struct DLCheckRow: View {
    let text: String
    @Binding var isOn: Bool
    @Environment(\.vehicleTheme) private var theme

    var body: some View {
        Button {
            withAnimation(Motion.quick) { isOn.toggle() }
        } label: {
            HStack(spacing: 14) {
                DLCheckMark(isOn: isOn)
                Text(text)
                    .font(.system(size: 15))
                    .foregroundStyle(isOn ? DL.ink3 : DL.ink)
                    .strikethrough(isOn, color: DL.ink3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 10)
            .frame(minHeight: 52)
            .overlay(alignment: .bottom) { Rectangle().fill(DL.line).frame(height: 1) }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(text)
        .accessibilityAddTraits(isOn ? [.isSelected] : [])
    }
}

struct DLCheckMark: View {
    let isOn: Bool
    @Environment(\.vehicleTheme) private var theme

    var body: some View {
        ZStack {
            Circle().strokeBorder(isOn ? theme.accent : DL.lineStrong, lineWidth: 1.5)
            if isOn {
                Circle().fill(LinearGradient(colors: [theme.accentHi, theme.accent], startPoint: .top, endPoint: .bottom))
                DLIcon.check.image
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(theme.accentInk)
            }
        }
        .frame(width: 24, height: 24)
        .accessibilityHidden(true)
    }
}

// MARK: Log entry

struct DLLogRow: View {
    let record: ServiceRecord
    @Environment(\.vehicleTheme) private var theme

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                DLLabel(record.date.formatted(.dateTime.month(.abbreviated)))
                Text(record.date.formatted(.dateTime.day()))
                    .font(.system(size: 24, weight: .light).monospacedDigit())
                    .tracking(-1)
                Text(record.date.formatted(.dateTime.year()))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(DL.ink3)
            }
            .frame(width: 40)
            .padding(.top, 10)

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline) {
                    Text(record.kind.jobTitle).font(.system(size: 15, weight: .medium)).tracking(-0.2)
                    Spacer(minLength: 8)
                    Text(record.cost.map(Fmt.money) ?? "Add cost")
                        .font(.system(size: 15, weight: .medium).monospacedDigit())
                        .foregroundStyle(record.cost == nil ? theme.accentHi : DL.ink)
                }
                HStack(spacing: 8) {
                    Text(record.isDIY ? "DIY" : "Shop")
                        .font(.system(size: 11, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(record.isDIY ? theme.accent.opacity(0.18) : DL.surface2))
                        .foregroundStyle(record.isDIY ? theme.accentHi : DL.ink2)
                    Text(meta)
                        .font(DLFont.caption)
                        .foregroundStyle(DL.ink3)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .dlGlass(.card, cornerRadius: Radius.m)
        }
        .accessibilityElement(children: .combine)
    }

    private var meta: String {
        var parts: [String] = []
        if !record.place.isEmpty, record.place != "DIY" { parts.append(record.place) }
        if record.odometer > 0 { parts.append("\(Fmt.miles(record.odometer)) mi") }
        if let q = record.quartsAdded { parts.append("\(q.formatted()) qt") }
        if parts.isEmpty || record.odometer == 0 { parts.append("add details") }
        return parts.joined(separator: " · ")
    }
}

// MARK: Spec list

struct DLSpecList: View {
    let title: String
    let rows: [Guide.Spec]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            DLLabel(title)
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                    HStack(alignment: .firstTextBaseline, spacing: 16) {
                        Text(row.key).font(.system(size: 14)).foregroundStyle(DL.ink2)
                        Spacer(minLength: 0)
                        Text(row.value).font(.system(size: 14, weight: .medium)).multilineTextAlignment(.trailing)
                        if row.verify {
                            Text("verify").font(.system(size: 11, weight: .semibold)).foregroundStyle(DL.due)
                        }
                    }
                    .padding(.vertical, 13)
                    .overlay(alignment: .bottom) {
                        if index < rows.count - 1 { Rectangle().fill(DL.line).frame(height: 1) }
                    }
                    .accessibilityElement(children: .combine)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 2)
            .dlGlass(.card, cornerRadius: Radius.l)
        }
    }
}
