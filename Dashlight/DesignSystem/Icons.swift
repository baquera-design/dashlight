import SwiftUI

/// Fastback icon set, mapped to SF Symbols so they match iOS weights and
/// scale with Dynamic Type.
enum DLIcon: String {
    case coolant, oil, tires, engineAir, wipers, cabinAir
    case care, guides, history, car
    case back, close, share, bell, plus, check, arrow, chevron
    case caution, tip, clean, faceID, lock, copy, edit, reset

    var symbol: String {
        switch self {
        case .coolant: "thermometer.medium"
        case .oil: "drop"
        case .tires: "circle.circle"
        case .engineAir: "wind"
        case .wipers: "windshield.front.and.wiper"
        case .cabinAir: "air.purifier"
        case .care: "gauge.with.dots.needle.67percent"
        case .guides: "wrench.adjustable"
        case .history: "clock.arrow.circlepath"
        case .car: "car.side"
        case .back: "chevron.left"
        case .close: "xmark"
        case .share: "square.and.arrow.up"
        case .bell: "bell"
        case .plus: "plus"
        case .check: "checkmark"
        case .arrow: "arrow.right"
        case .chevron: "chevron.right"
        case .caution: "exclamationmark.triangle"
        case .tip: "lightbulb"
        case .clean: "sparkles"
        case .faceID: "faceid"
        case .lock: "lock"
        case .copy: "doc.on.doc"
        case .edit: "pencil"
        case .reset: "arrow.counterclockwise"
        }
    }

    var image: Image { Image(systemName: symbol) }
}
