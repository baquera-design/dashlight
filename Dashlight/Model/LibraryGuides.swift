import CoreGraphics

// Guides 02–04 from the Dashlight plan's How-to library.
// Values marked verify still need checking against the owner's manual.

private enum Spot {
    static let floorFront = CGPoint(x: 0.88, y: 0.96)
    static let frontWheel = CGPoint(x: 0.87, y: 0.80)
    static let oilPan = CGPoint(x: 0.86, y: 0.86)
    static let oilFilter = CGPoint(x: 0.90, y: 0.72)
    static let oilCap = CGPoint(x: 0.85, y: 0.38)
    static let dipstick = CGPoint(x: 0.82, y: 0.40)
    static let driverSeat = CGPoint(x: 0.62, y: 0.42)
    static let windshield = CGPoint(x: 0.72, y: 0.33)
    static let wiperArm = CGPoint(x: 0.75, y: 0.38)
    static let gloveBox = CGPoint(x: 0.64, y: 0.52)
}

extension Guide {
    // MARK: 02 Oil change

    static let oilChange = Guide(
        id: "oil",
        kind: .oil,
        number: 2,
        eyebrow: "Guide 02 · Under the car",
        title: "Oil change",
        minutes: 60,
        difficulty: "Intermediate",
        platformTags: ["ford-c1-2.0-gdi"],
        intro: "Ramps up, mat down, and the oil goes from a valve through a hose into a closed jug. About an hour the first time, 30 minutes after.",
        cost: .init(
            diy: 40,
            shopLow: 70,
            shopHigh: 100,
            note: "Oil and filter only. The valve and ramps are one-time buys."
        ),
        beforeYouStart: "Engine warm, not hot: drive 5 minutes, then wait 10. Gloves on.",
        stopIf: [
            "The oil comes out milky or foamy.",
            "You see metal flakes in the oil or on the drain plug.",
            "The drain plug threads feel rough or won't snug down.",
            "The oil light stays on after the engine starts."
        ],
        caution: .init(
            title: "Ramps, never the jack",
            text: "Never reach under the car on the spare-tire jack or one jack stand. Ramps and wheel chocks only."
        ),
        specs: [
            .init(key: "Oil", value: "5W-20 synthetic blend", verify: true),
            .init(key: "Capacity with filter", value: "~4.5 qt", verify: true),
            .init(key: "Filter", value: "Motorcraft FL-910S", verify: true),
            .init(key: "Interval", value: "5,000 mi or 6 months")
        ],
        steps: [
            GuideStep(
                id: 1, phase: .contain,
                title: "Mat under the ramps",
                body: "Lay the drop sheet and mat under the front of the car, then set the ramps on top, lined up with the front tires.",
                minutes: 5,
                confirm: "Slide when the ramps are set",
                focus: Spot.floorFront, focusLabel: "Under the front"
            ),
            GuideStep(
                id: 2, phase: .contain,
                title: "Drive up the ramps",
                body: "Drive slowly up until the tires sit in the ramp cradles. Park, parking brake on, and chock both rear wheels.",
                caution: "Have someone guide you the first time. Stop if a ramp slides.",
                minutes: 5,
                confirm: "Slide when parked and chocked",
                focus: Spot.frontWheel, focusLabel: "Front tire on the ramp"
            ),
            GuideStep(
                id: 3, phase: .contain,
                title: "Pan under the drain plug",
                body: "Slide the lidded drain pan under the oil pan, slightly behind the drain plug. Oil shoots back as it starts.",
                minutes: 2,
                confirm: "Slide when the pan is in place",
                focus: Spot.oilPan, focusLabel: "Oil pan, drain plug", isHidden: true
            ),
            GuideStep(
                id: 4, phase: .work,
                title: "Loosen the filler cap",
                body: "Open the hood and loosen the oil filler cap. Letting air in makes the oil drain smoothly.",
                minutes: 1,
                confirm: "Slide when the cap is loose",
                focus: Spot.oilCap, focusLabel: "Oil filler cap", isHidden: true
            ),
            GuideStep(
                id: 5, phase: .work,
                title: "Drain the oil",
                body: "First time: unscrew the drain plug with the pan beneath it and let it drain. Every time after: push the hose onto the quick-drain valve, put the end in the jug and flip the lever open.",
                caution: "The oil is warm. Keep your arm out of the stream.",
                minutes: 10,
                confirm: "Slide when it's down to drips",
                focus: Spot.oilPan, focusLabel: "Drain plug", isHidden: true
            ),
            GuideStep(
                id: 6, phase: .work,
                title: "Fit the quick-drain valve",
                body: "First time only: wipe the threads, add the new washer and thread the quick-drain valve in by hand, then snug it with a wrench. Every time after: close the lever and pull the hose off over the pan.",
                caution: "Snug, not cranked. The pan threads are soft.",
                minutes: 5,
                confirm: "Slide when the valve is closed",
                focus: Spot.oilPan, focusLabel: "Quick-drain valve", isHidden: true
            ),
            GuideStep(
                id: 7, phase: .work,
                title: "Bag the old filter",
                body: "Slip a gallon zip bag up around the oil filter. Unscrew it inside the bag with the filter wrench, let it drop in, and seal the bag.",
                minutes: 5,
                confirm: "Slide when the filter is bagged",
                focus: Spot.oilFilter, focusLabel: "Oil filter", isHidden: true
            ),
            GuideStep(
                id: 8, phase: .work,
                title: "Fit the new filter",
                body: "Wipe the filter mount clean. Rub a dab of fresh oil on the new filter's gasket, spin it on until it touches, then three-quarters of a turn more by hand.",
                caution: "Check the old gasket came off with the old filter. Two gaskets will leak.",
                minutes: 3,
                confirm: "Slide when it's hand-tight",
                focus: Spot.oilFilter, focusLabel: "Oil filter", isHidden: true
            ),
            GuideStep(
                id: 9, phase: .work,
                title: "Fill with fresh oil",
                body: "Funnel in 4 quarts. Wait a minute, check the dipstick, then add a little at a time until it reads at the full mark.",
                minutes: 5,
                confirm: "Slide when it reads full",
                focus: Spot.dipstick, focusLabel: "Filler and dipstick", isHidden: true
            ),
            GuideStep(
                id: 10, phase: .work,
                title: "Run it and check for drips",
                body: "Cap on, start the engine and let it run 30 seconds. The oil light should go out. Look under the valve and filter for drips with a white paper towel.",
                caution: "If the oil light stays on, turn the engine off right away.",
                minutes: 2,
                confirm: "Slide when it's dry underneath",
                focus: Spot.driverSeat, focusLabel: "Start the engine"
            ),
            GuideStep(
                id: 11, phase: .work,
                title: "Recheck the level",
                body: "Engine off. Wait 2 minutes, then pull the dipstick, wipe, dip and read it again. Top up if it's below full.",
                minutes: 3,
                confirm: "Slide when it reads full",
                focus: Spot.dipstick, focusLabel: "Dipstick", isHidden: true
            ),
            GuideStep(
                id: 12, phase: .work,
                title: "Down off the ramps",
                body: "Take the chocks out, then back slowly down off the ramps. Look at the mat where the car sat: it should be clean.",
                minutes: 3,
                confirm: "Slide when you're back on the floor",
                focus: Spot.frontWheel, focusLabel: "Front tire"
            )
        ],
        cleanUp: [
            "Old oil funneled into the empty jugs, lids tight, labeled USED OIL.",
            "Filter bag sealed.",
            "Mat folded inward and bagged.",
            "Drop the oil and filter at any parts store (they take it free).",
            "Reset the oil life monitor in the dash menu."
        ],
        finishNote: .init(title: "Floor check", text: "Slide a white paper towel under the valve and filter. Clean towel, clean garage."),
        typicalQuarts: 4.5,
        isAvailable: true,
        specsTitle: "Engine oil",
        methodChip: "Zero-spill method",
        heroFocus: CGPoint(x: 0.86, y: 0.75)
    )

