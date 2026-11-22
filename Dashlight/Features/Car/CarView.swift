import SwiftUI

/// The car itself: photo, VIN plate and specs.
struct CarView: View {
    @Bindable var vehicle: Vehicle
    @State private var editingVIN = false
    @State private var vinVersion = 0

    var body: some View {
        DLScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    DLHeader(eyebrow: "Car", title: vehicle.nickname, subtitle: vehicle.subtitle)
                        .padding(.horizontal, -Space.gutter)

                    DLHero(imageName: vehicle.heroImageName, carName: vehicle.nickname, height: 200)
                        .padding(.horizontal, -Space.gutter)

                    DLVINCard(prefix: vehicle.vinPrefix, vinKey: vehicle.vinKey) { editingVIN = true }
                        .id(vinVersion)

                    DLSpecList(title: "Vehicle", rows: [
                        .init(key: "Year", value: "\(vehicle.year)"),
                        .init(key: "Make and model", value: "\(vehicle.make) \(vehicle.modelName)"),
                        .init(key: "Trim", value: vehicle.trim),
                        .init(key: "Engine", value: vehicle.engine),
                        .init(key: "Color", value: vehicle.colorName),
                        .init(key: "Odometer", value: "\(Fmt.miles(vehicle.odometer)) mi")
                    ])

                    DLSpecList(title: "Fluids", rows: [
                        .init(key: "Coolant", value: "Motorcraft Orange, premix"),
                        .init(key: "Cooling system", value: "~6.5 qt", verify: true),
                        .init(key: "Engine oil", value: "5W-20 synthetic blend", verify: true),
                        .init(key: "Oil capacity", value: "~4.5 qt with filter", verify: true)
                    ])
                }
                .padding(.horizontal, Space.gutter)
                .padding(.top, 12)
                .padding(.bottom, 130)
            }
            .scrollIndicators(.hidden)
        }
        .sheet(isPresented: $editingVIN, onDismiss: { vinVersion += 1 }) {
            VINEditSheet(vehicle: vehicle)
        }
    }
}

private struct VINEditSheet: View {
    @Bindable var vehicle: Vehicle
    @Environment(\.dismiss) private var dismiss
    @State private var vin = ""
    @State private var failed = false

    var body: some View {
        NavigationStack {
            DLScreen {
                VStack(alignment: .leading, spacing: 14) {
                    DLLabel("Full VIN, 17 characters")
                    TextField("1FA…", text: $vin)
                        .font(.system(size: 20, weight: .medium, design: .monospaced))
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .padding(16)
                        .dlGlass(.card, cornerRadius: Radius.m)
                        .onChange(of: vin) { _, new in
                            let clean = String(new.uppercased().filter { $0.isLetter || $0.isNumber }.prefix(17))
                            if clean != new { vin = clean }
                        }
                    Text("Stored only on this iPhone, in the Keychain. Dashlight shows the first 3 characters; Face ID reveals the rest.")
                        .font(DLFont.callout)
                        .foregroundStyle(DL.ink3)
                    if failed {
                        Text("That doesn't look like a VIN. It's 17 letters and numbers, without I, O or Q.")
                            .font(DLFont.callout)
                            .foregroundStyle(DL.overdue)
                    }
                    Spacer()
                    DLButton(title: "Save VIN") {
                        guard VINVault.isValid(vin), VINVault.save(vin, key: vehicle.vinKey) else {
                            failed = true
                            return
                        }
                        vehicle.vinPrefix = String(vin.prefix(3))
                        dismiss()
                    }
                    .disabled(vin.count != 17)
                }
                .padding(Space.gutter)
            }
            .navigationTitle("VIN")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
        .presentationDetents([.medium])
    }
}
