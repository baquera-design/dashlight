import Foundation
import SwiftData

/// First-launch data for Astrid. Runs once, when there are no vehicles.
enum SeedData {
    static func seedIfNeeded(_ context: ModelContext) {
        let count = (try? context.fetchCount(FetchDescriptor<Vehicle>())) ?? 0
        guard count == 0 else { return }

        let astrid = Vehicle(
            nickname: "Astrid",
            year: 2015,
            make: "Ford",
            modelName: "Focus",
            trim: "SE",
            engine: "2.0L GDI I-4",
            colorName: "White",
            heroImageName: "Astrid",
            vinPrefix: "1FA",
            odometer: 141_798
        )
        context.insert(astrid)

        let coolantDate = date(2021, 11, 20)
        let oilDate = date(2026, 11, 22)

        let items = [
            MaintenanceItem(kind: .coolant, intervalMiles: nil, intervalMonths: 60, lastDoneDate: coolantDate),
            MaintenanceItem(kind: .oil, intervalMiles: 5_000, intervalMonths: 6, lastDoneDate: oilDate, lastDoneMiles: 141_798, lastPlace: "Take 5"),
            MaintenanceItem(kind: .tires, intervalMiles: 7_500, intervalMonths: 6),
            MaintenanceItem(kind: .engineAir, intervalMiles: 30_000, intervalMonths: 36),
            MaintenanceItem(kind: .wipers, intervalMiles: nil, intervalMonths: 12),
            MaintenanceItem(kind: .cabinAir, intervalMiles: 15_000, intervalMonths: 12)
        ]
        for item in items {
            context.insert(item)
            item.vehicle = astrid
        }

        let records = [
            ServiceRecord(date: oilDate, odometer: 141_798, kind: .oil, isDIY: false, place: "Take 5"),
            ServiceRecord(date: coolantDate, odometer: 0, kind: .coolant, isDIY: false, place: "Shop")
        ]
        for record in records {
            context.insert(record)
            record.vehicle = astrid
        }

        let kit: [(String, Double)] = [
            ("Gloves, eye protection, towels", 15),
            ("Drop sheet + absorbent mat", 35),
            ("Lidded drain pan + vinyl tube", 25),
            ("Spill-free funnel kit", 30),
            ("2 gal Motorcraft Orange premix", 50)
        ]
        for (index, entry) in kit.enumerated() {
            context.insert(KitItem(name: entry.0, cost: entry.1, sortOrder: index, guideTags: index == 3 || index == 4 ? "coolant" : "coolant,oil"))
        }

        try? context.save()
    }

    private static func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: y, month: m, day: d, hour: 12)) ?? .now
    }
}
