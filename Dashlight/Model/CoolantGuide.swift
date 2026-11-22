import CoreGraphics

// Guide 01: Coolant drain-and-fill, apartment-garage edition.
// Content comes from the Dashlight plan (How-to library, section 1).
// Focus points are positions on the hero photo (side view, nose to the right).

private enum Spot {
    static let floorFront = CGPoint(x: 0.88, y: 0.96)
    static let petcock = CGPoint(x: 0.96, y: 0.78)
    static let degas = CGPoint(x: 0.84, y: 0.40)
    static let upperHose = CGPoint(x: 0.91, y: 0.47)
    static let driverSeat = CGPoint(x: 0.62, y: 0.42)
}

extension Guide {
    static let coolant = Guide(
        id: "coolant",
        kind: .coolant,
        number: 1,
        eyebrow: "Guide 01 · Under the hood",
        title: "Coolant drain-and-fill",
        minutes: 90,
        difficulty: "Beginner",
        platformTags: ["ford-c1-2.0-gdi"],
        intro: "Engine cold, mat down, nothing on the floor. We swap about half of the coolant with zero runoff.",
        cost: .init(
            diy: 50,
            shopLow: 130,
            shopHigh: 200,
            note: "Coolant only, if you own the kit. Your time: about 90 minutes."
        ),
        beforeYouStart: "About 90 minutes. Engine fully cold (sat overnight), car level. Nitrile gloves and eye protection on.",
        stopIf: [
            "The temperature gauge climbs above the middle.",
            "Coolant keeps going down between checks.",
            "You smell something sweet in the cabin or see fog inside the windshield.",
            "The old coolant comes out brown, rusty or sludgy.",
            "The oil looks milky."
        ],
        caution: .init(
            title: "Cold engine only",
            text: "The cap is pressurized when hot. Coolant tastes sweet and is poisonous to pets, so nothing sits open."
        ),
        specs: [
            .init(key: "Coolant", value: "Motorcraft Orange, premix"),
            .init(key: "System capacity", value: "~6.5 qt", verify: true),
            .init(key: "One drain gets", value: "~3 qt")
        ],
        steps: [
            GuideStep(
                id: 1, phase: .contain,
                title: "Lay the drop sheet and mat",
                body: "Plastic drop sheet first, absorbent mat on top. Cover the floor under the front of the car, 2 ft past the bumper on each side.",
                minutes: 5,
                confirm: "Slide when the floor is covered",
                focus: Spot.floorFront, focusLabel: "Under the front"
            ),
            GuideStep(
                id: 2, phase: .contain,
                title: "Set the drain pan",
                body: "Slide the lidded drain pan (2 gal or more) under the radiator's lower driver-side corner.",
                minutes: 2,
                confirm: "Slide when the pan is in place",
                focus: Spot.petcock, focusLabel: "Radiator, lower corner", isHidden: true
            ),
            GuideStep(
                id: 3, phase: .contain,
                title: "Fit the vinyl tube",
                body: "Push the clear vinyl tube onto the radiator drain petcock and drop its other end into the pan. Coolant flows down the tube, not across the splash shield.",
                caution: "Keep the tube end below the pan lip the whole time.",
                minutes: 3,
                confirm: "Slide when the tube is on",
                focus: Spot.petcock, focusLabel: "Drain petcock", isHidden: true
            ),
            GuideStep(
                id: 4, phase: .work,
                title: "Check the degas bottle",
                body: "Open the hood. Find the degas bottle, the coolant reservoir, and note where the level sits.",
                minutes: 2,
                confirm: "Slide when you've found it",
                focus: Spot.degas, focusLabel: "Degas bottle", isHidden: true
            ),
            GuideStep(
                id: 5, phase: .work,
                title: "Crack the degas cap",
                body: "Loosen the cap a quarter turn and wait 10 seconds, then take it off. Letting air in makes the drain flow smoothly.",
                caution: "Only on a cold engine. A warm system is under pressure.",
                minutes: 1,
                confirm: "Slide when the cap is off",
                focus: Spot.degas, focusLabel: "Degas cap", isHidden: true
            ),
            GuideStep(
                id: 6, phase: .work,
                title: "Find the drain petcock",
                body: "From the front, under the bumper, find the plastic drain petcock on the radiator's lower corner. The tube you fitted is on it.",
                caution: "Its exact spot on Astrid is still to verify. If it doesn't match, stop and tell me.",
                minutes: 2,
                confirm: "Slide when you see it",
                focus: Spot.petcock, focusLabel: "Drain petcock", isHidden: true
            ),
            GuideStep(
                id: 7, phase: .work,
                title: "Open the drain petcock",
                body: "With the tube on the petcock and its end in the pan, turn the petcock about two turns counterclockwise. Let it drain fully.",
                caution: "Keep the tube end below the pan lip. If it pops off, close the petcock first, then refit.",
                minutes: 10,
                confirm: "Slide when drained",
                focus: Spot.petcock, focusLabel: "Drain petcock", isHidden: true
            ),
            GuideStep(
                id: 8, phase: .work,
                title: "Close the petcock",
                body: "Close the petcock hand-tight. Pull the tube off over the pan so the last drips land in it.",
                caution: "Hand-tight only. The petcock is plastic and cracks if forced.",
                minutes: 2,
                confirm: "Slide when it's closed",
                focus: Spot.petcock, focusLabel: "Drain petcock", isHidden: true
            ),
            GuideStep(
                id: 9, phase: .work,
                title: "Bottle the old coolant",
                body: "Put the lid on the pan. Funnel the old coolant into the empty coolant jugs and label them USED COOLANT.",
                minutes: 5,
                confirm: "Slide when it's bottled",
                focus: Spot.floorFront, focusLabel: "Drain pan"
            ),
            GuideStep(
                id: 10, phase: .work,
                title: "Seat the funnel and fill",
                body: "Seat the spill-free funnel on the degas bottle. Pour fresh Motorcraft Orange premix slowly until the funnel is about one-third full.",
                minutes: 5,
                confirm: "Slide when the funnel is one-third full",
                focus: Spot.degas, focusLabel: "Spill-free funnel", isHidden: true
            ),
            GuideStep(
                id: 11, phase: .work,
                title: "Idle to bleed the air",
                body: "Start the engine. Heat on max, fan on low. Let it idle 10 to 15 minutes. Air bubbles up into the funnel instead of onto the floor.",
                caution: "Stay with the car. If the temperature gauge climbs past the middle, turn it off.",
                minutes: 15,
                confirm: "Slide after 10 to 15 minutes",
                focus: Spot.driverSeat, focusLabel: "Heat max, fan low"
            ),
            GuideStep(
                id: 12, phase: .work,
                title: "Squeeze the upper hose",
                body: "Gently squeeze the upper radiator hose a few times to push out trapped air. Watch for bubbles in the funnel.",
                caution: "The hose warms up as the engine runs. Gloves on, squeeze gently.",
                minutes: 2,
                confirm: "Slide when bubbles slow",
                focus: Spot.upperHose, focusLabel: "Upper radiator hose", isHidden: true
            ),
            GuideStep(
                id: 13, phase: .work,
                title: "Engine off, plug the funnel",
                body: "When the bubbles stop and the vents blow hot, turn the engine off. Plug the funnel, lift it out and set it in its stand.",
                minutes: 3,
                confirm: "Slide when the funnel is out",
                focus: Spot.degas, focusLabel: "Spill-free funnel", isHidden: true
            ),
            GuideStep(
                id: 14, phase: .work,
                title: "Top up to MAX",
                body: "Once it's cool, top up the degas bottle to the MAX line and cap it tight.",
                minutes: 3,
                confirm: "Slide when it's capped",
                focus: Spot.degas, focusLabel: "Degas bottle, MAX line", isHidden: true
            )
        ],
        cleanUp: [
            "Wipe the petcock dry.",
            "White paper towel under the radiator: no new drops.",
            "Fold the mat inward and bag it.",
            "Jugs labeled USED COOLANT, lids tight.",
            "Recheck the level cold tomorrow morning."
        ],
        finishNote: .init(title: "Floor check", text: "Slide a white paper towel under the radiator. If it comes back clean, you're done."),
        typicalQuarts: 3,
        isAvailable: true,
        specsTitle: "Cooling system",
        methodChip: "Zero-spill method",
        heroFocus: CGPoint(x: 0.9, y: 0.55)
    )
}
