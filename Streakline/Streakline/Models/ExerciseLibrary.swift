import Foundation

/// Hardcoded exercise data with full guidance content for the guide focus mode.
/// Symbols are limited to SF Symbols available on iOS 17.
extension WorkoutDay {

    // MARK: - Day A — Run + glute circuit

    static let dayAExercises: [Exercise] = [
        Exercise(
            name: "5km Run",
            prescription: "1 x 5km",
            note: "Steady, controlled effort — aim to beat last week's time",
            symbol: "figure.run",
            steps: [
                "Warm up with 5 minutes of easy jogging.",
                "Settle into a steady pace you could just about hold a conversation at.",
                "Aim for even splits — don't bank time early.",
                "Push the final kilometre, then walk 3 minutes to cool down.",
            ],
            cues: ["Relaxed shoulders", "Quick, light steps", "Rhythmic breathing"],
            mistakes: [
                "Starting too fast and fading in the back half.",
                "Overstriding — landing with your foot far ahead of your hips.",
                "Skipping the warm-up.",
            ]
        ),
        Exercise(
            name: "Glute Bridge",
            prescription: "3 x 20",
            note: "2-second pause at top, drive hips up",
            symbol: "figure.core.training",
            steps: [
                "Lie on your back, knees bent, feet flat and hip-width apart.",
                "Drive through your heels and lift your hips until knees, hips and shoulders form a line.",
                "Pause for 2 seconds at the top, squeezing your glutes hard.",
                "Lower with control and repeat.",
            ],
            cues: ["Ribs down", "Push through heels", "Squeeze at the top"],
            mistakes: [
                "Arching the lower back instead of extending the hips.",
                "Bouncing reps without a pause.",
                "Letting the knees fall in or out.",
            ]
        ),
        Exercise(
            name: "Single-leg Hip Thrust",
            prescription: "3 x 12 each",
            note: "Shoulders on a bench or sofa edge, other leg extended",
            symbol: "figure.strengthtraining.functional",
            steps: [
                "Rest your upper back on a bench or sofa edge, one foot planted, the other leg extended.",
                "Drive through the planted heel until your thigh and torso form a straight line.",
                "Pause at the top, hips square.",
                "Lower slowly and repeat, then switch sides.",
            ],
            cues: ["Chin tucked", "Hips square", "Full extension"],
            mistakes: [
                "Arching the back to fake range.",
                "Planting the foot too far from your hips.",
                "Rushing the lowering phase.",
            ]
        ),
        Exercise(
            name: "Lateral Band Walk",
            prescription: "3 x 15 each",
            note: "Resistance band above knees, stay low",
            symbol: "figure.step.training",
            steps: [
                "Place a resistance band just above your knees.",
                "Sit into a quarter squat, feet hip-width apart.",
                "Step sideways, leading with the knee, keeping band tension.",
                "Complete all reps one way, then return the other way.",
            ],
            cues: ["Stay low", "Toes forward", "Constant tension"],
            mistakes: [
                "Standing up tall between steps.",
                "Dragging the trailing leg so the band goes slack.",
                "Letting the knees cave inward.",
            ]
        ),
        Exercise(
            name: "Clamshells",
            prescription: "3 x 15 each",
            note: "Side-lying, keep hips stacked",
            symbol: "figure.pilates",
            steps: [
                "Lie on your side, knees bent to 90 degrees, heels together.",
                "Keeping heels touching, open your top knee like a clamshell.",
                "Pause at the top without rolling your hips back.",
                "Close slowly and repeat, then switch sides.",
            ],
            cues: ["Hips stacked", "Core braced", "Move from the hip"],
            mistakes: [
                "Rolling the pelvis backward to lift higher.",
                "Using momentum instead of the glute.",
            ]
        ),
        Exercise(
            name: "KB Single-leg RDL",
            prescription: "3 x 10 each",
            note: "Light kettlebell, hinge at hip, soft standing knee",
            symbol: "figure.strengthtraining.traditional",
            steps: [
                "Hold a light kettlebell in one hand and stand on the opposite leg.",
                "Hinge at the hip, letting the kettlebell travel straight down.",
                "Lower until you feel a hamstring stretch, back flat.",
                "Drive your hips forward to stand tall, then switch sides.",
            ],
            cues: ["Soft standing knee", "Square hips", "Long, flat spine"],
            mistakes: [
                "Rounding the back to reach lower.",
                "Twisting the hips open as you hinge.",
                "Locking out the standing knee.",
            ]
        ),
    ]

