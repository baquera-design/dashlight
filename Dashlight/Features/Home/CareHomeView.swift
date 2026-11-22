import SwiftUI
import SwiftData

/// Car Care home: Astrid lit as the hero, the care score, what needs
/// attention, quick stats and every service item.
struct CareHomeView: View {
    @Bindable var vehicle: Vehicle
    @Environment(AppRouter.self) private var router
    @State private var showReminders = false
    @State private var showOdometer = false

    var body: some View {
        let now = Date.now
        let score = vehicle.careScore(now: now)
        let oil = vehicle.item(.oil)?.health(odometer: vehicle.odometer, now: now)

        DLScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                        .padding(.horizontal, Space.gutter)

                    DLHero(
                        imageName: vehicle.heroImageName,
                        carName: vehicle.nickname,
                        spots: spots(now: now),
                        onSelect: { spot in
                            if let kind = MaintenanceKind(rawValue: spot.id) { router.open(kind) }
                        }
                    )
                    .padding(.top, -4)

                    VStack(alignment: .leading, spacing: 18) {
                        DLScore(score: score.score, caption: score.caption)

                        if let urgent = vehicle.mostUrgent(now: now) {
                            DLAlert(
                                status: urgent.1.status,
                                title: "\(urgent.0.kind.title) is \(urgent.1.status == .overdue ? "overdue" : "due")",
                                text: alertText(item: urgent.0, now: now),
                                cta: Guide.guide(for: urgent.0.kind) == nil ? "Log it" : "Start"
                            ) {
                                router.open(urgent.0.kind)
                            }
                        }

                        HStack(spacing: 10) {
                            Button { showOdometer = true } label: {
                                DLTile(label: "Odometer", value: Fmt.kMiles(vehicle.odometer), unit: "mi", caption: "Update miles")
                            }
                            .buttonStyle(DLPressStyle())

                            DLTile(
                                label: "Oil life",
                                value: oil?.lifeLeft.map { "\(Int(($0 * 100).rounded()))" } ?? "–",
                                unit: "%",
                                caption: vehicle.item(.oil)?.lastPlace.isEmpty == false ? "Changed \(Fmt.ago(vehicle.item(.oil)?.lastDoneDate ?? now, now: now))" : "Log oil",
                                status: oil?.status
                            )
                            DLTile(
                                label: "Next oil",
                                value: oil?.nextMiles.map(Fmt.kMiles) ?? "–",
                                unit: "mi",
                                caption: oil?.nextMiles.map { "~\(Fmt.miles(max(0, $0 - vehicle.odometer))) mi away" } ?? ""
                            )
                        }

                        VStack(alignment: .leading, spacing: 0) {
                            DLSectionHeader(title: "Service", trailing: "\(vehicle.sortedItems.count) items")
                                .padding(.top, 6)
                            ForEach(vehicle.sortedItems) { item in
                                Button { router.open(item.kind) } label: {
                                    DLServiceRow(kind: item.kind, health: item.health(odometer: vehicle.odometer, now: now))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, Space.gutter)
                }
                .padding(.top, 12)
                .padding(.bottom, 130)
            }
            .scrollIndicators(.hidden)
        }
        .sheet(isPresented: $showReminders) { RemindersSheet() }
        .sheet(isPresented: $showOdometer) { OdometerSheet(vehicle: vehicle) }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(Fmt.greeting()), Sam")
                    .font(.system(size: 14))
                    .foregroundStyle(DL.ink2)
                ChromeText(text: vehicle.nickname, font: DLFont.title(46), tracking: -1.8)
                    .accessibilityAddTraits(.isHeader)
                Text("\(vehicle.subtitle) · \(Fmt.miles(vehicle.odometer)) mi")
                    .font(.system(size: 14))
                    .foregroundStyle(DL.ink3)
                    .padding(.top, 4)
            }
            Spacer()
            DLIconButton(icon: .bell, label: "Reminders") { showReminders = true }
        }
    }

    /// Spots on the side photo. Nose is to the right.
    private func spots(now: Date) -> [HeroSpot] {
        let layout: [(MaintenanceKind, CGPoint)] = [
            (.coolant, CGPoint(x: 0.95, y: 0.52)),
            (.oil, CGPoint(x: 0.84, y: 0.37)),
            (.wipers, CGPoint(x: 0.72, y: 0.33)),
            (.cabinAir, CGPoint(x: 0.64, y: 0.52)),
            (.tires, CGPoint(x: 0.87, y: 0.78))
        ]
        let urgent = vehicle.mostUrgent(now: now)?.0.kind
        return layout.compactMap { entry -> HeroSpot? in
            let (kind, point) = entry
            guard let item = vehicle.item(kind) else { return nil }
            let status = item.health(odometer: vehicle.odometer, now: now).status
            return HeroSpot(id: kind.rawValue, name: kind.title, point: point, status: status, showsTag: kind == urgent)
        }
    }

    private func alertText(item: MaintenanceItem, now: Date) -> String {
        if let last = item.lastDoneDate {
            return "Last changed \(Fmt.ago(last, now: now))"
        }
        return item.kind.unknownDetail
    }
}

// MARK: Odometer

struct OdometerSheet: View {
    @Bindable var vehicle: Vehicle
    @Environment(\.dismiss) private var dismiss
    @State private var miles: Int?

    var body: some View {
        NavigationStack {
            DLScreen {
                VStack(alignment: .leading, spacing: 16) {
                    DLLabel("Odometer")
                    TextField("Miles", value: $miles, format: .number)
                        .keyboardType(.numberPad)
                        .font(DLFont.numeral(52))
                        .foregroundStyle(DL.ink)
                    Text("Last updated \(Fmt.date(vehicle.odometerUpdatedAt))")
                        .font(DLFont.callout)
                        .foregroundStyle(DL.ink3)
                    Spacer()
                    DLButton(title: "Save miles") {
                        if let miles, miles > 0 {
                            vehicle.odometer = miles
                            vehicle.odometerUpdatedAt = .now
                        }
                        dismiss()
                    }
                    .disabled((miles ?? 0) <= 0)
                }
                .padding(Space.gutter)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
        .presentationDetents([.medium])
        .onAppear { miles = vehicle.odometer }
    }
}

// MARK: Reminders

struct RemindersSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var items: [Reminders.Pending] = []
    @State private var loaded = false

    var body: some View {
        NavigationStack {
            DLScreen {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if loaded && items.isEmpty {
                            DLNote(tone: .tip, title: "No reminders yet", text: "Finish a guide and log it. Dashlight sets the next reminder for you.")
                        }
                        ForEach(items) { item in
                            HStack(alignment: .top, spacing: 12) {
                                DLIcon.bell.image.foregroundStyle(DL.ink2).frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title).font(.system(size: 15, weight: .medium))
                                    Text(item.body).font(DLFont.callout).foregroundStyle(DL.ink2)
                                    if let date = item.date {
                                        Text(date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().hour().minute()))
                                            .font(DLFont.caption)
                                            .foregroundStyle(DL.ink3)
                                    }
                                }
                                Spacer(minLength: 0)
                            }
                            .padding(14)
                            .dlGlass(.card, cornerRadius: Radius.m)
                        }
                    }
                    .padding(Space.gutter)
                }
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
        .task {
            items = await Reminders.pending()
            loaded = true
        }
    }
}
