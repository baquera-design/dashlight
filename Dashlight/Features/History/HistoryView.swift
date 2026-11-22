import SwiftUI
import SwiftData

/// Service record and savings.
struct HistoryView: View {
    let vehicle: Vehicle
    @Environment(AppRouter.self) private var router
    @State private var logging = false

    var body: some View {
        let now = Date.now
        let records = vehicle.sortedRecords
        let diyCount = records.filter(\.isDIY).count
        let saved = vehicle.totalSaved

        DLScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    DLHeader(eyebrow: "\(vehicle.nickname) · service record", title: "History")
                        .padding(.horizontal, -Space.gutter)

                    VStack(alignment: .leading, spacing: 2) {
                        DLLabel("Saved by doing it yourself")
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            ChromeText(text: Fmt.money(saved), font: DLFont.numeral(88), tracking: -5)
                                .contentTransition(.numericText())
                            Text("so far").font(.system(size: 15)).foregroundStyle(DL.ink3)
                        }
                        if diyCount == 0, let coolant = Guide.guide(for: .coolant) {
                            let range = Fmt.moneyRange(coolant.cost.shopLow - coolant.cost.diy, coolant.cost.shopHigh - coolant.cost.diy)
                            Text("Your first DIY job, the coolant, should save \(Text(range).foregroundStyle(DL.ok).bold()).")
                                .font(.system(size: 14))
                                .foregroundStyle(DL.ink2)
                                .padding(.top, 6)
                        }
                    }
                    .accessibilityElement(children: .combine)

                    HStack(spacing: 10) {
                        DLTile(label: "Jobs", value: "\(records.count)", caption: "Logged")
                        DLTile(label: "Shop", value: "\(records.count - diyCount)", caption: "Paid for")
                        DLTile(label: "DIY", value: "\(diyCount)", caption: diyCount == 0 ? "Coolant is first" : "Done yourself")
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        DLSectionHeader(title: "Coming up")
                        ForEach(upcoming(now: now), id: \.0.id) { pair in
                            Button { router.open(pair.0.kind) } label: {
                                DLServiceRow(kind: pair.0.kind, health: pair.1)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        DLSectionHeader(title: "Log")
                        ForEach(records) { record in
                            DLLogRow(record: record)
                        }
                        DLButton(title: "Log a job", variant: .secondary, size: .regular) { logging = true }
                    }
                }
                .padding(.horizontal, Space.gutter)
                .padding(.top, 12)
                .padding(.bottom, 130)
            }
            .scrollIndicators(.hidden)
        }
        .sheet(isPresented: $logging) {
            LogServiceSheet(vehicle: vehicle, kind: nil)
        }
    }

    /// Logged items with a next due date, soonest first. Max 3.
    private func upcoming(now: Date) -> [(MaintenanceItem, ItemHealth)] {
        vehicle.sortedItems
            .map { ($0, $0.health(odometer: vehicle.odometer, now: now)) }
            .filter { $0.1.status != .unknown }
            .sorted { ($0.1.lifeLeft ?? 0) < ($1.1.lifeLeft ?? 0) }
            .prefix(3)
            .map { $0 }
    }
}
