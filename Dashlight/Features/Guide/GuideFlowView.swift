import SwiftUI

/// One guide, start to finish: overview, the steps, then clean up and log it.
struct GuideFlowView: View {
    let guide: Guide
    let vehicle: Vehicle

    private enum Stage: Equatable {
        case overview
        case step(Int)
        case log
    }

    @State private var stage: Stage = .overview
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            switch stage {
            case .overview:
                GuideOverviewView(guide: guide, vehicle: vehicle, onClose: { dismiss() }) {
                    go(.step(0))
                }
                .transition(.opacity)
            case .step(let index):
                GuideStepView(
                    guide: guide,
                    vehicle: vehicle,
                    index: index,
                    onClose: { go(.overview) },
                    onBack: { go(index > 0 ? .step(index - 1) : .overview) },
                    onNext: { go(index + 1 < guide.steps.count ? .step(index + 1) : .log) }
                )
                .id(index)
                .transition(reduceMotion ? .opacity : .asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
            case .log:
                GuideLogView(guide: guide, vehicle: vehicle, onDone: { dismiss() })
                    .transition(.opacity)
            }
        }
    }

    private func go(_ next: Stage) {
        withAnimation(Motion.standard(reduced: reduceMotion)) { stage = next }
    }
}