    // MARK: - Day B — Full-body weights

    static let dayBExercises: [Exercise] = [
        Exercise(
            name: "Romanian Deadlift",
            prescription: "4 x 10",
            note: "Hinge at hips, soft knees, feel the hamstring stretch",
            symbol: "figure.strengthtraining.traditional",
            steps: [
                "Stand tall with the weight at your thighs, feet hip-width.",
                "Push your hips back and let the weight slide down your legs.",
                "Lower until you feel a deep hamstring stretch, back flat.",
                "Drive your hips forward to stand — squeeze the glutes at the top.",
            ],
            cues: ["Shoulders packed", "Weight close to body", "Hinge, don't squat"],
            mistakes: [
                "Bending the knees too much and turning it into a squat.",
                "Rounding the lower back near the bottom.",
                "Leaning back at the top.",
            ]
        ),
        Exercise(
            name: "Bulgarian Split Squat",
            prescription: "3 x 10 each",
            note: "Rear foot elevated, front knee tracks over toes",
            symbol: "figure.cross.training",
            steps: [
                "Place your rear foot on a bench, front foot a big step ahead.",
                "Lower straight down until the rear knee hovers near the floor.",
                "Drive through the front heel to stand.",
                "Finish the set, then switch legs.",
            ],
            cues: ["Slight forward lean", "Knee tracks toes", "Control the descent"],
            mistakes: [
                "Front foot too close, forcing the knee far past the toes.",
                "Bouncing out of the bottom.",
                "Pushing off the back foot.",
            ]
        ),
        Exercise(
            name: "Single-leg Press",
            prescription: "3 x 12 each",
            note: "Full range, drive through heel",
            symbol: "figure.strengthtraining.traditional",
            steps: [
                "Sit in the leg press with one foot centred on the platform.",
                "Lower the sled with control until the knee reaches about 90 degrees.",
                "Press through the heel without locking the knee.",
                "Finish the set, then switch legs.",
            ],
            cues: ["Whole foot in contact", "Knee tracks toes", "Slow lowering"],
            mistakes: [
                "Cutting the range short.",
                "Slamming into a locked knee at the top.",
                "Letting the hips lift off the pad.",
            ]
        ),
        Exercise(
            name: "Cable Pull-Through",
            prescription: "3 x 15",
            note: "Drive hips forward, squeeze glutes at top",
            symbol: "figure.strengthtraining.functional",
            steps: [
                "Face away from a low cable with the rope between your legs.",
                "Hinge at the hips and let the rope pull back through.",
                "Drive your hips forward to stand tall.",
                "Squeeze the glutes hard at the top and repeat.",
            ],
            cues: ["Arms relaxed", "Flat back", "Hips do the work"],
            mistakes: [
                "Squatting instead of hinging.",
                "Pulling with the arms.",
                "Hyperextending the back at the top.",
            ]
        ),
        Exercise(
            name: "Plank",
            prescription: "3 x 45-60s",
            note: "Posterior pelvic tilt, ribs down, glutes squeezed",
            symbol: "figure.core.training",
            steps: [
                "Set your forearms down with elbows under shoulders.",
                "Form a straight line from head to heels.",
                "Tuck your pelvis, squeeze your glutes, and brace your core.",
                "Hold while breathing steadily.",
            ],
            cues: ["Ribs down", "Glutes squeezed", "Keep breathing"],
            mistakes: [
                "Letting the hips sag.",
                "Piking the hips up to make it easier.",
                "Holding your breath.",
            ]
        ),
        Exercise(
            name: "Pallof Press",
            prescription: "3 x 12 each",
            note: "Anti-rotation — resist the cable, don't rotate",
            symbol: "figure.core.training",
            steps: [
                "Stand side-on to a cable set at chest height.",
                "Hold the handle at your chest with both hands.",
                "Press straight out, resisting the pull to rotate.",
                "Return to your chest with control, then switch sides.",
            ],
            cues: ["Shoulders square", "Brace hard", "Slow and controlled"],
            mistakes: [
                "Letting the torso rotate toward the machine.",
                "Drifting the arms sideways.",
                "Leaning away instead of bracing.",
            ]
        ),
    ]

