import SwiftUI
import SwiftData

/// Guide overview: what it costs, what "good enough" means, the spill-free
/// kit, when to stop and go to a shop, and the specs.
struct GuideOverviewView: View {
    let guide: Guide
    let vehicle: Vehicle
    let onClose: () -> Void
    let onStart: () -> Void

    @Query(sort: \KitItem.sortOrder) private var kit: [KitItem]
    @Environment(\.vehicleTheme) private var theme
    @State private var loggingPastJob = false

    private var guideKit: [KitItem] { kit.filter { $0.isUsed(by: guide.id) } }
    private var stillNeed: Double { guideKit.filter { !$0.owned }.reduce(0) { $0 + $1.cost } }

    var body: some View {
        let health = vehicle.item(guide.kind)?.health(odometer: vehicle.odometer)

        DLScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    hero(health: health)

                    VStack(alignment: .leading, spacing: 14) {
                        Text(guide.intro)
                            .font(DLFont.body)
                            .lineSpacing(3)
                            .foregroundStyle(DL.ink2)

                        DLCompare(diy: guide.cost.diy, shopLow: guide.cost.shopLow, shopHigh: guide.cost.shopHigh, note: guide.cost.note)

                        if health?.status == .unknown {
                            Button { loggingPastJob = true } label: {
                                Text("Already done it recently? Log it instead")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(theme.accentHi)
                                    .frame(minHeight: 44)
                            }
                            .buttonStyle(.plain)
                        }

                        if guide.kind == .coolant {
                            DLRounds()
                        }

                        kitSection
                            .padding(.top, 8)

                        DLNote(tone: .caution, title: guide.caution.title, text: guide.caution.text)

                        if !guide.stopIf.isEmpty {
                            stopCard
                        }

                        DLSpecList(title: guide.specsTitle, rows: specRows)
                    }
                    .padding(.horizontal, Space.gutter)
                    .padding(.top, 18)
                }
                .padding(.bottom, 140)
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)
        }
        .sheet(isPresented: $loggingPastJob) {
            LogServiceSheet(vehicle: vehicle, kind: guide.kind)
        }
        .overlay(alignment: .bottom) {
            DLButton(title: "Start guide · \(guide.steps.count) steps", showsArrow: true, action: onStart)
                .padding(.horizontal, Space.gutter)
                .padding(.top, 28)
                .padding(.bottom, 12)
                .background(
                    LinearGradient(stops: [.init(color: DL.bg.opacity(0), location: 0), .init(color: DL.bg, location: 0.38)], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                )
        }
    }

    // MARK: Hero

    private func hero(health: ItemHealth?) -> some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { geo in
                ZStack {
                    EllipticalGradient(colors: [theme.accentGlow, .clear], center: UnitPoint(x: 0.6, y: 0.5), endRadiusFraction: 0.5)
                        .frame(width: 600, height: 320)
                        .position(x: geo.size.width / 2, y: 230)
                    // Front end, where the radiator sits behind the grille.
                    Image(vehicle.heroImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geo.size.width * 2.2)
                        .brightness(-0.05)
                        .position(x: geo.size.width * (0.78 - (guide.heroFocus.x - 0.5) * 2.2), y: 230)
                        .accessibilityHidden(true)
                    LinearGradient(
                        stops: [
                            .init(color: DL.bg.opacity(0.55), location: 0),
                            .init(color: .clear, location: 0.28),
                            .init(color: .clear, location: 0.48),
                            .init(color: DL.bg, location: 0.94)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .clipped()
            }
            .frame(height: 400)

            VStack(alignment: .leading, spacing: 0) {
                DLLabel(guide.eyebrow)
                ChromeText(text: guide.title, font: DLFont.title(36), tracking: -1.3)
                    .padding(.top, 6)
                    .padding(.bottom, 12)
                    .accessibilityAddTraits(.isHeader)
                ScrollView(.horizontal) {
                    HStack(spacing: 6) {
                        DLChip(label: "\(guide.minutes) min")
                        DLChip(label: guide.difficulty)
                        DLChip(label: guide.methodChip)
                        if let health, health.status != .ok {
                            DLChip(label: health.value, status: health.status)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollClipDisabled()
            }
            .padding(.horizontal, Space.gutter)
            .padding(.bottom, 6)
        }
        .overlay(alignment: .topLeading) {
            DLIconButton(icon: .back, label: "Back to \(vehicle.nickname)", action: onClose)
                .padding(.leading, 16)
                .padding(.top, 60)
        }
    }

    // MARK: Kit

    private var kitSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            DLSectionHeader(
                title: guide.methodChip == "Zero-spill method" ? "Spill-free kit" : "What you need",
                trailing: stillNeed == 0 ? "You're all set" : "\(Fmt.money(stillNeed)) still to buy"
            )
            Text("Tap what you already have.")
                .font(DLFont.callout)
                .foregroundStyle(DL.ink3)
                .padding(.top, 2)
            ForEach(guideKit) { item in
                DLKitRow(name: item.name, cost: item.cost, owned: Binding(get: { item.owned }, set: { item.owned = $0 }))
            }
        }
    }

    // MARK: Stop card

    private var stopCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                DLIcon.caution.image.foregroundStyle(DL.overdue)
                Text("Stop and go to a shop if").font(.system(size: 14.5, weight: .semibold))
            }
            ForEach(guide.stopIf, id: \.self) { line in
                HStack(alignment: .top, spacing: 10) {
                    Circle().fill(DL.overdue).frame(width: 5, height: 5).padding(.top, 7)
                    Text(line).font(DLFont.callout).foregroundStyle(DL.ink2).fixedSize(horizontal: false, vertical: true)
                }
            }
            Text("Those are repairs, not maintenance.")
                .font(DLFont.caption)
                .foregroundStyle(DL.ink3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .dlGlass(.card, cornerRadius: Radius.l)
        .accessibilityElement(children: .combine)
    }

    private var specRows: [Guide.Spec] {
        var rows = guide.specs
        if let last = vehicle.item(guide.kind)?.lastDoneDate {
            rows.append(.init(key: "Last changed", value: Fmt.date(last)))
        }
        return rows
    }
}
