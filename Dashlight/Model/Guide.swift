import Foundation
import CoreGraphics

/// A how-to guide. Guides are keyed to parts of a car (platform tags), not to
/// Astrid herself, so they carry over to any car on the same platform.
struct Guide: Identifiable {
    let id: String
    let kind: MaintenanceKind
    let number: Int
    let eyebrow: String
    let title: String
    let minutes: Int
    let difficulty: String
    let platformTags: [String]
    let intro: String
    let cost: CostCard
    let beforeYouStart: String
    let stopIf: [String]
    let caution: Note
    let specs: [Spec]
    let steps: [GuideStep]
    let cleanUp: [String]
    /// Suggested quarts added, prefilled on the log screen.
    let typicalQuarts: Double?
    let isAvailable: Bool

    struct CostCard {
        let diy: Double
        let shopLow: Double
        let shopHigh: Double
        let note: String
    }

    struct Note {
        let title: String
        let text: String
    }

    struct Spec: Identifiable {
        var id: String { key }
        let key: String
        let value: String
        var verify: Bool = false
    }
}

struct GuideStep: Identifiable {
    enum Phase: String {
        case contain = "Contain"
        case work = "Steps"
    }

    let id: Int
    let phase: Phase
    let title: String
    let body: String
    var caution: String? = nil
    var minutes: Int? = nil
    /// Label on the swipe-to-confirm control.
    var confirm: String = "Slide when done"
    /// Where the 2D view zooms on the hero photo (0...1 of the image).
    var focus: CGPoint
    /// Short label pinned to the focus point.
    var focusLabel: String
    /// Hidden from the side view, e.g. under the hood or behind the bumper.
    var isHidden: Bool = false
}

extension Guide {
    static let all: [Guide] = [.coolant, .placeholder(.oil, 2, "Oil change", 60), .placeholder(.wipers, 3, "Wiper blades", 10), .placeholder(.cabinAir, 4, "Cabin air filter", 10)]

    static func guide(for kind: MaintenanceKind) -> Guide? {
        all.first { $0.kind == kind && $0.isAvailable }
    }

    private static func placeholder(_ kind: MaintenanceKind, _ number: Int, _ title: String, _ minutes: Int) -> Guide {
        Guide(
            id: kind.rawValue, kind: kind, number: number, eyebrow: "Coming next", title: title, minutes: minutes,
            difficulty: "Beginner", platformTags: ["ford-c1-2.0-gdi"], intro: "", cost: .init(diy: 0, shopLow: 0, shopHigh: 0, note: ""),
            beforeYouStart: "", stopIf: [], caution: .init(title: "", text: ""), specs: [], steps: [], cleanUp: [],
            typicalQuarts: nil, isAvailable: false
        )
    }
}
