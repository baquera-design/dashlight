import SwiftUI

// MARK: DIY vs shop

struct DLCompare: View {
    var label: String = "Cost"
    let diy: Double
    let shopLow: Double
    let shopHigh: Double
    let note: String
    @Environment(\.vehicleTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                DLLabel(label)
                Spacer()
                Text("Save \(Fmt.moneyRange(shopLow - diy, shopHigh - diy))")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DL.ok)
            }
            Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 12) {
                GridRow {
                    Text("DIY").font(DLFont.callout).foregroundStyle(DL.ink2).frame(width: 44, alignment: .leading)
                    bar { geo in
                        Capsule().fill(theme.accent)
                            .frame(width: geo.size.width * diy / shopHigh)
                            .shadow(color: theme.accentGlow, radius: 5)
                    }
                    amount("~\(Fmt.money(diy))")
                }
                GridRow {
                    Text("Shop").font(DLFont.callout).foregroundStyle(DL.ink2).frame(width: 44, alignment: .leading)
                    bar { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(.white.opacity(0.16))
                            Capsule().fill(.white.opacity(0.42)).frame(width: geo.size.width * shopLow / shopHigh)
                        }
                    }
                    amount(Fmt.moneyRange(shopLow, shopHigh))
                }
            }
            Text(note).font(DLFont.caption).foregroundStyle(DL.ink3)
        }
        .padding(16)
        .dlGlass(.card, cornerRadius: Radius.l)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Do it yourself about \(Fmt.money(diy)). Shop \(Fmt.moneyRange(shopLow, shopHigh)). \(note)")
    }

    private func bar<Fill: View>(@ViewBuilder _ fill: @escaping (GeometryProxy) -> Fill) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(DL.line)
                fill(geo)
            }
        }
        .frame(height: 8)
    }

    private func amount(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17, weight: .medium).monospacedDigit())
            .tracking(-0.4)
            .frame(width: 92, alignment: .trailing)
    }
}

// MARK: Good-enough rounds

/// Explains drain-and-fill rounds in plain terms: how much is fresh after each.
struct DLRounds: View {
    @State private var selected = 1
    @Environment(\.vehicleTheme) private var theme

    private struct Round { let n: Int; let pct: Int; let text: String }
    private let rounds = [
        Round(n: 1, pct: 45, text: "Good enough for now. A shop flush swaps about 95% in one visit; one drain-and-fill swaps about half."),
        Round(n: 2, pct: 70, text: "Drive 3 to 4 weeks, then repeat. Two rounds gets you most of the benefit of a shop flush."),
        Round(n: 3, pct: 85, text: "A third round is optional. Past this, extra rounds barely move the number.")
    ]

    var body: some View {
        let current = rounds[selected - 1]
        VStack(alignment: .leading, spacing: 0) {
            DLLabel("Fresh coolant in the system")
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                ChromeText(text: "≈\(current.pct)%", font: .system(size: 44, weight: .light).monospacedDigit(), tracking: -2)
                    .contentTransition(.numericText())
                Text("after round \(current.n)").font(.system(size: 14)).foregroundStyle(DL.ink2)
            }
            .padding(.top, 4)

            HStack(spacing: 8) {
                ForEach(rounds, id: \.n) { round in
                    Button {
                        withAnimation(Motion.standard) { selected = round.n }
                    } label: {
                        VStack(alignment: .leading, spacing: 7) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(DL.line)
                                    Capsule()
                                        .fill(round.n <= selected ? theme.accent : .white.opacity(0.18))
                                        .frame(width: geo.size.width * Double(round.pct) / 100)
                                }
                            }
                            .frame(height: 6)
                            Text("Round \(round.n) · \(round.pct)%")
                                .font(.system(size: 12, weight: round.n == selected ? .semibold : .regular))
                                .foregroundStyle(round.n == selected ? DL.ink : DL.ink3)
                        }
                        .frame(minHeight: 44, alignment: .top)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Round \(round.n), about \(round.pct) percent fresh")
                    .accessibilityAddTraits(round.n == selected ? [.isSelected] : [])
                }
            }
            .padding(.top, 14)

            Text(current.text)
                .font(DLFont.callout)
                .foregroundStyle(DL.ink2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
        }
        .padding(16)
        .dlGlass(.card, cornerRadius: Radius.l)
    }
}
