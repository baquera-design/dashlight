import SwiftUI
import UIKit

/// VIN plate: first 3 characters, then stars. Face ID reveals the full VIN,
/// with copy, and it hides again after 30 seconds.
struct DLVINCard: View {
    let prefix: String
    let vinKey: String
    var onEdit: () -> Void = {}

    @State private var revealed: String?
    @State private var hasVIN = false
    @State private var hideTask: Task<Void, Never>?
    @Environment(\.vehicleTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                DLLabel("VIN")
                Spacer()
                Button(action: onEdit) {
                    Text(hasVIN ? "Edit" : "Add VIN")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(theme.accentHi)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.plain)
            }
            Text(revealed ?? VINVault.masked(prefix: prefix))
                .font(.system(size: 20, weight: .medium, design: .monospaced))
                .tracking(2)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .textSelection(.enabled)
                .contentTransition(.opacity)
                .accessibilityLabel(revealed.map { "VIN \($0)" } ?? "VIN hidden, starts with \(prefix)")

            HStack(spacing: 10) {
                if let revealed {
                    smallButton("Copy", icon: .copy) {
                        UIPasteboard.general.string = revealed
                    }
                    smallButton("Hide", icon: .lock) { hide() }
                } else {
                    smallButton("Reveal with Face ID", icon: .faceID, weight: hasVIN ? .prime : .control) {
                        Task { await reveal() }
                    }
                    .disabled(!hasVIN)
                    .opacity(hasVIN ? 1 : 0.5)
                }
            }
        }
        .padding(16)
        .dlGlass(.card, cornerRadius: Radius.l)
        .onAppear { hasVIN = VINVault.hasVIN(key: vinKey) }
        .onDisappear { hide() }
    }

    private func smallButton(_ title: String, icon: DLIcon, weight: GlassWeight = .control, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                icon.image.font(.system(size: 14, weight: .semibold))
                Text(title).font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(DL.ink)
            .padding(.horizontal, 16)
            .frame(height: 44)
            .contentShape(Capsule())
        }
        .buttonStyle(DLPressStyle())
        .dlGlass(weight, in: Capsule())
    }

    private func reveal() async {
        guard let vin = await VINVault.reveal(key: vinKey) else { return }
        withAnimation(Motion.quick) { revealed = vin }
        hideTask?.cancel()
        hideTask = Task {
            try? await Task.sleep(for: .seconds(30))
            guard !Task.isCancelled else { return }
            await MainActor.run { hide() }
        }
    }

    private func hide() {
        hideTask?.cancel()
        withAnimation(Motion.quick) { revealed = nil }
    }
}