    // MARK: 03 Wiper blades

    static let wiperBlades = Guide(
        id: "wipers",
        kind: .wipers,
        number: 3,
        eyebrow: "Guide 03 · Windshield",
        title: "Wiper blades",
        minutes: 10,
        difficulty: "Beginner",
        platformTags: ["ford-c1"],
        intro: "No fluids, no tools. The only real risk is the arm snapping back onto the glass, so a folded towel goes down first.",
        cost: .init(
            diy: 40,
            shopLow: 60,
            shopHigh: 80,
            note: "A pair of beam blades. Your time: about 10 minutes."
        ),
        beforeYouStart: "Engine off, wipers parked. Check the sizes before you buy.",
        stopIf: [],
        caution: .init(
            title: "Towel on the glass",
            text: "A bare wiper arm springs back hard enough to crack the windshield. Keep a folded towel under it."
        ),
        specs: [
            .init(key: "Driver side", value: "26 in", verify: true),
            .init(key: "Passenger side", value: "18 in", verify: true),
            .init(key: "Interval", value: "6 to 12 months")
        ],
        steps: [
            GuideStep(
                id: 1, phase: .contain,
                title: "Towel on the windshield",
                body: "Fold a thick towel and lay it on the glass where the driver-side wiper arm rests.",
                minutes: 1,
                confirm: "Slide when the towel is down",
                focus: Spot.windshield, focusLabel: "Windshield"
            ),
            GuideStep(
                id: 2, phase: .work,
                title: "Lift the arm",
                body: "Pull the driver-side arm up and away from the glass until it stays up on its own.",
                minutes: 1,
                confirm: "Slide when the arm is up",
                focus: Spot.wiperArm, focusLabel: "Wiper arm"
            ),
            GuideStep(
                id: 3, phase: .work,
                title: "Take the old blade off",
                body: "Turn the blade so it sits at a right angle to the arm. Press the release tab and slide the blade down, off the hook.",
                caution: "Hold the arm as you work so it can't snap back.",
                minutes: 2,
                confirm: "Slide when it's off",
                focus: Spot.wiperArm, focusLabel: "Release tab"
            ),
            GuideStep(
                id: 4, phase: .work,
                title: "Clip the new blade on",
                body: "Slide the new blade's adapter up onto the hook until it clicks. Tug it to make sure it's locked.",
                minutes: 2,
                confirm: "Slide when it clicks",
                focus: Spot.wiperArm, focusLabel: "Hook"
            ),
            GuideStep(
                id: 5, phase: .work,
                title: "Lower it onto the towel",
                body: "Lower the arm gently onto the towel, then slide the towel out from under it.",
                minutes: 1,
                confirm: "Slide when it's down",
                focus: Spot.windshield, focusLabel: "Windshield"
            ),
            GuideStep(
                id: 6, phase: .work,
                title: "Do the passenger side",
                body: "Move the towel over and repeat on the passenger side with the shorter blade.",
                minutes: 3,
                confirm: "Slide when both are on",
                focus: Spot.windshield, focusLabel: "Passenger side"
            ),
            GuideStep(
                id: 7, phase: .work,
                title: "Test them",
                body: "Ignition on, spray washer fluid and run the wipers. They should clear in clean, quiet sweeps with no streaks or chatter.",
                minutes: 1,
                confirm: "Slide when they wipe clean",
                focus: Spot.driverSeat, focusLabel: "Wiper stalk"
            )
        ],
        cleanUp: [
            "Old blades in the new blades' box, into the trash.",
            "Towel back in the kit."
        ],
        finishNote: nil,
        typicalQuarts: nil,
        isAvailable: true,
        specsTitle: "Blades",
        methodChip: "No spill risk",
        heroFocus: CGPoint(x: 0.72, y: 0.35)
    )

