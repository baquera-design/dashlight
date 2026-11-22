import simd

/// A part of the car a guide step points at. Each part knows where it sits in
/// the stylized 3D rig and where the camera should look from.
/// Coordinates are meters; the car faces +z (toward the default camera),
/// y is up, and the driver's side is +x.
enum ScenePart: String, CaseIterable {
    case floor, drainPan, petcock, degas, upperHose
    case oilPan, oilFilter, oilCap, dipstick, frontWheel
    case windshield, wiperArm, dash, gloveBox

    /// Where the part sits.
    var anchor: SIMD3<Float> {
        switch self {
        case .floor: [0, 0.02, 1.25]
        case .drainPan: [0.35, 0.06, 1.15]
        case .petcock: [0.58, 0.32, 1.42]
        case .degas: [0.48, 0.86, 0.72]
        case .upperHose: [-0.35, 0.78, 1.12]
        case .oilPan: [0, 0.24, 0.72]
        case .oilFilter: [0.28, 0.36, 1.1]
        case .oilCap: [-0.15, 0.9, 0.8]
        case .dipstick: [0.15, 0.9, 0.66]
        case .frontWheel: [0.8, 0.32, 1.0]
        case .windshield: [0, 1.22, 0.18]
        case .wiperArm: [0.3, 1.02, 0.52]
        case .dash: [0.4, 1.05, -0.32]
        case .gloveBox: [-0.45, 0.86, -0.04]
        }
    }

    /// Where the camera sits to frame the part.
    var cameraPosition: SIMD3<Float> {
        switch self {
        case .floor: [1.9, 1.5, 3.4]
        case .drainPan: [1.5, 0.9, 2.6]
        case .petcock: [1.35, 0.45, 2.35]
        case .degas: [1.2, 1.85, 1.85]
        case .upperHose: [-1.05, 1.75, 2.2]
        case .oilPan: [1.25, 0.3, 2.3]
        case .oilFilter: [1.05, 0.45, 2.15]
        case .oilCap: [0.55, 1.95, 1.8]
        case .dipstick: [0.95, 1.95, 1.6]
        case .frontWheel: [2.6, 0.85, 2.5]
        case .windshield: [0, 2.35, 2.6]
        case .wiperArm: [0.95, 1.85, 1.6]
        case .dash: [-0.1, 1.45, 1.05]
        case .gloveBox: [-0.75, 1.3, 1.2]
        }
    }

    /// Body panels fade to glass so a hidden part shows through.
    var needsXRay: Bool {
        switch self {
        case .floor, .frontWheel, .windshield, .wiperArm, .drainPan: false
        default: true
        }
    }

    /// Radius of the glow that marks the part.
    var haloRadius: Float {
        switch self {
        case .floor: 0.5
        case .windshield: 0.35
        case .frontWheel: 0.4
        case .petcock, .oilCap, .dipstick: 0.08
        default: 0.14
        }
    }
}
