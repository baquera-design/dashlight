import SwiftUI
import SwiftData

/// Log any job without a guide: a shop visit, or something done before the app.
struct LogServiceSheet: View {
    let vehicle: Vehicle
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var form: LogForm
    private let showsKindPicker: Bool

    init(vehicle: Vehicle, kind: MaintenanceKind?) {
        self.vehicle = vehicle
        self.showsKindPicker = kind == nil
        _form = State(initialValue: LogForm(kind: kind ?? .oil, odometer: vehicle.odometer, isDIY: false))
    }

    var body: some View {
        NavigationStack {
            DLScreen {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        if let guide = Guide.all.first(where: { $0.kind == form.kind }), !guide.isAvailable {
                            DLNote(tone: .tip, title: "Guide coming next", text: "\(guide.title) gets its own spill-free guide soon. For now, log it here.")
                        }
                        LogFormView(form: $form, showsKindPicker: showsKindPicker, showsWhoDidIt: true)
                    }
                    .padding(Space.gutter)
                }
            }
            .navigationTitle(showsKindPicker ? "Log a job" : form.kind.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        ServiceLogger.log(form.entry, vehicle: vehicle, context: context)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDragIndicator(.visible)
    }
}
