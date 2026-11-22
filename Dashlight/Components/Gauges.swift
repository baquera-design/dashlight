import SwiftUI

// MARK: Care score

/// The one classic-car nod: a tachometer row of 40 ticks with a redline.
struct DLScore: View {
    var label: String = "Care score"
    let score: Int
    let caption: String
    @Environment(\.vehicleTheme) private var theme

    private let tickCount = 40
    private let redlineStart = 35

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .bottom, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    DLLabel(label)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        ChromeText(text: "\(score)", font: DLFont.numeral(68), tracking: -3.5)
                            .contentTransition(.numericText())
                        Text("/100").font(.system(size: 18)).foregroundStyle(DL.ink3)
                    }
                }
                Spacer(minLength: 0)
                Text(caption)
                    .font(DLFont.callout)
                    .foregroundStyle(DL.ink2)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 160, alignment: .trailing)
                    .padding(.bottom, 6)
            }
            ticks
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) \(score) out of 100. \(caption)")
    }

    private var ticks: some View {
        let lit = Int((Double(max(0, min(100, score))) / 100 * Double(tickCount)).rounded())
        return HStack(alignment: .bottom, spacing: 3) {
            ForEach(0..<tickCount, id: \.self) { i in
                let on = i < lit
                let red = i >= redlineStart
                RoundedRectangle(cornerRadius: 1)
                    .fill(on ? (red ? DL.overdue : theme.accent) : (red ? DL.overdue.opacity(0.30) : DL.lineStrong))
                    .frame(height: i % 5 == 0 ? 22 : 13)
                    .shadow(color: on && i == lit - 1 ? theme.accent : .clear, radius: 5)
            }
        }
        .frame(height: 22)
    }
}

// MARK: Stat tile

struct DLTile: View {
    let label: String
    let value: String
    var unit: String = ""
    var caption: String = ""
    var status: ServiceStatus? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            DLLabel(label)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 26, weight: .light).monospacedDigit())
                    .tracking(-1)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                if !unit.isEmpty {
                    Text(unit).font(.system(size: 13)).foregroundStyle(DL.ink3)
                }
            }
            Spacer(minLength: 0)
            HStack(spacing: 5) {
                if let status {
                    Circle().fill(status.color).frame(width: 6, height: 6)
                }
                Text(caption)
                    .font(.system(size: 11.5))
                    .foregroundStyle(DL.ink3)
                    .lineLimit(2)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 116, alignment: .topLeading)
        .dlGlass(.card, cornerRadius: Radius.l)
        .accessibilityElement(children: .combine)
    }
}

// MARK: Life bar

/// Thin bar showing how much life is left. Unknown is a dashed track.
struct DLLifeBar: View {
    let fraction: Double?
    let color: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                if fraction == nil {
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 1.5))
                        path.addLine(to: CGPoint(x: geo.size.width, y: 1.5))
                    }
                    .stroke(DL.lineStrong, style: StrokeStyle(lineWidth: 3, dash: [4, 4]))
                } else {
                    Capsule().fill(DL.line)
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * max(0.03, min(1, fraction ?? 0)))
                        .shadow(color: color, radius: 4)
                }
            }
        }
        .frame(height: 3)
        .accessibilityHidden(true)
    }
}
