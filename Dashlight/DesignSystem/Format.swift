import Foundation

enum Fmt {
    static func miles(_ value: Int) -> String {
        value.formatted(.number.grouping(.automatic))
    }

    /// 141798 -> "141.8k"
    static func kMiles(_ value: Int) -> String {
        let k = Double(value) / 1000
        return k.formatted(.number.precision(.fractionLength(1))) + "k"
    }

    static func money(_ value: Double) -> String {
        value.formatted(.currency(code: "USD").precision(.fractionLength(0)))
    }

    static func moneyRange(_ low: Double, _ high: Double) -> String {
        "\(money(low))–\(money(high))"
    }

    static func date(_ date: Date) -> String {
        date.formatted(.dateTime.month(.abbreviated).day().year())
    }

    /// "5 yrs ago", "3 mo ago", "today"
    static func ago(_ date: Date, now: Date = .now) -> String {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month, .day], from: cal.startOfDay(for: date), to: cal.startOfDay(for: now))
        if let y = comps.year, y >= 1 { return y == 1 ? "1 yr ago" : "\(y) yrs ago" }
        if let m = comps.month, m >= 1 { return "\(m) mo ago" }
        if let d = comps.day, d >= 1 { return d == 1 ? "yesterday" : "\(d) days ago" }
        return "today"
    }

    static func greeting(now: Date = .now) -> String {
        switch Calendar.current.component(.hour, from: now) {
        case 5..<12: "Good morning"
        case 12..<17: "Good afternoon"
        default: "Good evening"
        }
    }
}
