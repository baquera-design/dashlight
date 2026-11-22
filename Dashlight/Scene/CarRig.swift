import RealityKit
import UIKit

/// A stylized, low-poly front half of the car built from primitives: painted
/// shapes and clean edges, in the Fastback palette. Only the parts the guides
/// touch are modeled. A USDZ model of Astrid can replace this later; the
/// guide steps only care about `ScenePart` anchors.
@MainActor
final class CarRig {
    let root = Entity()
    /// Body panels that fade to glass in X-ray mode.
    private(set) var shell: [ModelEntity] = []
    private var shellMaterial: [ObjectIdentifier: any RealityKit.Material] = [:]
    /// Parts that can light up, keyed by scene part.
    private(set) var parts: [ScenePart: [ModelEntity]] = [:]
    private var partMaterial: [ObjectIdentifier: (entity: ModelEntity, material: any RealityKit.Material)] = [:]
    /// Ramps only show for the oil change.
    private(set) var ramps: [ModelEntity] = []

    private let accent: UIColor

    init(paint: UIColor = UIColor(white: 0.93, alpha: 1), accent: UIColor) {
        self.accent = accent
        build(paint: paint)
    }

    // MARK: Build

    private func build(paint: UIColor) {
        let steel = UIColor(red: 0.42, green: 0.46, blue: 0.51, alpha: 1)
        let darkSteel = UIColor(red: 0.18, green: 0.21, blue: 0.25, alpha: 1)
        let rubber = UIColor(red: 0.07, green: 0.08, blue: 0.09, alpha: 1)
        let plastic = UIColor(red: 0.12, green: 0.14, blue: 0.17, alpha: 1)
        let orange = UIColor(red: 0.95, green: 0.55, blue: 0.2, alpha: 1)
        let amberOil = UIColor(red: 0.85, green: 0.62, blue: 0.2, alpha: 1)
        let glass = UIColor(red: 0.55, green: 0.7, blue: 0.78, alpha: 1)

        // Floor and the mat
        add(box([6, 0.01, 6]), color: UIColor(red: 0.04, green: 0.05, blue: 0.07, alpha: 1), at: [0, -0.005, 0])
        add(box([1.9, 0.012, 1.5]), color: UIColor(red: 0.16, green: 0.2, blue: 0.24, alpha: 1), at: [0, 0.006, 1.25], part: .floor)

        // Body shell (X-ray-able)
        addShell(box([1.76, 0.42, 0.26], radius: 0.08), color: paint, at: [0, 0.48, 1.55])            // bumper
        addShell(box([1.7, 0.05, 1.15], radius: 0.02), color: paint, at: [0, 0.98, 0.95], pitch: -0.08) // hood
        addShell(box([0.14, 0.5, 1.3], radius: 0.05), color: paint, at: [0.82, 0.72, 0.95])            // driver fender
        addShell(box([0.14, 0.5, 1.3], radius: 0.05), color: paint, at: [-0.82, 0.72, 0.95])           // passenger fender
        addShell(box([1.76, 0.6, 2.4], radius: 0.1), color: paint, at: [0, 0.68, -1.3])               // cabin lower
        addShell(box([1.6, 0.05, 1.3], radius: 0.02), color: paint, at: [0, 1.42, -1.25])             // roof

        // Glass
        add(box([1.5, 0.02, 0.95]), color: glass, at: [0, 1.2, 0.18], pitch: 0.62, opacity: 0.28, part: .windshield)

        // Wheels
        for x: Float in [0.8, -0.8] {
            for z: Float in [1.0, -1.7] {
                let tire = cylinder(height: 0.22, radius: 0.32)
                let wheel = add(tire, color: rubber, at: [x, 0.32, z], roll: .pi / 2, part: (x > 0 && z > 0) ? .frontWheel : nil)
                let hub = add(cylinder(height: 0.23, radius: 0.18), color: steel, at: .zero, roll: 0)
                wheel.addChild(hub)
            }
        }

        // Ramps (oil change only)
        for x: Float in [0.8, -0.8] {
            let ramp = add(box([0.32, 0.12, 0.9], radius: 0.02), color: UIColor(red: 0.85, green: 0.2, blue: 0.15, alpha: 1), at: [x, 0.04, 1.15], pitch: -0.12)
            ramp.isEnabled = false
            ramps.append(ramp)
        }

        // Engine bay
        add(box([0.8, 0.48, 0.6], radius: 0.04), color: darkSteel, at: [0, 0.6, 0.85])                  // engine block
        add(box([1.3, 0.5, 0.05], radius: 0.01), color: plastic, at: [0, 0.6, 1.38])                    // radiator
        add(cylinder(height: 0.07, radius: 0.03), color: orange, at: ScenePart.petcock.anchor, pitch: .pi / 2, part: .petcock)
        add(box([0.6, 0.14, 0.5], radius: 0.03), color: steel, at: [0, 0.3, 0.8], part: .oilPan)
        add(cylinder(height: 0.06, radius: 0.03), color: steel, at: ScenePart.oilPan.anchor, part: .oilPan) // drain plug
        add(cylinder(height: 0.14, radius: 0.055), color: UIColor(red: 0.12, green: 0.3, blue: 0.62, alpha: 1), at: ScenePart.oilFilter.anchor, pitch: .pi / 2, part: .oilFilter)
        add(cylinder(height: 0.03, radius: 0.045), color: rubber, at: ScenePart.oilCap.anchor, part: .oilCap)
        add(cylinder(height: 0.1, radius: 0.015), color: UIColor(red: 0.98, green: 0.82, blue: 0.2, alpha: 1), at: ScenePart.dipstick.anchor, part: .dipstick)
        add(cylinder(height: 0.55, radius: 0.035), color: rubber, at: ScenePart.upperHose.anchor, pitch: .pi / 2, part: .upperHose)

        // Degas bottle: translucent tank with orange coolant inside
        add(box([0.2, 0.22, 0.15], radius: 0.03), color: .white, at: ScenePart.degas.anchor, opacity: 0.45, part: .degas)
        add(box([0.17, 0.12, 0.12], radius: 0.02), color: orange, at: ScenePart.degas.anchor - [0, 0.04, 0])
        add(cylinder(height: 0.04, radius: 0.04), color: rubber, at: ScenePart.degas.anchor + [0, 0.13, 0], part: .degas)

        // Drain pan on the mat
        add(box([0.6, 0.1, 0.48], radius: 0.03), color: rubber, at: ScenePart.drainPan.anchor, part: .drainPan)
        add(box([0.52, 0.02, 0.4]), color: amberOil, at: ScenePart.drainPan.anchor + [0, 0.035, 0], opacity: 0.6)

        // Wipers
        add(box([0.7, 0.025, 0.04], radius: 0.01), color: rubber, at: ScenePart.wiperArm.anchor, yaw: 0.2, part: .wiperArm)
        add(box([0.55, 0.025, 0.04], radius: 0.01), color: rubber, at: [-0.4, 1.02, 0.52], yaw: 0.2, part: .wiperArm)

        // Cabin: dash, steering wheel, glove box
        add(box([1.5, 0.28, 0.35], radius: 0.05), color: plastic, at: [0, 0.95, -0.2])
        add(cylinder(height: 0.04, radius: 0.18), color: rubber, at: ScenePart.dash.anchor, pitch: 1.2, part: .dash)
        add(box([0.42, 0.18, 0.06], radius: 0.02), color: UIColor(red: 0.2, green: 0.23, blue: 0.27, alpha: 1), at: ScenePart.gloveBox.anchor, part: .gloveBox)
    }

