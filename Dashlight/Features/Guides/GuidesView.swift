import SwiftUI

/// The how-to library. Coolant is live; the rest are listed so the plan is visible.
struct GuidesView: View {
    let vehicle: Vehicle
    @Environment(AppRouter.self) private var router

    var body: some View {
        DLScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    DLHeader(eyebrow: "Apartment-garage editions", title: "Guides", subtitle: "Zero-spill methods for \(vehicle.nickname).")
                        .padding(.horizontal, -Space.gutter)

                    ForEach(Guide.all) { guide in
                        GuideCard(guide: guide, health: vehicle.item(guide.kind)?.health(odometer: vehicle.odometer)) {
                            router.open(guide.kind)
                        }
                    }
                }
                .padding(.horizontal, Space.gutter)
                .padding(.top, 12)
                .padding(.bottom, 130)
            }
            .scrollIndicators(.hidden)
        }
    }
}

private struct GuideCard: View {
    let guide: Guide
    let health: ItemHealth?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                guide.kind.icon.image
                    .font(.system(size: 18))
                    .foregroundStyle(health?.status.needsAttention == true ? health!.status.color : DL.ink2)
                    .frame(width: 44, height: 44)
                    .dlGlass(.control, in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    DLLabel(String(format: "Guide %02d", guide.number))
                    Text(guide.title).font(.system(size: 17, weight: .semibold)).tracking(-0.3)
                    HStack(spacing: 6) {
                        Text("\(guide.minutes) min").font(DLFont.caption).foregroundStyle(DL.ink3)
                        if guide.isAvailable, let health, health.status.needsAttention {
                            DLChip(label: health.value, status: health.status)
                        } else if !guide.isAvailable {
                            Text("· Guide coming next, log it for now").font(DLFont.caption).foregroundStyle(DL.ink3)
                        }
                    }
                }
                Spacer(minLength: 0)
                DLIcon.chevron.image.font(.system(size: 13, weight: .semibold)).foregroundStyle(DL.ink3)
            }
            .padding(16)
            .dlGlass(.card, cornerRadius: Radius.l)
            .contentShape(Rectangle())
        }
        .buttonStyle(DLPressStyle())
        .opacity(guide.isAvailable ? 1 : 0.75)
    }
}
