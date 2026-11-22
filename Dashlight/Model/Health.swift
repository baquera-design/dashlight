import Foundation

/// How far through its interval a maintenance item is, and what to say about it.
struct ItemHealth {
    let status: ServiceStatus
    /// 0...1 of life left. Nil when the item has never been logged.
    let lifeLeft: Double?
    /// Short value on the right of a service row, e.g. "Due now", "100%", "Log it".
    let value: String
    /// Detail under the title.
    let detail: String
    /// Next due date and mileage, when known.
    let nextDate: Date?
    let nextMiles: Int?
}

extension MaintenanceItem {
    func health(odometer: Int, now: Date = .now) -> ItemHealth {
        guard let lastDate = lastDoneDate else {
            return ItemHealth(status: .unknown, lifeLeft: nil, value: "Log it", detail: kind.unknownDetail, nextDate: nil, nextMiles: nil)
        }

        var fractions: [Double] = []
        var nextDate: Date?
        var nextMiles: Int?

        if let months = intervalMonths, months > 0,
           let due = Calendar.current.date(byAdding: .month, value: months, to: lastDate) {
            nextDate = due
            let total = due.timeIntervalSince(lastDate)
            let left = due.timeIntervalSince(now)
            fractions.append(left / total)
        }
        if let miles = intervalMiles, miles > 0, let lastMiles = lastDoneMiles {
            let due = lastMiles + miles
            nextMiles = due
            fractions.append(Double(due - odometer) / Double(miles))
        }

        let left = fractions.min() ?? 1
        let status: ServiceStatus
        let value: String
        switch left {
        case ..<(-0.1):
            status = .overdue
            value = "Overdue"
        case ..<0.1:
            status = .due
            value = left <= 0 ? "Due now" : "Due soon"
        default:
            status = .ok
            value = "\(Int((left * 100).rounded()))%"
        }

        let when = Fmt.date(lastDate)
        let detail = lastPlace.isEmpty
            ? "Last changed \(when) · \(Fmt.ago(lastDate, now: now))"
            : "\(lastPlace) · \(when)"

        return ItemHealth(status: status, lifeLeft: max(0, min(1, left)), value: value, detail: detail, nextDate: nextDate, nextMiles: nextMiles)
    }
}

extension Vehicle {
    /// Care score: tachometer-style 0–100. Unlogged items count as "unsure"
    /// so logging them sharpens the score.
    func careScore(now: Date = .now) -> (score: Int, caption: String) {
        let all = sortedItems
        guard !all.isEmpty else { return (0, "Log a job to start your score.") }

        let healths = all.map { ($0.kind, $0.health(odometer: odometer, now: now)) }
        let points: [Double] = healths.map { pair in
            switch pair.1.status {
            case .ok: return 100
            case .due: return 40
            case .overdue: return 10
            case .unknown: return 60
            }
        }
        let score = Int((points.reduce(0, +) / Double(points.count)).rounded())

        let unknown = healths.filter { $0.1.status == .unknown }.count
        let urgent = healths.first { $0.1.status.needsAttention }
        var parts: [String] = []
        if let urgent {
            parts.append("\(urgent.0.title) is \(urgent.1.status == .overdue ? "overdue" : "due").")
        }
        if unknown > 0 {
            parts.append("Log \(unknown) more \(unknown == 1 ? "item" : "items") to sharpen it.")
        }
        if parts.isEmpty { parts.append("Everything is on schedule.") }
        return (score, parts.joined(separator: " "))
    }

    /// Most urgent item that needs attention, if any.
    func mostUrgent(now: Date = .now) -> (MaintenanceItem, ItemHealth)? {
        sortedItems
            .map { ($0, $0.health(odometer: odometer, now: now)) }
            .filter { $0.1.status.needsAttention }
            .min { ($0.1.lifeLeft ?? 0) < ($1.1.lifeLeft ?? 0) }
    }

    var totalSaved: Double {
        (records ?? []).reduce(0) { $0 + $1.saved }
    }
}
