import SwiftUI
import SwiftData

@main
struct DashlightApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
                .tint(VehicleTheme.astrid.accent)
        }
        .modelContainer(for: [Vehicle.self, MaintenanceItem.self, ServiceRecord.self, KitItem.self])
    }
}

/// App-wide navigation: guides open full screen over the tabs, and "log a
/// job" is a sheet that any screen can raise.
@Observable
final class AppRouter {
    var tab: DLTab = .care
    var activeGuide: Guide?
    var logKind: MaintenanceKind?

    func open(_ kind: MaintenanceKind) {
        if let guide = Guide.guide(for: kind) {
            activeGuide = guide
        } else {
            logKind = kind
        }
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Vehicle> { $0.isActive }, sort: \Vehicle.createdAt)
    private var vehicles: [Vehicle]
    @State private var router = AppRouter()

    var body: some View {
        Group {
            if let vehicle = vehicles.first {
                ZStack(alignment: .bottom) {
                    Group {
                        switch router.tab {
                        case .care: CareHomeView(vehicle: vehicle)
                        case .guides: GuidesView(vehicle: vehicle)
                        case .history: HistoryView(vehicle: vehicle)
                        case .car: CarView(vehicle: vehicle)
                        }
                    }
                    .transition(.opacity)

                    DLTabBar(selection: $router.tab)
                        .padding(.bottom, 8)
                }
                .fullScreenCover(item: $router.activeGuide) { guide in
                    GuideFlowView(guide: guide, vehicle: vehicle)
                        .environment(router)
                        .environment(\.vehicleTheme, .astrid)
                }
                .sheet(item: $router.logKind) { kind in
                    LogServiceSheet(vehicle: vehicle, kind: kind)
                        .environment(\.vehicleTheme, .astrid)
                }
            } else {
                DLScreen { ProgressView() }
            }
        }
        .environment(router)
        .environment(\.vehicleTheme, .astrid)
        .task { SeedData.seedIfNeeded(context) }
    }
}