    // MARK: 04 Cabin air filter

    static let cabinFilter = Guide(
        id: "cabinAir",
        kind: .cabinAir,
        number: 4,
        eyebrow: "Guide 04 · Inside the cabin",
        title: "Cabin air filter",
        minutes: 10,
        difficulty: "Beginner",
        platformTags: ["ford-c1"],
        intro: "Everything happens from the passenger seat. The one thing to get right is the airflow arrow on the new filter.",
        cost: .init(
            diy: 20,
            shopLow: 60,
            shopHigh: 90,
            note: "One filter. Your time: about 10 minutes."
        ),
        beforeYouStart: "Engine off. A flashlight and a handheld vacuum help.",
        stopIf: [],
        caution: .init(
            title: "Mind the arrow",
            text: "The filter only works one way. Note which way the old one's arrow points before you pull it out."
        ),
        specs: [
            .init(key: "Location", value: "Behind the glove box", verify: true),
            .init(key: "Filter", value: "Motorcraft FP-71", verify: true),
            .init(key: "Interval", value: "15,000 mi or yearly")
        ],
        steps: [
            GuideStep(
                id: 1, phase: .contain,
                title: "Empty the glove box",
                body: "Take everything out of the glove box and set it on the seat.",
                minutes: 1,
                confirm: "Slide when it's empty",
                focus: Spot.gloveBox, focusLabel: "Glove box", isHidden: true
            ),
            GuideStep(
                id: 2, phase: .work,
                title: "Let the glove box swing down",
                body: "Open it, then squeeze its sides inward or unhook the stops so it swings all the way down.",
                minutes: 2,
                confirm: "Slide when it's down",
                focus: Spot.gloveBox, focusLabel: "Glove box stops", isHidden: true
            ),
            GuideStep(
                id: 3, phase: .work,
                title: "Open the filter door",
                body: "Find the narrow cover behind the glove box. Unclip it and set it aside.",
                minutes: 1,
                confirm: "Slide when it's open",
                focus: Spot.gloveBox, focusLabel: "Filter door", isHidden: true
            ),
            GuideStep(
                id: 4, phase: .work,
                title: "Pull the old filter",
                body: "Note which way the airflow arrow points, then slide the old filter straight out. Leaves and dust come with it.",
                minutes: 1,
                confirm: "Slide when it's out",
                focus: Spot.gloveBox, focusLabel: "Cabin filter", isHidden: true
            ),
            GuideStep(
                id: 5, phase: .work,
                title: "Vacuum the slot",
                body: "Vacuum out any leaves or grit in the slot and around the floor below it.",
                minutes: 2,
                confirm: "Slide when it's clean",
                focus: Spot.gloveBox, focusLabel: "Filter slot", isHidden: true
            ),
            GuideStep(
                id: 6, phase: .work,
                title: "Slide the new filter in",
                body: "Arrow pointing the same way as the old one. Slide it in gently so the pleats don't fold.",
                caution: "Arrow the wrong way and the fan pushes dust straight into the cabin.",
                minutes: 1,
                confirm: "Slide when it's seated",
                focus: Spot.gloveBox, focusLabel: "Cabin filter", isHidden: true
            ),
            GuideStep(
                id: 7, phase: .work,
                title: "Close it all up",
                body: "Clip the filter door back on, lift the glove box until the stops catch, and put your things back.",
                minutes: 2,
                confirm: "Slide when it's closed",
                focus: Spot.gloveBox, focusLabel: "Glove box", isHidden: true
            ),
            GuideStep(
                id: 8, phase: .work,
                title: "Test the fan",
                body: "Ignition on, fan on high. Air should blow strong with no rattle and no dusty smell.",
                minutes: 1,
                confirm: "Slide when it blows clean",
                focus: Spot.driverSeat, focusLabel: "Fan controls"
            )
        ],
        cleanUp: [
            "Old filter bagged and in the trash.",
            "Glove box latched."
        ],
        finishNote: nil,
        typicalQuarts: nil,
        isAvailable: true,
        specsTitle: "Cabin filter",
        methodChip: "No spill risk",
        heroFocus: CGPoint(x: 0.64, y: 0.5)
    )
}
