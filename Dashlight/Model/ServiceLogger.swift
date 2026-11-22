import Foundation
import SwiftData

/// Writes a finished job to the log, moves the item's "last done", bumps the
/// odometer if it went up, and sets the follow-up reminders.
enum ServiceLogger {
    struct Entry {
        var kind: MaintenanceKind
        var date: Date = .now
        var odometer: Int
        var isDIY: Bool = true
        var cost: Double?
        var quartsAdded: Double?
        var round: Int?
        var place: String = ""
        var notes: String = ""
        var remindRoundTwo: Bool = false
        var remindRecheck: Bool = false
    }

    @MainActor
    static func log(_ entry: Entry, vehicle: Vehicle, context: ModelContext) {
        let shop = entry.kind.shopPrice
        let record = ServiceRecord(
            date: entry.date,
            odometer: entry.odometer,
            kind: entry.kind,
            isDIY: entry.isDIY,
            cost: entry.cost,
            shopEstimate: entry.isDIY && shop.upperBound > 0 ? shop.lowerBound : nil,
            quartsAdded: entry.quartsAdded,
            round: entry.round,
            place: entry.isDIY ? "DIY" : entry.place,
            notes: entry.notes
        )
        context.insert(record)
        record.vehicle = vehicle

        if let item = vehicle.item(entry.kind) {
            // Only move "last done" forward; backfilling an old job keeps the newer date.
            if (item.lastDoneDate ?? .distantPast) <= entry.date {
                item.lastDoneDate = entry.date
                item.lastDoneMiles = entry.odometer > 0 ? entry.odometer : item.lastDoneMiles
                item.lastPlace = entry.isDIY ? "DIY" : entry.place
            }
        }

        if entry.odometer > vehicle.odometer {
            vehicle.odometer = entry.odometer
            vehicle.odometerUpdatedAt = entry.date
        }

        try? context.save()

        let name = vehicle.nickname
        Task {
            if entry.remindRecheck, let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: entry.date) {
                await Reminders.schedule(
                    id: "\(entry.kind.rawValue).recheck",
                    title: "Check \(name)'s \(entry.kind.title.lowercased()) level",
                    body: "Engine cold, hood up. It should sit at the MAX line. Top up if it dropped.",
                    on: tomorrow,
                    hour: 8
                )
            }
            if entry.remindRoundTwo, let later = Calendar.current.date(byAdding: .day, value: 24, to: entry.date) {
                await Reminders.schedule(
                    id: "\(entry.kind.rawValue).round2",
                    title: "Round 2 of the coolant drain-and-fill",
                    body: "Optional. A second round takes \(name) from about 45% to about 70% fresh coolant.",
                    on: later,
                    hour: 10
                )
            }
            if let item = vehicle.item(entry.kind),
               let next = item.health(odometer: vehicle.odometer).nextDate {
                await Reminders.schedule(
                    id: "\(entry.kind.rawValue).due",
                    title: "\(entry.kind.title) is due",
                    body: "\(name) is due for: \(entry.kind.jobTitle.lowercased()).",
                    on: next,
                    hour: 9
                )
            }
        }
    }
}
