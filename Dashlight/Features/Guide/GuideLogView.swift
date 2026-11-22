import SwiftUI
import SwiftData

/// End of a guide: the clean-up checklist, then "log it" with reminders.
struct GuideLogView: View {
    let guide: Guide
    let vehicle: Vehicle
    let onDone: () -> Void

    @Environment(\.modelContext) private var context
    @State private var cleaned: Set<Int> = []
    @State private var form: LogForm

    init(guide: Guide, vehicle: Vehicle, onDone: @escaping () -> Void) {
        self.guide = guide
        self.vehicle = vehicle
        self.onDone = onDone
        let round = (vehicle.records ?? []).contains { $0.kind == guide.kind && $0.isDIY && $0.date > Date.now.addingTimeInterval(-60 * 86_400) } ? 2 : 1
        _form = State(initialValue: LogForm(
            kind: guide.kind,
            odometer: vehicle.odometer,
            isDIY: true,
            cost: guide.cost.diy,
            quarts: guide.typicalQuarts,
            round: guide.kind == .coolant ? round : nil,
            remindRoundTwo: guide.kind == .coolant && round == 1,
            remindRecheck: guide.kind == .coolant
        ))
    }

    var body: some View {
        DLScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 6) {
                        DLLabel("\(guide.title) · done")
                        ChromeText(text: "Nice work.", font: DLFont.title(40), tracking: -1.5)
                            .accessibilityAddTraits(.isHeader)
                        Text("Two minutes of clean-up, then log it so \(vehicle.nickname)'s record stays honest.")
                            .font(DLFont.body)
                            .foregroundStyle(DL.ink2)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        DLSectionHeader(title: "Clean up", trailing: "\(cleaned.count) of \(guide.cleanUp.count)")
                        ForEach(Array(guide.cleanUp.enumerated()), id: \.offset) { index, line in
                            DLCheckRow(
                                text: line,
                                isOn: Binding(
                                    get: { cleaned.contains(index) },
                                    set: { on in if on { cleaned.insert(index) } else { cleaned.remove(index) } }
                                )
                            )
                        }
                    }

                    DLNote(tone: .clean, title: "Floor check", text: "Slide a white paper towel under the radiator. If it comes back clean, you're done.")

                    LogFormView(form: $form)
                }
                .padding(.horizontal, Space.gutter)
                .padding(.top, 24)
                .padding(.bottom, 130)
            }
            .scrollIndicators(.hidden)
        }
        .overlay(alignment: .bottom) {
            DLButton(title: "Log it", showsArrow: true) {
                ServiceLogger.log(form.entry, vehicle: vehicle, context: context)
                onDone()
            }
            .padding(.horizontal, Space.gutter)
            .padding(.top, 28)
            .padding(.bottom, 12)
            .background(
                LinearGradient(stops: [.init(color: DL.bg.opacity(0), location: 0), .init(color: DL.bg, location: 0.38)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
        }
    }
}

// MARK: Log form

struct LogForm {
    var kind: MaintenanceKind
    var date: Date = .now
    var odometer: Int?
    var isDIY: Bool
    var cost: Double?
    var quarts: Double?
    var round: Int?
    var place: String = ""
    var notes: String = ""
    var remindRoundTwo: Bool = false
    var remindRecheck: Bool = false

    var entry: ServiceLogger.Entry {
        ServiceLogger.Entry(
            kind: kind,
            date: date,
            odometer: odometer ?? 0,
            isDIY: isDIY,
            cost: cost,
            quartsAdded: kind == .coolant || kind == .oil ? quarts : nil,
            round: round,
            place: place.trimmingCharacters(in: .whitespaces),
            notes: notes,
            remindRoundTwo: remindRoundTwo,
            remindRecheck: remindRecheck
        )
    }
}

/// Fields for logging a job. Glass rows, numeric keypads, reminders as toggles.
struct LogFormView: View {
    @Binding var form: LogForm
    var showsKindPicker = false
    var showsWhoDidIt = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DLSectionHeader(title: "Log it")
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                if showsKindPicker {
                    row("Job") {
                        Picker("Job", selection: $form.kind) {
                            ForEach(MaintenanceKind.allCases) { Text($0.jobTitle).tag($0) }
                        }
                        .labelsHidden()
                    }
                }
                if showsWhoDidIt {
                    row("Done by") {
                        Picker("Done by", selection: $form.isDIY) {
                            Text("Me").tag(true)
                            Text("A shop").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 160)
                    }
                    if !form.isDIY {
                        row("Shop") {
                            TextField("Name", text: $form.place)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                row("Date") {
                    DatePicker("Date", selection: $form.date, in: ...Date.now, displayedComponents: .date)
                        .labelsHidden()
                }
                row("Odometer") {
                    HStack(spacing: 4) {
                        TextField("Miles", value: $form.odometer, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("mi").foregroundStyle(DL.ink3)
                    }
                }
                row("Cost") {
                    TextField("$0", value: $form.cost, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                if form.kind == .coolant || form.kind == .oil {
                    row("Quarts added") {
                        Stepper(value: Binding(get: { form.quarts ?? 0 }, set: { form.quarts = $0 }), in: 0...8, step: 0.5) {
                            Text("\((form.quarts ?? 0).formatted()) qt").monospacedDigit()
                        }
                    }
                }
                if form.round != nil {
                    row("Round") {
                        Picker("Round", selection: Binding(get: { form.round ?? 1 }, set: { form.round = $0 })) {
                            Text("1").tag(1)
                            Text("2").tag(2)
                            Text("3").tag(3)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 150)
                    }
                }
                if form.kind == .coolant {
                    toggleRow("Remind me to check the level tomorrow morning", isOn: $form.remindRecheck)
                    toggleRow("Remind me about round 2 in 3 to 4 weeks", isOn: $form.remindRoundTwo, last: true)
                }
            }
            .padding(.horizontal, 16)
            .dlGlass(.card, cornerRadius: Radius.l)
        }
        .font(.system(size: 15))
    }

    private func row<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            Text(title).foregroundStyle(DL.ink2)
            Spacer(minLength: 8)
            content()
        }
        .frame(minHeight: 52)
        .overlay(alignment: .bottom) { Rectangle().fill(DL.line).frame(height: 1) }
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>, last: Bool = false) -> some View {
        Toggle(isOn: isOn) {
            Text(title).foregroundStyle(DL.ink2)
        }
        .frame(minHeight: 52)
        .overlay(alignment: .bottom) {
            if !last { Rectangle().fill(DL.line).frame(height: 1) }
        }
    }
}
