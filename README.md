# Dashlight

A personal iOS app for keeping Astrid, a 2015 Ford Focus SE, healthy from an apartment garage: service tracking, cost estimates, and zero-spill how-to guides.

## Run it

1. Open `Dashlight.xcodeproj` in Xcode 16 or later.
2. Pick the **Dashlight** scheme and an iPhone simulator, then press Run.
3. To run on your iPhone: select the Dashlight target › Signing & Capabilities, choose your personal team, then pick your phone as the run destination.

Requires iOS 18. No server, no account; data lives on the phone (SwiftData).

## What's in Phase 1 (Coolant MVP)

- **Care home**: Astrid's photo as the hero with glowing status points, the care score, what needs attention, odometer and oil stats, and every service item with its life bar.
- **Coolant guide**: cost (DIY vs shop), "good enough" rounds, the spill-free kit (tap what you own), when to stop and go to a shop, specs.
- **Guide steps**: 14 steps, each with a 2D view that zooms into the spot on the car, a glass step sheet, and swipe to confirm. The 3D (RealityKit) scene replaces the 2D view in Phase 2 with the same layout.
- **Clean up and log it**: clean-up checklist, then the job is logged, the item's "last done" moves, and reminders are set (check the level tomorrow morning, optional round 2 in about 3 weeks, next due date).
- **History**: money saved by doing it yourself, upcoming items, the service log, and "log a job" for shop visits or anything without a guide yet.
- **Car**: specs and the VIN plate (first 3 characters, Face ID reveals the full VIN, stored in the Keychain on this device only).

## Design system: Fastback v3, "Night garage" + liquid glass

The SwiftUI code mirrors `tokens.css` from the design canvas.

| Canvas | SwiftUI |
| --- | --- |
| Raw paint `--fb-*` | `FB` in `DesignSystem/Tokens.swift` |
| Semantic roles `--dl-*` | `DL`, `Space`, `Radius`, `Motion` |
| Vehicle theme (accent, glow, photo) | `VehicleTheme` in the environment (`\.vehicleTheme`) |
| `.dl-lg` glass + `--card`, `--prime`, `--tint`, `--orb` | `.dlGlass(_:in:)` in `DesignSystem/LiquidGlass.swift` |
| `--dl-stage` light pools | `DLStage` / `DLScreen` |
| Geist + Geist Mono | SF Pro + SF Mono (`DLFont`, `DLLabel`, `ChromeText`) |
| Components `DL*.dc.html` | `Components/` (same names: `DLScore`, `DLServiceRow`, `DLSwipe`, …) |

Rules that carry over: color only means status and always comes with a word; Brittany Blue means "look here"; one big number per screen; controls are pills or circles; one ease curve (450 ms); Reduce Motion swaps movement for crossfades.

## Project layout

```
Dashlight/
  App/            app entry, root tabs, router
  DesignSystem/   tokens, glass material, type, icons, formatting
  Components/     reusable Fastback components
  Model/          SwiftData models, health logic, guides, seed data
  Features/       Care home, Guide flow, History, Guides, Car
  Services/       reminders, VIN Keychain vault
```

A future car is a new `Vehicle` with its own photo, hotspots and `VehicleTheme`; guides are tagged by platform, and the kit belongs to Sam, not the car.
