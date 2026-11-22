import Foundation
import LocalAuthentication
import Security

/// Keeps a car's full VIN in the Keychain (this device only) and only hands it
/// back after Face ID or the passcode. The app's database stores just the
/// first 3 characters for display.
enum VINVault {
    private static let service = "design.baquera.dashlight.vin"

    static func save(_ vin: String, key: String) -> Bool {
        let data = Data(vin.uppercased().utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
        var add = query
        add[kSecValueData as String] = data
        add[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        return SecItemAdd(add as CFDictionary, nil) == errSecSuccess
    }

    static func hasVIN(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false
        ]
        return SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess
    }

    /// Asks for Face ID (falling back to the passcode), then reads the VIN.
    static func reveal(key: String) async -> String? {
        let context = LAContext()
        context.localizedFallbackTitle = "Use Passcode"
        do {
            let ok = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Reveal the full VIN")
            guard ok else { return nil }
        } catch {
            return nil
        }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// "1FA" + stars for the remaining 14 characters.
    static func masked(prefix: String) -> String {
        prefix + String(repeating: "*", count: max(0, 17 - prefix.count))
    }

    static func isValid(_ vin: String) -> Bool {
        let v = vin.uppercased()
        guard v.count == 17 else { return false }
        let allowed = CharacterSet(charactersIn: "ABCDEFGHJKLMNPRSTUVWXYZ0123456789")
        return v.unicodeScalars.allSatisfy { allowed.contains($0) }
    }
}
