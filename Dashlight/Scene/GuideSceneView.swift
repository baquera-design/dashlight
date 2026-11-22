import SwiftUI
import RealityKit
import Combine

/// Live 3D view for a guide step. The camera dollies to the step's part,
/// the part lights up in the car's accent with a pulsing halo, body panels
/// fade to glass when the part is hidden (X-ray), and a drag orbits the car.
struct GuideSceneView: UIViewRepresentable {
    let part: ScenePart
    var xRay: Bool
    var showsRamps: Bool
    /// Bumped by the "recenter" button to undo any orbit.
    var recenterToken: Int
    var reduceMotion: Bool
    var accent: UIColor

    func makeCoordinator() -> Coordinator {
        Coordinator(accent: accent)
    }

    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        view.environment.background = .color(UIColor(red: 0.024, green: 0.031, blue: 0.043, alpha: 1))
        view.renderOptions.insert(.disableMotionBlur)
        view.renderOptions.insert(.disableCameraGrain)
        context.coordinator.attach(to: view)

        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        view.addGestureRecognizer(pan)
        let pinch = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        view.addGestureRecognizer(pinch)

        context.coordinator.apply(part: part, xRay: xRay, ramps: showsRamps, recenter: recenterToken, animated: false)
        return view
    }

    func updateUIView(_ view: ARView, context: Context) {
        context.coordinator.apply(part: part, xRay: xRay, ramps: showsRamps, recenter: recenterToken, animated: !reduceMotion)
    }

    static func dismantleUIView(_ view: ARView, coordinator: Coordinator) {
        coordinator.detach()
    }

    @MainActor
    final class Coordinator: NSObject {
        private let rig: CarRig
        private let anchor = AnchorEntity(world: .zero)
        private let pivot = Entity()
        private let camera = PerspectiveCamera()
        private let halo: ModelEntity
        private var updates: Cancellable?
        private var time: Float = 0

        private var currentPart: ScenePart?
        private var currentXRay: Bool?
        private var currentRecenter: Int?
        private var yaw: Float = 0
        private var pitch: Float = 0
        private var zoom: Float = 1
        private var startYaw: Float = 0
        private var startPitch: Float = 0
        private var startZoom: Float = 1

        init(accent: UIColor) {
            rig = CarRig(accent: accent)
            var glow = UnlitMaterial(color: accent)
            glow.blending = .transparent(opacity: .init(floatLiteral: 0.22))
            halo = ModelEntity(mesh: .generateSphere(radius: 1), materials: [glow])
            super.init()
        }

        func attach(to view: ARView) {
            camera.camera.fieldOfViewInDegrees = 42
            pivot.addChild(rig.root)
            pivot.addChild(halo)
            anchor.addChild(pivot)
            anchor.addChild(camera)

            // Soft key light from the top-left and a cool fill, like the canvas stage.
            let key = DirectionalLight()
            key.light.intensity = 2600
            key.light.color = .white
            key.look(at: .zero, from: [-2, 4, 3], relativeTo: nil)
            anchor.addChild(key)
            let fill = DirectionalLight()
            fill.light.intensity = 900
            fill.light.color = UIColor(red: 0.56, green: 0.72, blue: 0.79, alpha: 1)
            fill.look(at: .zero, from: [3, 1.5, -2], relativeTo: nil)
            anchor.addChild(fill)

            view.scene.addAnchor(anchor)

            updates = view.scene.subscribe(to: SceneEvents.Update.self) { [weak self] event in
                guard let self else { return }
                self.time += Float(event.deltaTime)
                let pulse = 1 + 0.18 * sin(self.time * 3.2)
                let radius = self.currentPart?.haloRadius ?? 0.1
                self.halo.scale = SIMD3(repeating: radius * pulse)
            }
        }

        func detach() {
            updates?.cancel()
            updates = nil
        }

        func apply(part: ScenePart, xRay: Bool, ramps: Bool, recenter: Int, animated: Bool) {
            rig.showRamps(ramps)

            if currentXRay != xRay {
                rig.setXRay(xRay)
                currentXRay = xRay
            }

            let partChanged = currentPart != part
            let recentered = currentRecenter != nil && currentRecenter != recenter
            currentRecenter = recenter
            guard partChanged || recentered else { return }

            currentPart = part
            rig.highlight(part)
            halo.position = part.anchor + rig.root.position

            if recentered || partChanged {
                yaw = 0
                pitch = 0
                zoom = 1
                pivot.transform.rotation = simd_quatf(angle: 0, axis: [0, 1, 0])
            }
            moveCamera(animated: animated)
        }

        private func moveCamera(animated: Bool) {
            guard let part = currentPart else { return }
            let target = part.anchor + rig.root.position
            let offset = (part.cameraPosition - part.anchor) * zoom
            let from = target + offset

            let goal = Entity()
            goal.look(at: target, from: from, relativeTo: nil)
            if animated {
                camera.move(to: goal.transform, relativeTo: anchor, duration: 0.9, timingFunction: .easeInOut)
            } else {
                camera.transform = goal.transform
            }
        }

        private func applyOrbit() {
            let rotation = simd_quatf(angle: yaw, axis: [0, 1, 0]) * simd_quatf(angle: pitch, axis: [1, 0, 0])
            // Orbit around the part, not the world origin.
            let center = (currentPart?.anchor ?? .zero) + rig.root.position
            pivot.transform = Transform(
                scale: .one,
                rotation: rotation,
                translation: center - rotation.act(center)
            )
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            if gesture.state == .began {
                startYaw = yaw
                startPitch = pitch
            }
            let t = gesture.translation(in: gesture.view)
            yaw = max(-1.2, min(1.2, startYaw + Float(t.x) * 0.006))
            pitch = max(-0.35, min(0.35, startPitch + Float(t.y) * 0.004))
            applyOrbit()
        }

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            if gesture.state == .began { startZoom = zoom }
            zoom = max(0.5, min(1.8, startZoom / Float(gesture.scale)))
            moveCamera(animated: false)
        }
    }
}
