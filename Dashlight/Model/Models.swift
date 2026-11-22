import Foundation
import SwiftData

// The data model separates what's true about a car (Vehicle, its items)
// from what Sam does (ServiceRecord) and what Sam owns (KitItem), so a future
// car can take over the kit and history can be archived, not deleted.
//
// Every stored property has a default and relationships are optional, which
// keeps the schema ready for CloudKit sync later.

enum MaintenanceKind: String, CaseIterable, Codable, Identifiable {
    case coolant, oil, tires, engineAir, wipers, cabinAir

    var id: String { rawValue }

    var title: String {
        switch self {
        case .coolant: "Coolant"
        case .oil: "Engine oil"
        case .tires: "Tires"
        case .engineAir: "Engine air filter"
        case .wipers: "Wiper blades"
        case .cabinAir: "Cabin air filter"
        }
    }

    /// Name of the job when it's logged.
    var jobTitle: String {
        switch self {
        case .coolant: "Coolant drain-and-fill"
        case .oil: "Oil change"
        case .tires: "Tire check"
        case .engineAir: "Engine air filter"
        case .wipers: "Wiper blades"
        case .cabinAir: "Cabin air filter"
        }
    }

    var icon: DLIcon {
        switch self {
        case .coolant: .coolant
        case .oil: .oil
        case .tires: .tires
        case .engineAir: .engineAir
        case .wipers: .wipers
        case .cabinAir: .cabinAir
        }
    }

    /// Approximate shop price for comparison (from the plan's cost analysis).
    var shopPrice: ClosedRange<Double> {
        switch self {
        case .coolant: 130...200
        case .oil: 70...100
        case .tires: 0...0
        case .engineAir: 50...70
        case .wipers: 60...80
        case .cabinAir: 60...90
        }
    }

    var unknownDetail: String {
        self == .tires ? "Tread depth not measured" : "Last change unknown"
    }
}

@Model
final class Vehicle {
    var nickname: String = ""
    var year: Int = 0
    var make: String = ""
    var modelName: String = ""
    var trim: String = ""
    var engine: String = ""
    var colorName: String = ""
    /// Asset name of the hero photo cutout.
    var heroImageName: String = ""
    /// First 3 VIN characters, safe to show. The full VIN lives in the Keychain.
    var vinPrefix: String = ""
    var odometer: Int = 0
    var odometerUpdatedAt: Date = Date.now
    var isActive: Bool = true
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \MaintenanceItem.vehicle)
    var items: [MaintenanceItem]? = []

    @Relationship(deleteRule: .cascade, inverse: \ServiceRecord.vehicle)
    var records: [ServiceRecord]? = []

    init(nickname: String, year: Int, make: String, modelName: String, trim: String, engine: String, colorName: String, heroImageName: String, vinPrefix: String, odometer: Int) {
        self.nickname = nickname
        self.year = year
        self.make = make
        self.modelName = modelName
        self.trim = trim
        self.engine = engine
        self.colorName = colorName
        self.heroImageName = heroImageName
        self.vinPrefix = vinPrefix
        self.odometer = odometer
    }

    var subtitle: String {
        "\(year) \(make) \(modelName) \(trim)"
    }

    /// Stable id for the VIN Keychain entry.
    var vinKey: String {
        "vin.\(createdAt.timeIntervalSince1970)"
    }

    func item(_ kind: MaintenanceKind) -> MaintenanceItem? {
        (items ?? []).first { $0.kind == kind }
    }

    var sortedItems: [MaintenanceItem] {
        (items ?? []).sorted { $0.kind.sortIndex < $1.kind.sortIndex }
    }

    var sortedRecords: [ServiceRecord] {
        (records ?? []).sorted { $0.date > $1.date }
    }
}

extension MaintenanceKind {
    var sortIndex: Int { Self.allCases.firstIndex(of: self) ?? 0 }
}

@Model
final class MaintenanceItem {
    var kindRaw: String = MaintenanceKind.coolant.rawValue
    var intervalMiles: Int? = nil
    var intervalMonths: Int? = nil
    var lastDoneDate: Date? = nil
    var lastDoneMiles: Int? = nil
    /// Where it was last done, e.g. "Take 5" or "DIY".
    var lastPlace: String = ""
    var vehicle: Vehicle? = nil

    init(kind: MaintenanceKind, intervalMiles: Int?, intervalMonths: Int?, lastDoneDate: Date? = nil, lastDoneMiles: Int? = nil, lastPlace: String = "") {
        self.kindRaw = kind.rawValue
        self.intervalMiles = intervalMiles
        self.intervalMonths = intervalMonths
        self.lastDoneDate = lastDoneDate
        self.lastDoneMiles = lastDoneMiles
        self.lastPlace = lastPlace
    }

    var kind: MaintenanceKind {
        MaintenanceKind(rawValue: kindRaw) ?? .coolant
    }
}

@Model
final class ServiceRecord {
    var date: Date = Date.now
    var odometer: Int = 0
    var kindRaw: String = MaintenanceKind.coolant.rawValue
    var isDIY: Bool = false
    /// What Sam paid. Nil until it's added.
    var cost: Double? = nil
    /// Shop price at the time, used for "saved by doing it yourself".
    var shopEstimate: Double? = nil
    var quartsAdded: Double? = nil
    /// For coolant: which drain-and-fill round this was.
    var round: Int? = nil
    var place: String = ""
    var notes: String = ""
    var vehicle: Vehicle? = nil

    init(date: Date, odometer: Int, kind: MaintenanceKind, isDIY: Bool, cost: Double? = nil, shopEstimate: Double? = nil, quartsAdded: Double? = nil, round: Int? = nil, place: String = "", notes: String = "") {
        self.date = date
        self.odometer = odometer
        self.kindRaw = kind.rawValue
        self.isDIY = isDIY
        self.cost = cost
        self.shopEstimate = shopEstimate
        self.quartsAdded = quartsAdded
        self.round = round
        self.place = place
        self.notes = notes
    }

    var kind: MaintenanceKind {
        MaintenanceKind(rawValue: kindRaw) ?? .coolant
    }

    /// Money saved versus the shop, for DIY jobs with a known cost.
    var saved: Double {
        guard isDIY, let shopEstimate else { return 0 }
        return max(0, shopEstimate - (cost ?? 0))
    }
}

/// The spill-free kit belongs to Sam, not to a car, so it moves to the next one.
@Model
final class KitItem {
    var name: String = ""
    var cost: Double = 0
    var owned: Bool = false
    var sortOrder: Int = 0
    /// Comma-separated guide ids this item is used by, e.g. "coolant,oil".
    var guideTags: String = ""

    init(name: String, cost: Double, owned: Bool = false, sortOrder: Int, guideTags: String) {
        self.name = name
        self.cost = cost
        self.owned = owned
        self.sortOrder = sortOrder
        self.guideTags = guideTags
    }

    func isUsed(by guideID: String) -> Bool {
        guideTags.split(separator: ",").contains { $0 == guideID }
    }
}