    // MARK: - Day C — Long run (run weeks)

    static let dayCRunExercises: [Exercise] = [
        Exercise(
            name: "7-8km Run",
            prescription: "1 x 7-8km",
            note: "Comfortable conversational pace, not a race",
            symbol: "figure.run",
            steps: [
                "Warm up with 5 minutes of very easy jogging.",
                "Settle into a fully conversational pace and keep it there.",
                "Keep the effort even on hills — slow down going up.",
                "Finish relaxed and walk a few minutes to cool down.",
            ],
            cues: ["Conversational pace", "Relaxed arms", "Even effort"],
            mistakes: [
                "Turning it into a race — this run builds your base.",
                "Skipping water on warm days.",
                "Overstriding on downhills.",
            ]
        ),
        Exercise(
            name: "Jump Squat",
            prescription: "3 x 15",
            note: "Explode up, land soft with bent knees",
            symbol: "figure.cross.training",
            steps: [
                "Stand with feet shoulder-width apart.",
                "Dip into a quarter-to-half squat.",
                "Explode upward, fully extending your hips.",
                "Land softly, toes-to-heel, straight into the next rep.",
            ],
            cues: ["Land soft", "Chest up", "Full hip extension"],
            mistakes: [
                "Landing stiff-legged.",
                "Letting the knees cave on landing.",
            ]
        ),
        Exercise(
            name: "Mountain Climbers",
            prescription: "3 x 20 each",
            note: "Hips level, don't let them pike up",
            symbol: "figure.core.training",
            steps: [
                "Start in a high plank, shoulders over wrists.",
                "Drive one knee toward your chest.",
                "Switch legs quickly, keeping your hips level.",
                "Keep a steady rhythm for all reps.",
            ],
            cues: ["Shoulders over wrists", "Hips level", "Steady rhythm"],
            mistakes: [
                "Piking the hips up as you fatigue.",
                "Bouncing on the toes instead of driving the knees.",
            ]
        ),
        Exercise(
            name: "Feet-elevated Hip Thrust",
            prescription: "3 x 15",
            note: "Feet on a bench or sofa, back on floor, full hip extension",
            symbol: "figure.strengthtraining.functional",
            steps: [
                "Lie on the floor with your feet up on a bench or sofa.",
                "Drive through your heels and lift your hips to full extension.",
                "Pause and squeeze the glutes at the top.",
                "Lower slowly and repeat.",
            ],
            cues: ["Drive through heels", "Ribs down", "Squeeze at the top"],
            mistakes: [
                "Pushing through the toes.",
                "Hyperextending the lower back.",
                "Cutting the range short.",
            ]
        ),
        Exercise(
            name: "Dead Bug",
            prescription: "3 x 10 each",
            note: "Opposite arm/leg, lower back pressed to floor",
            symbol: "figure.pilates",
            steps: [
                "Lie on your back, arms up, knees stacked over hips at 90 degrees.",
                "Lower your opposite arm and leg toward the floor.",
                "Stop just before your lower back lifts, then return.",
                "Alternate sides with slow control.",
            ],
            cues: ["Back pressed down", "Exhale as you extend", "Move slowly"],
            mistakes: [
                "Letting the lower back arch off the floor.",
                "Moving both legs at once.",
                "Rushing the reps.",
            ]
        ),
    ]

    // MARK: - Day C — Circuit (circuit weeks)

    static let dayCCircuitExercises: [Exercise] = [
        Exercise(
            name: "KB Swings",
            prescription: "4 x 20",
            note: "Kettlebell — explosive hip drive, not a squat",
            symbol: "figure.strengthtraining.functional",
            steps: [
                "Stand over the kettlebell, feet shoulder-width apart.",
                "Hinge and hike the bell back between your legs.",
                "Snap your hips forward — the bell floats to chest height.",
                "Let it swing back down into the next rep.",
            ],
            cues: ["Hips, not arms", "Flat back", "Exhale at the top"],
            mistakes: [
                "Squatting the swing instead of hinging.",
                "Lifting with the shoulders.",
                "Leaning back at the top.",
            ]
        ),
        dayCRunExercises[1],  // Jump Squat
        dayCRunExercises[2],  // Mountain Climbers
        dayCRunExercises[3],  // Feet-elevated Hip Thrust
        dayCRunExercises[4],  // Dead Bug
    ]
}