    // MARK: Highlight and X-ray

    func highlight(_ part: ScenePart?) {
        for saved in partMaterial.values {
            saved.entity.model?.materials = [saved.material]
        }
        guard let part, let entities = parts[part] else { return }
        let lit = UnlitMaterial(color: accent)
        for entity in entities where entity.components[ModelComponent.self] != nil {
            entity.model?.materials = [lit]
        }
    }

    func setXRay(_ on: Bool) {
        for entity in shell {
            if on {
                var ghost = PhysicallyBasedMaterial()
                ghost.baseColor = .init(tint: UIColor(red: 0.75, green: 0.86, blue: 0.92, alpha: 1))
                ghost.roughness = 0.2
                ghost.blending = .transparent(opacity: .init(floatLiteral: 0.12))
                entity.model?.materials = [ghost]
            } else if let material = shellMaterial[ObjectIdentifier(entity)] {
                entity.model?.materials = [material]
            }
        }
    }

    func showRamps(_ on: Bool) {
        for ramp in ramps { ramp.isEnabled = on }
        // Up on the ramps the car sits a little higher.
        root.position.y = on ? 0.1 : 0
    }

    // MARK: Helpers

    private func box(_ size: SIMD3<Float>, radius: Float = 0) -> MeshResource {
        .generateBox(size: size, cornerRadius: radius)
    }

    private func cylinder(height: Float, radius: Float) -> MeshResource {
        .generateCylinder(height: height, radius: radius)
    }

    private func material(_ color: UIColor, opacity: Float) -> any RealityKit.Material {
        var m = PhysicallyBasedMaterial()
        m.baseColor = .init(tint: color)
        m.roughness = 0.45
        m.metallic = 0.1
        if opacity < 1 {
            m.blending = .transparent(opacity: .init(floatLiteral: opacity))
        }
        return m
    }

    @discardableResult
    private func add(
        _ mesh: MeshResource,
        color: UIColor,
        at position: SIMD3<Float>,
        pitch: Float = 0,
        yaw: Float = 0,
        roll: Float = 0,
        opacity: Float = 1,
        part: ScenePart? = nil
    ) -> ModelEntity {
        let mat = material(color, opacity: opacity)
        let entity = ModelEntity(mesh: mesh, materials: [mat])
        entity.position = position
        entity.orientation = simd_quatf(angle: yaw, axis: [0, 1, 0])
            * simd_quatf(angle: pitch, axis: [1, 0, 0])
            * simd_quatf(angle: roll, axis: [0, 0, 1])
        root.addChild(entity)
        if let part {
            parts[part, default: []].append(entity)
            partMaterial[ObjectIdentifier(entity)] = (entity, mat)
        }
        return entity
    }

    private func addShell(_ mesh: MeshResource, color: UIColor, at position: SIMD3<Float>, pitch: Float = 0) {
        let entity = add(mesh, color: color, at: position, pitch: pitch)
        shell.append(entity)
        shellMaterial[ObjectIdentifier(entity)] = entity.model?.materials.first
    }
}
