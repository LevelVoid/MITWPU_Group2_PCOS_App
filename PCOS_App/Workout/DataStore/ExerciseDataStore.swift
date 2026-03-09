//
//  DataStore.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

//
//  DataStore.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

import Foundation

class ExerciseDataStore {
    static let shared = ExerciseDataStore()
    
    private init() {}
    
    // MARK: - Hardcoded Exercises
    let allExercises: [Exercise] = [

    Exercise(
    name: "Plank",
    muscleGroup: .core,
    equipment: .none,
    image: "plank",
    instructions: "Hold your body in a straight line supported by forearms and toes.",
    gifUrl: "Plankgif.gif",
    level: "Beginner",
    tempo: "Hold 20–60s",
    form: [
    "Keep body straight from head to heels",
    "Engage core and glutes",
    "Keep neck neutral"
    ],
    variations: [
    "Side plank",
    "Plank with leg lift"
    ],
    commonMistakes: [
    "Hips sagging",
    "Raising hips too high",
    "Looking forward and straining neck"
    ]
    ),

    Exercise(
    name: "Bent Over Row",
    muscleGroup: .back,
    equipment: .barbell,
    image: "bent_row",
    instructions: "Hinge at hips and pull the bar toward your torso while keeping the back neutral.",
    gifUrl: "bent_rowgif.gif",
    level: "Intermediate",
    tempo: "2s pull, 2s lower",
    form: [
    "Hinge from hips",
    "Keep bar close to body",
    "Lead pull with elbows"
    ],
    variations: [
    "Underhand row",
    "Single-arm dumbbell row"
    ],
    commonMistakes: [
    "Rounding the back",
    "Standing too upright",
    "Using momentum"
    ]
    ),

    Exercise(
    name: "Bhujangasana",
    muscleGroup: .mobility,
    equipment: .none,
    image: "bhujangasana",
    instructions: "Press chest upward while keeping hips grounded.",
    gifUrl: "bhujangasanagif.gif",
    level: "Beginner",
    tempo: "Hold 15–30s",
    form: [
    "Press palms into mat",
    "Lift chest gently",
    "Keep shoulders relaxed"
    ],
    variations: [
    "Baby cobra",
    "Upward dog"
    ],
    commonMistakes: [
    "Overarching lower back",
    "Locking elbows",
    "Lifting hips off mat"
    ]
    ),

    Exercise(
    name: "Bicycle Crunch",
    muscleGroup: .core,
    equipment: .none,
    image: "bicycle",
    instructions: "Alternate elbow to opposite knee while extending the other leg.",
    gifUrl: "bicyclegif.gif",
    level: "Beginner",
    tempo: "1–2s per rep",
    form: [
    "Keep lower back pressed down",
    "Rotate torso not just elbows",
    "Control movement"
    ],
    variations: [
    "Slow bicycle crunch",
    "Weighted bicycle crunch"
    ],
    commonMistakes: [
    "Pulling neck",
    "Moving too fast",
    "Arching lower back"
    ]
    ),

    Exercise(
    name: "Bird Dog",
    muscleGroup: .core,
    equipment: .none,
    image: "bird_dog",
    instructions: "Extend opposite arm and leg while stabilizing your core.",
    gifUrl: "bird_doggif.gif",
    level: "Beginner",
    tempo: "2s extend, 2s hold",
    form: [
    "Keep hips square",
    "Maintain neutral spine",
    "Extend fully"
    ],
    variations: [
    "Bird dog hold",
    "Weighted bird dog"
    ],
    commonMistakes: [
    "Rotating hips",
    "Arching back",
    "Moving too quickly"
    ]
    ),

    Exercise(
    name: "Bow Pose",
    muscleGroup: .mobility,
    equipment: .none,
    image: "bow_pose",
    instructions: "Grab ankles and lift chest and thighs off the floor.",
    gifUrl: "bow_posegif.gif",
    level: "Intermediate",
    tempo: "Hold 15–30s",
    form: [
    "Press feet into hands",
    "Lift chest upward",
    "Keep breathing steady"
    ],
    variations: [
    "Half bow",
    "Rocking bow"
    ],
    commonMistakes: [
    "Holding breath",
    "Overarching neck",
    "Forcing the stretch"
    ]
    ),

    Exercise(
    name: "Butterfly Stretch",
    muscleGroup: .mobility,
    equipment: .none,
    image: "butterfly",
    instructions: "Sit with feet together and gently press knees toward the floor.",
    gifUrl: "butterflygif.gif",
    level: "Beginner",
    tempo: "Hold 20–40s",
    form: [
    "Keep spine upright",
    "Relax hips",
    "Press knees gently"
    ],
    variations: [
    "Forward fold butterfly",
    "Dynamic butterfly"
    ],
    commonMistakes: [
    "Rounding back",
    "Forcing knees down",
    "Bouncing knees aggressively"
    ]
    ),

    Exercise(
    name: "Cable Row",
    muscleGroup: .back,
    equipment: .machine,
    image: "cable_row",
    instructions: "Pull cable handle toward torso while keeping chest lifted.",
    gifUrl: "cable_rowgif.gif",
    level: "Beginner",
    tempo: "2s pull, 2s return",
    form: [
    "Keep chest tall",
    "Squeeze shoulder blades",
    "Pull elbows back"
    ],
    variations: [
    "Wide grip row",
    "Single arm cable row"
    ],
    commonMistakes: [
    "Leaning too far back",
    "Rounding shoulders",
    "Jerking weight"
    ]
    ),

    Exercise(
    name: "Cat Cow",
    muscleGroup: .mobility,
    equipment: .none,
    image: "cat_cow",
    instructions: "Alternate between arching and rounding the spine.",
    gifUrl: "cat_cowgif.gif",
    level: "Beginner",
    tempo: "Slow breathing rhythm",
    form: [
    "Inhale arch spine",
    "Exhale round spine",
    "Move slowly"
    ],
    variations: [
    "Thread the needle",
    "Cat cow hold"
    ],
    commonMistakes: [
    "Rushing movement",
    "Overextending neck"
    ]
    ),

    Exercise(
    name: "Child Pose",
    muscleGroup: .mobility,
    equipment: .none,
    image: "child_pose",
    instructions: "Sit back on heels and stretch arms forward.",
    gifUrl: "child_posegif.gif",
    level: "Beginner",
    tempo: "Hold 20–40s",
    form: [
    "Relax hips",
    "Stretch arms forward",
    "Forehead to mat"
    ],
    variations: [
    "Side child pose",
    "Wide knee child pose"
    ],
    commonMistakes: [
    "Lifting hips",
    "Rounding shoulders"
    ]
    ),
    Exercise(
    name: "Deadlift",
    muscleGroup: .back,
    equipment: .barbell,
    image: "deadlift",
    instructions: "Lift the bar from the floor by extending hips and knees while keeping your spine neutral.",
    gifUrl: "deadliftgif.gif",
    level: "Intermediate",
    tempo: "2s lift, 2s lower",
    form: [
    "Keep bar close to legs",
    "Drive through heels",
    "Maintain neutral spine"
    ],
    variations: [
    "Romanian deadlift",
    "Sumo deadlift"
    ],
    commonMistakes: [
    "Rounding lower back",
    "Jerking the bar off the floor",
    "Hyperextending at the top"
    ]
    ),

    Exercise(
    name: "Downward Dog",
    muscleGroup: .mobility,
    equipment: .none,
    image: "downward_dog",
    instructions: "Lift hips upward forming an inverted V shape.",
    gifUrl: "downward_doggif.gif",
    level: "Beginner",
    tempo: "Hold 20–40s",
    form: [
    "Press heels toward floor",
    "Keep arms straight",
    "Lengthen spine"
    ],
    variations: [
    "Bent knee downward dog",
    "Three leg downward dog"
    ],
    commonMistakes: [
    "Rounding back",
    "Collapsing shoulders",
    "Heels forced down excessively"
    ]
    ),

    Exercise(
    name: "Elliptical Trainer",
    muscleGroup: .cardio,
    equipment: .machine,
    image: "elliptical",
    instructions: "Move arms and legs smoothly on the elliptical trainer.",
    gifUrl: "ellipticalgif.gif",
    level: "Beginner",
    tempo: "Steady continuous pace",
    form: [
    "Keep torso upright",
    "Push and pull handles evenly",
    "Maintain smooth rhythm"
    ],
    variations: [
    "Reverse pedaling",
    "Interval training"
    ],
    commonMistakes: [
    "Leaning heavily on handles",
    "Moving too fast",
    "Locking knees"
    ]
    ),

    Exercise(
    name: "Face Pulls",
    muscleGroup: .shoulders,
    equipment: .machine,
    image: "face_pulls",
    instructions: "Pull rope attachment toward your face while squeezing upper back.",
    gifUrl: "face_pullsgif.gif",
    level: "Beginner",
    tempo: "1s pull, 2s return",
    form: [
    "Keep elbows high",
    "Squeeze shoulder blades",
    "Keep chest tall"
    ],
    variations: [
    "Single arm face pull",
    "Band face pull"
    ],
    commonMistakes: [
    "Using too much weight",
    "Shrugging shoulders",
    "Pulling with arms only"
    ]
    ),

    Exercise(
    name: "Glute Bridge",
    muscleGroup: .glutes,
    equipment: .none,
    image: "glute_bridge",
    instructions: "Lift hips upward by squeezing glutes while keeping shoulders on floor.",
    gifUrl: "glute_bridgegif.gif",
    level: "Beginner",
    tempo: "1s up, 2s down",
    form: [
    "Push through heels",
    "Engage glutes at top",
    "Keep core braced"
    ],
    variations: [
    "Single leg glute bridge",
    "Banded glute bridge"
    ],
    commonMistakes: [
    "Overarching back",
    "Feet too far from hips",
    "Not squeezing glutes"
    ]
    ),

    Exercise(
    name: "Hammer Curl",
    muscleGroup: .arms,
    equipment: .dumbbell,
    image: "hammer_curl",
    instructions: "Curl dumbbells upward with palms facing each other.",
    gifUrl: "hammer_curlgif.gif",
    level: "Beginner",
    tempo: "1s up, 2s down",
    form: [
    "Keep elbows close to torso",
    "Maintain neutral wrist",
    "Control the descent"
    ],
    variations: [
    "Cross body hammer curl",
    "Cable hammer curl"
    ],
    commonMistakes: [
    "Swinging weights",
    "Using momentum",
    "Shrugging shoulders"
    ]
    ),

    Exercise(
    name: "Hip Rotation",
    muscleGroup: .mobility,
    equipment: .none,
    image: "hip_rotation",
    instructions: "Rotate hips slowly to improve mobility.",
    gifUrl: "hip_rotationgif.gif",
    level: "Beginner",
    tempo: "Controlled circular motion",
    form: [
    "Keep torso stable",
    "Move through full hip range",
    "Move slowly"
    ],
    variations: [
    "Standing hip circles",
    "Quadruped hip rotation"
    ],
    commonMistakes: [
    "Arching lower back",
    "Rushing movement",
    "Rotating torso excessively"
    ]
    ),

    Exercise(
    name: "Incline Treadmill Walk",
    muscleGroup: .cardio,
    equipment: .machine,
    image: "incline_treadmill",
    instructions: "Walk on treadmill with incline to increase intensity.",
    gifUrl: "incline_treadmillgif.gif",
    level: "Beginner",
    tempo: "Steady pace",
    form: [
    "Keep posture upright",
    "Swing arms naturally",
    "Step evenly"
    ],
    variations: [
    "Incline intervals",
    "Power walk incline"
    ],
    commonMistakes: [
    "Holding rails constantly",
    "Leaning forward",
    "Taking uneven steps"
    ]
    ),

    Exercise(
    name: "Jump Rope",
    muscleGroup: .cardio,
    equipment: .none,
    image: "jump_rope",
    instructions: "Jump lightly while rotating rope under feet.",
    gifUrl: "jump_ropegif.gif",
    level: "Beginner",
    tempo: "Fast rhythmic",
    form: [
    "Jump lightly",
    "Rotate rope with wrists",
    "Maintain steady rhythm"
    ],
    variations: [
    "Single leg jumps",
    "Double unders"
    ],
    commonMistakes: [
    "Jumping too high",
    "Using arms instead of wrists",
    "Landing heavily"
    ]
    ),

    Exercise(
    name: "Jumping Jacks",
    muscleGroup: .cardio,
    equipment: .none,
    image: "jumping_jacks",
    instructions: "Jump feet apart while raising arms overhead.",
    gifUrl: "jumping_jacksgif.gif",
    level: "Beginner",
    tempo: "Fast pace",
    form: [
    "Land softly",
    "Move arms fully overhead",
    "Maintain rhythm"
    ],
    variations: [
    "Half jacks",
    "Weighted jacks"
    ],
    commonMistakes: [
    "Landing too hard",
    "Shrugging shoulders",
    "Losing coordination"
    ]
    ),
    Exercise(
    name: "Lat Pulldown",
    muscleGroup: .back,
    equipment: .machine,
    image: "lat_pulldown",
    instructions: "Pull the bar toward upper chest while engaging lats.",
    gifUrl: "lat_pulldownsgif.gif",
    level: "Beginner",
    tempo: "2s pull, 2s return",
    form: [
    "Lean slightly back",
    "Drive elbows downward",
    "Squeeze lats"
    ],
    variations: [
    "Reverse grip pulldown",
    "Close grip pulldown"
    ],
    commonMistakes: [
    "Pulling behind neck",
    "Using momentum",
    "Shrugging shoulders"
    ]
    ),

    Exercise(
    name: "Lateral Raises",
    muscleGroup: .shoulders,
    equipment: .dumbbell,
    image: "lateral_raises",
    instructions: "Raise dumbbells to shoulder height with arms slightly bent.",
    gifUrl: "lateral_raisesgif.gif",
    level: "Beginner",
    tempo: "1s up, 2s down",
    form: [
    "Lead with elbows",
    "Keep slight bend in arms",
    "Pause at top"
    ],
    variations: [
    "Cable lateral raise",
    "Seated lateral raise"
    ],
    commonMistakes: [
    "Swinging weights",
    "Shrugging shoulders",
    "Using too heavy weight"
    ]
    ),

    Exercise(
    name: "Leg Extension",
    muscleGroup: .legs,
    equipment: .machine,
    image: "leg_extension",
    instructions: "Extend knees upward against resistance.",
    gifUrl: "leg_extensiongif.gif",
    level: "Beginner",
    tempo: "1s extend, 2s lower",
    form: [
    "Squeeze quads at top",
    "Control the descent",
    "Keep back against pad"
    ],
    variations: [
    "Single leg extension",
    "Drop sets"
    ],
    commonMistakes: [
    "Kicking weight up",
    "Using momentum",
    "Too much weight"
    ]
    ),

    Exercise(
    name: "Leg Press",
    muscleGroup: .legs,
    equipment: .machine,
    image: "leg_press",
    instructions: "Push platform away using legs while keeping feet flat.",
    gifUrl: "leg_pressgif.gif",
    level: "Beginner",
    tempo: "2s press, 2s return",
    form: [
    "Keep knees aligned with toes",
    "Control range of motion",
    "Avoid locking knees"
    ],
    variations: [
    "Single leg press",
    "High foot placement"
    ],
    commonMistakes: [
    "Locking knees",
    "Too shallow reps",
    "Using excessive weight"
    ]
    ),

    Exercise(
    name: "Leg Raises",
    muscleGroup: .core,
    equipment: .none,
    image: "leg_raises",
    instructions: "Lift legs upward while lying flat keeping core tight.",
    gifUrl: "leg_raisesgif.gif",
    level: "Beginner",
    tempo: "2s up, 2s down",
    form: [
    "Keep lower back pressed down",
    "Move legs slowly",
    "Engage core"
    ],
    variations: [
    "Hanging leg raises",
    "Bent knee raises"
    ],
    commonMistakes: [
    "Arching back",
    "Using momentum"
    ]
    ),

    Exercise(
    name: "Lunges",
    muscleGroup: .legs,
    equipment: .none,
    image: "lunges",
    instructions: "Step forward and lower until both knees are about 90 degrees.",
    gifUrl: "lungesgif.gif",
    level: "Beginner",
    tempo: "1s down, 1s up",
    form: [
    "Keep torso upright",
    "Step long enough",
    "Push through front heel"
    ],
    variations: [
    "Walking lunges",
    "Reverse lunges"
    ],
    commonMistakes: [
    "Knee caving inward",
    "Leaning forward",
    "Short steps"
    ]
    ),
    Exercise(
    name: "Malasana (Yogic Squat)",
    muscleGroup: .mobility,
    equipment: .none,
    image: "malasana",
    instructions: "Deep squat with elbows pressing knees outward.",
    gifUrl: "malasanagif.gif",
    level: "Beginner",
    tempo: "Hold 20–40s",
    form: [
    "Keep heels grounded",
    "Press knees outward",
    "Maintain upright chest"
    ],
    variations: [
    "Heel elevated malasana",
    "Dynamic squat hold"
    ],
    commonMistakes: [
    "Heels lifting",
    "Rounding lower back",
    "Collapsing chest"
    ]
    ),

    Exercise(
    name: "Seated Calf Raises",
    muscleGroup: .legs,
    equipment: .machine,
    image: "seated_calf_raises",
    instructions: "Raise heels upward by contracting calves.",
    gifUrl: "seated_calf_raisesgif.gif",
    level: "Beginner",
    tempo: "1s up, 2s down",
    form: [
    "Pause at top",
    "Move slowly",
    "Full range of motion"
    ],
    variations: [
    "Single leg calf raise",
    "Weighted calf raise"
    ],
    commonMistakes: [
    "Bouncing reps",
    "Partial range of motion",
    "Too much weight"
    ]
    ),

    Exercise(
    name: "Squats",
    muscleGroup: .legs,
    equipment: .none,
    image: "squats",
    instructions: "Lower hips down and back while keeping chest upright.",
    gifUrl: "squatsgif.gif",
    level: "Beginner",
    tempo: "3s down, 1s up",
    form: [
    "Knees track over toes",
    "Chest upright",
    "Drive through heels"
    ],
    variations: [
    "Goblet squat",
    "Jump squat"
    ],
    commonMistakes: [
    "Knees caving inward",
    "Heels lifting",
    "Rounding lower back"
    ]
    ),

    Exercise(
    name: "Treadmill Run",
    muscleGroup: .cardio,
    equipment: .machine,
    image: "treadmill",
    instructions: "Run at steady pace maintaining upright posture.",
    gifUrl: "treadmillgif.gif",
    level: "Beginner",
    tempo: "Steady pace",
    form: [
    "Land mid-foot",
    "Relax shoulders",
    "Maintain cadence"
    ],
    variations: [
    "Interval running",
    "Incline running"
    ],
    commonMistakes: [
    "Overstriding",
    "Leaning forward",
    "Holding rails"
    ]
    )
    


    ]
    
    // MARK: - Helper Methods
    func getExercises(for muscleGroup: MuscleGroup) -> [Exercise] {
        if muscleGroup == .allMuscles {
            return allExercises
        }
        return allExercises.filter { $0.muscleGroup == muscleGroup }
    }
    
    func getExercises(for equipment: Equipment) -> [Exercise] {
        if equipment == .allEquipment {
            return allExercises
        }
        return allExercises.filter { $0.equipment == equipment }
    }
    
    func getExercises(for muscleGroup: MuscleGroup, equipment: Equipment) -> [Exercise] {
        return allExercises.filter { exercise in
            let muscleMatch = muscleGroup == .allMuscles || exercise.muscleGroup == muscleGroup
            let equipmentMatch = equipment == .allEquipment || exercise.equipment == equipment
            return muscleMatch && equipmentMatch
        }
    }
    
    func searchExercises(query: String) -> [Exercise] {
        let lowercasedQuery = query.lowercased()
        return allExercises.filter { exercise in
            exercise.name.lowercased().contains(lowercasedQuery) ||
            exercise.muscleGroup.displayName.lowercased().contains(lowercasedQuery) ||
            exercise.equipment.displayName.lowercased().contains(lowercasedQuery)
        }
    }
}

