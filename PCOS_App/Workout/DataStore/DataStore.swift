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
        // CORE EXERCISES
        Exercise(
            name: "Plank",
            muscleGroup: .core,
            equipment: .none,
            image: "plank",
            instructions: "Maintain a straight spine while holding the plank position.",
            gifUrl: "plank.gif",
            level: "Beginner",
            tempo: "Hold steady",
            form: [
                "Keep body in a straight line",
                "Engage core and glutes",
                "Keep neck neutral"
            ],
            variations: [
                "Side Plank",
                "Plank with leg lift"
            ],
            commonMistakes: [
                "Letting hips sag",
                "Raising hips too high",
                "Looking upward and straining neck"
            ]
        )
,
        Exercise(
            name: "Russian Twists",
            muscleGroup: .core,
            equipment: .none,
            image: "russian_twists",
            instructions: "Twist torso side to side while keeping core braced.",
            gifUrl: "russian_twists.gif",
            level: "Beginner",
            tempo: "1s per twist",
            form: [
                "Lean back slightly to engage core",
                "Rotate torso, not just arms",
                "Keep heels lightly touching floor"
            ],
            variations: [
                "Weighted Russian twists",
                "Feet elevated twists"
            ],
            commonMistakes: [
                "Moving only arms instead of torso",
                "Rounding the lower back",
                "Rushing the movement"
            ]
        )
,
        Exercise(
            name: "Cable Crunches",
            muscleGroup: .core,
            equipment: .machine,
            image: "cable_crunches",
            instructions: "Crunch downward using abdominal muscles while holding cable rope.",
            gifUrl: "cable_crunches.gif",
            level: "Intermediate",
            tempo: "2s down, 2s up",
            form: [
                "Keep hips fixed in place",
                "Crunch by contracting abs",
                "Keep elbows tucked in"
            ],
            variations: [
                "Standing cable crunch",
                "Single-arm cable crunch"
            ],
            commonMistakes: [
                "Pulling with arms instead of core",
                "Using excessive weight",
                "Letting lower back arch excessively"
            ]
        )
,
        Exercise(
            name: "Bicycle Crunches",
            muscleGroup: .core,
            equipment: .none,
            image: "bicycle_crunches",
            instructions: "Alternate elbow-to-knee while keeping core tight.",
            gifUrl: "bicycle_crunches.gif",
            level: "Beginner",
            tempo: "1–2s per rotation",
            form: [
                "Extend legs fully",
                "Keep lower back pressed into floor",
                "Rotate shoulders, not just elbows"
            ],
            variations: [
                "Slow-tempo bicycles",
                "Weighted bicycles"
            ],
            commonMistakes: [
                "Pulling neck with hands",
                "Using momentum",
                "Lifting lower back off floor"
            ]
        )
,
        
        // CHEST EXERCISES
        Exercise(
            name: "Bench Press",
            muscleGroup: .chest,
            equipment: .barbell,
            image: "bench_press",
            instructions: "Lower bar to mid-chest and press upward while maintaining shoulder stability.",
            gifUrl: "bench_press.gif",
            level: "Intermediate",
            tempo: "2s down, 1s up",
            form: [
                "Keep feet planted firmly",
                "Lower bar to mid-chest",
                "Keep wrists straight"
            ],
            variations: [
                "Incline bench press",
                "Close-grip bench press"
            ],
            commonMistakes: [
                "Flaring elbows excessively",
                "Bouncing bar off chest",
                "Arching back too much"
            ]
        )
,
        Exercise(
            name: "Dumbbell Chest Press",
            muscleGroup: .chest,
            equipment: .dumbbell,
            image: "dumbbell_bench_press",
            instructions: "Press dumbbells upward while maintaining shoulder stability.",
            gifUrl: "dumbbell_press.gif",
            level: "Beginner",
            tempo: "2s down, 1s up",
            form: [
                "Press dumbbells evenly",
                "Keep elbows at ~45° angle",
                "Control the descent"
            ],
            variations: [
                "Incline dumbbell press",
                "Neutral-grip press"
            ],
            commonMistakes: [
                "Uneven pressing",
                "Letting shoulders roll forward",
                "Using momentum"
            ]
        )
,
        Exercise(
            name: "Push-ups",
            muscleGroup: .chest,
            equipment: .none,
            image: "pushups",
            instructions: "Lower chest to the floor and push back up while keeping body straight.",
            gifUrl: "pushups.gif",
            level: "Beginner",
            tempo: "2s down, 1s up",
            form: [
                "Keep core tight",
                "Maintain straight body line",
                "Hands slightly wider than shoulders"
            ],
            variations: [
                "Knee push-ups",
                "Decline push-ups"
            ],
            commonMistakes: [
                "Sagging hips",
                "Flaring elbows too much",
                "Half reps"
            ]
        )
,
        Exercise(
            name: "Chest Fly",
            muscleGroup: .chest,
            equipment: .dumbbell,
            image: "chest_fly",
            instructions: "Open arms wide and bring them together in a hugging motion.",
            gifUrl: "chest_fly.gif",
            level: "Beginner",
            tempo: "2s stretch, 1s close",
            form: [
                "Keep slight elbow bend",
                "Open arms without dropping too low",
                "Squeeze chest at top"
            ],
            variations: [
                "Incline chest fly",
                "Cable fly"
            ],
            commonMistakes: [
                "Using too much weight",
                "Bending elbows excessively",
                "Dropping arms too low"
            ]
        )
,
        
        // BACK EXERCISES
        Exercise(
            name: "Deadlift",
            muscleGroup: .back,
            equipment: .barbell,
            image: "deadlift",
            instructions: "Lift barbell from ground by extending hips and knees while keeping spine neutral.",
            gifUrl: "deadlift.gif",
            level: "Advanced",
            tempo: "2s up, 2s down",
            form: [
                "Keep bar close to body",
                "Push floor away with legs",
                "Neutral spine throughout"
            ],
            variations: [
                "Romanian deadlift",
                "Sumo deadlift"
            ],
            commonMistakes: [
                "Rounding the lower back",
                "Hyperextending at lockout",
                "Letting bar drift forward"
            ]
        )

,
        Exercise(
            name: "Lat Pulldown",
            muscleGroup: .back,
            equipment: .machine,
            image: "lat_pulldown",
            instructions: "Pull bar to upper chest while squeezing lats.",
            gifUrl: "lat_pulldown.gif",
            level: "Beginner",
            tempo: "2s pull, 2s return",
            form: [
                "Lean back slightly",
                "Drive elbows down",
                "Avoid shrugging shoulders"
            ],
            variations: [
                "Close-grip pulldown",
                "Reverse-grip pulldown"
            ],
            commonMistakes: [
                "Using momentum",
                "Pulling behind head",
                "Shrugging traps"
            ]
        )
,
        Exercise(
            name: "Bent Over Barbell Row",
            muscleGroup: .back,
            equipment: .barbell,
            image: "barbell_row",
            instructions: "Pull barbell toward torso while maintaining hip hinge.",
            gifUrl: "barbell_row.gif",
            level: "Intermediate",
            tempo: "2s pull, 1s squeeze",
            form: [
                "Keep torso stable",
                "Lead with elbows",
                "Maintain neutral spine"
            ],
            variations: [
                "Underhand row",
                "Pendlay row"
            ],
            commonMistakes: [
                "Rounding back",
                "Jerking weight",
                "Standing too upright"
            ]
        )
,
        Exercise(
            name: "Dumbbell Row",
            muscleGroup: .back,
            equipment: .dumbbell,
            image: "dumbbell_row",
            instructions: "Row dumbbell toward hip while keeping back flat.",
            gifUrl: "dumbbell_row.gif",
            level: "Beginner",
            tempo: "1s pull, 2s lower",
            form: [
                "Square hips and shoulders",
                "Pull toward hip, not chest",
                "Keep elbow close"
            ],
            variations: [
                "Chest-supported row",
                "Kroc row"
            ],
            commonMistakes: [
                "Rotating torso",
                "Shrugging shoulder",
                "Pulling with biceps instead of back"
            ]
        )
,
        Exercise(
            name: "Pull-ups",
            muscleGroup: .back,
            equipment: .none,
            image: "pullups",
            instructions: "Pull body upward until chin passes bar.",
            gifUrl: "pullups.gif",
            level: "Advanced",
            tempo: "2s pull, 2s lower",
            form: [
                "Grip bar slightly wider than shoulder",
                "Engage scapula",
                "Drive elbows down"
            ],
            variations: [
                "Chin-ups",
                "Assisted pull-ups"
            ],
            commonMistakes: [
                "Kipping unintentionally",
                "Half reps",
                "Shrugging traps excessively"
            ]
        )
,
        Exercise(
            name: "Seated Cable Row",
            muscleGroup: .back,
            equipment: .machine,
            image: "cable_row",
            instructions: "Pull cable handle to torso while keeping chest lifted.",
            gifUrl: "cable_row.gif",
            level: "Beginner",
            tempo: "1s pull, 2s release",
            form: [
                "Keep shoulders back",
                "Squeeze shoulder blades",
                "Maintain upright torso"
            ],
            variations: [
                "Wide-grip row",
                "Single-arm row"
            ],
            commonMistakes: [
                "Leaning too far back",
                "Rounding shoulders",
                "Jerking weight"
            ]
        )
,
        
        // LEG EXERCISES
        Exercise(
            name: "Barbell Squat",
            muscleGroup: .legs,
            equipment: .barbell,
            image: "barbell_squat",
            instructions: "Lower hips back and down while maintaining upright torso.",
            gifUrl: "barbell_squat.gif",
            level: "Intermediate",
            tempo: "3s down, 1s up",
            form: [
                "Keep knees aligned with toes",
                "Brace core before descending",
                "Drive through heels"
            ],
            variations: [
                "Front squat",
                "Box squat"
            ],
            commonMistakes: [
                "Letting knees cave inward",
                "Rounding lower back",
                "Lifting heels off floor"
            ]
        )
,
        Exercise(
            name: "Leg Press",
            muscleGroup: .legs,
            equipment: .machine,
            image: "leg_press",
            instructions: "Press platform upward by extending knees and hips.",
            gifUrl: "leg_press.gif",
            level: "Beginner",
            tempo: "2s press, 2s return",
            form: [
                "Keep knees aligned",
                "Control depth",
                "Avoid locking knees"
            ],
            variations: [
                "Single-leg press",
                "High or low foot placement"
            ],
            commonMistakes: [
                "Locking knees aggressively",
                "Using too much weight",
                "Shallow range of motion"
            ]
        )
,
        Exercise(
            name: "Lunges",
            muscleGroup: .legs,
            equipment: .none,
            image: "lunges",
            instructions: "Step forward and lower knee toward floor.",
            gifUrl: "lunges.gif",
            level: "Beginner",
            tempo: "1s down, 1s up",
            form: [
                "Keep torso upright",
                "Step long enough for 90° angles",
                "Push through front heel"
            ],
            variations: [
                "Reverse lunge",
                "Walking lunges"
            ],
            commonMistakes: [
                "Knee caving inward",
                "Short steps",
                "Leaning too far forward"
            ]
        )
,
        Exercise(
            name: "Dumbbell Lunges",
            muscleGroup: .legs,
            equipment: .dumbbell,
            image: "dumbbell_lunges",
            instructions: "Perform lunges while holding dumbbells at sides.",
            gifUrl: "dumbbell_lunges.gif",
            level: "Intermediate",
            tempo: "1s down, 1s up",
            form: [
                "Control each step",
                "Keep chest lifted",
                "Drive through heel"
            ],
            variations: [
                "Curtsey lunges",
                "Split squats"
            ],
            commonMistakes: [
                "Using too heavy weights",
                "Leaning forward",
                "Letting weight swing"
            ]
        )
,
        Exercise(
            name: "Leg Extension",
            muscleGroup: .legs,
            equipment: .machine,
            image: "leg_extension",
            instructions: "Extend knees fully against machine resistance.",
            gifUrl: "leg_extension.gif",
            level: "Beginner",
            tempo: "1s lift, 2s lower",
            form: [
                "Point toes slightly upward",
                "Squeeze quads at top",
                "Move slowly"
            ],
            variations: [
                "Single-leg extension",
                "Drop sets"
            ],
            commonMistakes: [
                "Kicking weight up",
                "Using excessive load",
                "Not controlling descent"
            ]
        )
,
        Exercise(
            name: "Leg Curl",
            muscleGroup: .legs,
            equipment: .machine,
            image: "leg_curl",
            instructions: "Curl heels toward glutes on machine.",
            gifUrl: "leg_curl.gif",
            level: "Beginner",
            tempo: "1s curl, 2s lower",
            form: [
                "Keep hips pressed down",
                "Squeeze hamstrings",
                "Move smoothly"
            ],
            variations: [
                "Seated leg curl",
                "Single-leg curl"
            ],
            commonMistakes: [
                "Swinging weight",
                "Lifting hips",
                "Half reps"
            ]
        )
,Exercise(
    name: "Goblet Squat",
    muscleGroup: .legs,
    equipment: .dumbbell,
    image: "goblet_squat",
    instructions: "Hold dumbbell at chest and squat down.",
    gifUrl: "goblet_squat.gif",
    level: "Beginner",
    tempo: "3s down, 1s up",
    form: [
        "Keep elbows close",
        "Push knees outward",
        "Stay upright"
    ],
    variations: [
        "Kettlebell goblet squat",
        "Paused squat"
    ],
    commonMistakes: [
        "Letting chest collapse",
        "Caving knees inward",
        "Shallow squats"
    ]
)
,
        
        // SHOULDER EXERCISES
        Exercise(
            name: "Overhead Press",
            muscleGroup: .shoulders,
            equipment: .barbell,
            image: "overhead_press",
            instructions: "Press bar overhead while keeping core braced.",
            gifUrl: "overhead_press.gif",
            level: "Intermediate",
            tempo: "1–2s up, 2s down",
            form: [
                "Brace core and glutes",
                "Keep bar close to face path",
                "Lock out overhead"
            ],
            variations: [
                "Push press",
                "Seated shoulder press"
            ],
            commonMistakes: [
                "Overarching lower back",
                "Pressing in front of body",
                "Using too much leg drive"
            ]
        )
,
        Exercise(
            name: "Dumbbell Shoulder Press",
            muscleGroup: .shoulders,
            equipment: .dumbbell,
            image: "dumbbell_press",
            instructions: "Press dumbbells overhead with controlled movement.",
            gifUrl: "dumbbell_press.gif",
            level: "Beginner",
            tempo: "2s up, 2s down",
            form: [
                "Keep core tight",
                "Press evenly with both arms",
                "Avoid shrugging traps"
            ],
            variations: [
                "Arnold press",
                "Neutral-grip press"
            ],
            commonMistakes: [
                "Flaring elbows",
                "Arching back",
                "Uneven pressing"
            ]
        )
,
        Exercise(
            name: "Lateral Raises",
            muscleGroup: .shoulders,
            equipment: .dumbbell,
            image: "lateral_raises",
            instructions: "Raise arms to sides until shoulder height.",
            gifUrl: "lateral_raises.gif",
            level: "Beginner",
            tempo: "1s lift, 2s lower",
            form: [
                "Keep slight elbow bend",
                "Lift with delts, not traps",
                "Pause at top"
            ],
            variations: [
                "Cable lateral raise",
                "Seated lateral raise"
            ],
            commonMistakes: [
                "Swinging weights",
                "Shrugging shoulders",
                "Overloading weight"
            ]
        )
,
        Exercise(
            name: "Front Raises",
            muscleGroup: .shoulders,
            equipment: .dumbbell,
            image: "front_raises",
            instructions: "Lift dumbbells forward to shoulder height.",
            gifUrl: "front_raises.gif",
            level: "Beginner",
            tempo: "1s up, 2s down",
            form: [
                "Keep arms straight but not locked",
                "Lift to shoulder height only",
                "Control lowering phase"
            ],
            variations: [
                "Barbell front raise",
                "Plate front raise"
            ],
            commonMistakes: [
                "Swinging weights up",
                "Using too much weight",
                "Raising above shoulder height"
            ]
        )
,
        Exercise(
            name: "Step-Up on Chair",
            muscleGroup: .legs,
            equipment: .none,
            image: "step_up_chair",
            instructions: "Step onto a sturdy chair with one foot, press through the heel to stand up, then step back down with control.",
            gifUrl: "step_up_chair.gif",
            level: "Beginner",
            tempo: "1s up, 2s down",
            form: [
                "Keep chest upright and core engaged",
                "Drive through the heel of the working leg",
                "Fully extend the hip at the top"
            ],
            variations: [
                "Dumbbell step-up",
                "High step-up",
                "Alternating step-up"
            ],
            commonMistakes: [
                "Pushing off the back leg too much",
                "Letting knee cave inward",
                "Dropping down too fast"
            ]
        )
,
        
        // ARM EXERCISES
        Exercise(
            name: "Barbell Curl",
            muscleGroup: .arms,
            equipment: .barbell,
            image: "barbell_curl",
            instructions: "Curl bar upward while keeping elbows close to torso.",
            gifUrl: "barbell_curl.gif",
            level: "Beginner",
            tempo: "1s up, 2s down",
            form: [
                "Keep elbows pinned to sides",
                "Stand tall without leaning back",
                "Control lowering phase"
            ],
            variations: [
                "Reverse curl",
                "Wide-grip curl"
            ],
            commonMistakes: [
                "Using momentum",
                "Letting elbows flare",
                "Swinging body backward"
            ]
        )
,
        Exercise(
            name: "Dumbbell Curl",
            muscleGroup: .arms,
            equipment: .dumbbell,
            image: "dumbbell_curl",
            instructions: "Curl dumbbells while rotating palms upward.",
            gifUrl: "dumbbell_curl.gif",
            level: "Beginner",
            tempo: "1s up, 2s down",
            form: [
                "Rotate wrist supinated at top",
                "Keep elbows still",
                "Lift with biceps, not shoulders"
            ],
            variations: [
                "Hammer curl",
                "Alternating curls"
            ],
            commonMistakes: [
                "Shrugging shoulders",
                "Curling too quickly",
                "Dropping weight without control"
            ]
        )
,
        Exercise(
            name: "Tricep Dips",
            muscleGroup: .arms,
            equipment: .none,
            image: "tricep_dips",
            instructions: "Lower body by bending elbows and push back up.",
            gifUrl: "tricep_dips.gif",
            level: "Intermediate",
            tempo: "2s down, 1s up",
            form: [
                "Keep elbows pointing backward",
                "Lower until arms reach 90 degrees",
                "Keep chest lifted"
            ],
            variations: [
                "Bench dips",
                "Weighted dips"
            ],
            commonMistakes: [
                "Flaring elbows",
                "Shrugging shoulders",
                "Not using full range of motion"
            ]
        )
,
        Exercise(
            name: "Tricep Pushdown",
            muscleGroup: .arms,
            equipment: .machine,
            image: "tricep_pushdown",
            instructions: "Push cable handle downward while keeping elbows fixed.",
            gifUrl: "tricep_pushdown.gif",
            level: "Beginner",
            tempo: "1s push, 2s return",
            form: [
                "Keep elbows tucked",
                "Extend fully at bottom",
                "Keep wrist neutral"
            ],
            variations: [
                "Rope pushdown",
                "Straight bar pushdown"
            ],
            commonMistakes: [
                "Letting elbows flare",
                "Using torso to swing weight",
                "Not locking out arms"
            ]
        )
,
        Exercise(
            name: "Hammer Curl",
            muscleGroup: .arms,
            equipment: .dumbbell,
            image: "hammer_curl",
            instructions: "Curl dumbbells with a neutral grip.",
            gifUrl: "hammer_curl.gif",
            level: "Beginner",
            tempo: "1s up, 2s down",
            form: [
                "Keep palms facing inward",
                "Keep elbows close",
                "Control the tempo"
            ],
            variations: [
                "Cross-body hammer curl",
                "Cable rope hammer curl"
            ],
            commonMistakes: [
                "Swinging weights",
                "Bending wrists",
                "Shrugging shoulders"
            ]
        )
,
        Exercise(
            name: "Overhead Tricep Extension",
            muscleGroup: .arms,
            equipment: .dumbbell,
            image: "overhead_tricep",
            instructions: "Lower dumbbell behind head and extend upward.",
            gifUrl: "overhead_tricep.gif",
            level: "Intermediate",
            tempo: "2s down, 1s up",
            form: [
                "Keep elbows close together",
                "Lower weight behind head fully",
                "Keep core tight"
            ],
            variations: [
                "Two-hand dumbbell extension",
                "Cable overhead extension"
            ],
            commonMistakes: [
                "Elbows flaring wide",
                "Using too much weight",
                "Arching lower back"
            ]
        )
,
        
        // GLUTE EXERCISES
        Exercise(
            name: "Hip Thrust",
            muscleGroup: .glutes,
            equipment: .barbell,
            image: "hip_thrust",
            instructions: "Drive hips upward while squeezing glutes.",
            gifUrl: "hip_thrust.gif",
            level: "Intermediate",
            tempo: "1s up, 3s down",
            form: [
                "Tuck chin slightly",
                "Keep shins vertical",
                "Squeeze glutes at top"
            ],
            variations: [
                "Single-leg hip thrust",
                "Frog pumps"
            ],
            commonMistakes: [
                "Hyperextending back",
                "Feet too far forward",
                "Dropping hips too fast"
            ]
        )
,
        Exercise(
            name: "Glute Bridge",
            muscleGroup: .glutes,
            equipment: .none,
            image: "glute_bridge",
            instructions: "Lift hips off ground by squeezing glutes.",
            gifUrl: "glute_bridge.gif",
            level: "Beginner",
            tempo: "1s up, 2s down",
            form: [
                "Keep core braced",
                "Push through heels",
                "Squeeze at top"
            ],
            variations: [
                "Banded glute bridge",
                "Single-leg bridge"
            ],
            commonMistakes: [
                "Overarching back",
                "Feet too close",
                "Not squeezing glutes"
            ]
        )
,
        Exercise(
            name: "Bulgarian Split Squat",
            muscleGroup: .glutes,
            equipment: .dumbbell,
            image: "bulgarian_split",
            instructions: "Lower into split squat with rear foot elevated.",
            gifUrl: "bulgarian_split.gif",
            level: "Intermediate",
            tempo: "2s down, 1s up",
            form: [
                "Lean slightly forward for glute bias",
                "Keep front knee aligned",
                "Drive through heel"
            ],
            variations: [
                "Bodyweight only",
                "Barbell split squat"
            ],
            commonMistakes: [
                "Too wide stance",
                "Letting knee cave in",
                "Pushing off back leg"
            ]
        )
,
        Exercise(
            name: "Cable Kickbacks",
            muscleGroup: .glutes,
            equipment: .machine,
            image: "cable_kickbacks",
            instructions: "Kick leg backward while squeezing glute.",
            gifUrl: "cable_kickbacks.gif",
            level: "Beginner",
            tempo: "1s back, 2s return",
            form: [
                "Keep torso still",
                "Kick through heel",
                "Squeeze glute fully"
            ],
            variations: [
                "Glute machine kickback",
                "Banded kickback"
            ],
            commonMistakes: [
                "Hyperextending back",
                "Using quads instead of glutes",
                "Swinging weight"
            ]
        )
,
        Exercise(
            name: "Dumbbell Romanian Deadlift",
            muscleGroup: .glutes,
            equipment: .dumbbell,
            image: "romanian_deadlift",
            instructions: "Hinge at the hips while keeping a neutral spine and stretch hamstrings before returning to standing.",
            gifUrl: "romanian_deadlift.gif",
            level: "Intermediate",
            tempo: "3s down, 1s up",
            form: [
                "Keep slight knee bend",
                "Push hips backward in a hinge",
                "Keep dumbbells close to legs",
                "Maintain neutral spine"
            ],
            variations: [
                "Single-leg Romanian deadlift",
                "Barbell Romanian deadlift",
                "Banded RDL"
            ],
            commonMistakes: [
                "Rounding lower back",
                "Locking knees",
                "Letting dumbbells drift forward",
                "Squatting instead of hinging"
            ]
        ),

        
        // CARDIO EXERCISES
        Exercise(
            name: "Jumping Jacks",
            muscleGroup: .cardio,
            equipment: .none,
            image: "jumping_jacks",
            instructions: "Jump legs out while raising arms overhead.",
            gifUrl: "jumping_jacks.gif",
            level: "Beginner",
            tempo: "Fast-paced",
            form: [
                "Land softly",
                "Maintain rhythm",
                "Keep arms controlled"
            ],
            variations: [
                "Half-jacks",
                "Weighted jacks"
            ],
            commonMistakes: [
                "Stomping feet",
                "Shrugging shoulders",
                "Losing coordination"
            ]
        )
,
        Exercise(
            name: "Burpees",
            muscleGroup: .cardio,
            equipment: .none,
            image: "burpees",
            instructions: "Drop to plank, perform push-up, jump up explosively.",
            gifUrl: "burpees.gif",
            level: "Intermediate",
            tempo: "Continuous",
            form: [
                "Keep core tight",
                "Land softly",
                "Explode upward"
            ],
            variations: [
                "Step-back burpee",
                "Burpee with tuck jump"
            ],
            commonMistakes: [
                "Letting hips sag",
                "Not jumping fully",
                "Skipping push-up"
            ]
        )
,
        Exercise(
            name: "Mountain Climbers",
            muscleGroup: .cardio,
            equipment: .none,
            image: "mountain_climbers",
            instructions: "Alternate knees toward chest in plank position.",
            gifUrl: "mountain_climbers.gif",
            level: "Beginner",
            tempo: "Fast-paced",
            form: [
                "Keep shoulders over wrists",
                "Maintain flat back",
                "Drive knees forward"
            ],
            variations: [
                "Cross-body climbers",
                "Slow climbers"
            ],
            commonMistakes: [
                "Lifting hips high",
                "Letting back sag",
                "Short knee drive"
            ]
        )
,
        Exercise(
            name: "High Knees",
            muscleGroup: .cardio,
            equipment: .none,
            image: "high_knees",
            instructions: "Run in place while lifting knees to hip height.",
            gifUrl: "high_knees.gif",
            level: "Beginner",
            tempo: "Fast-paced",
            form: [
                "Lift knees high",
                "Pump arms",
                "Stay light on feet"
            ],
            variations: [
                "Low-impact high knees",
                "Weighted high knees"
            ],
            commonMistakes: [
                "Shallow knee lift",
                "Landing hard on heels",
                "Leaning backward"
            ]
        )
,
        Exercise(
            name: "Elliptical Trainer",
            muscleGroup: .cardio,
            equipment: .machine,
            image: "elliptical",
            instructions: "Move arms and legs in a smooth, continuous motion while maintaining an upright posture.",
            gifUrl: "elliptical.gif",
            level: "Beginner",
            tempo: "Steady continuous pace",
            form: [
                "Keep torso upright",
                "Push and pull handles evenly",
                "Maintain smooth, controlled motion"
            ],
            variations: [
                "Reverse pedaling",
                "Increased resistance intervals"
            ],
            commonMistakes: [
                "Leaning heavily on handles",
                "Locking knees",
                "Moving too fast without control"
            ]
        )
        ,

        Exercise(
            name: "Jump Rope",
            muscleGroup: .cardio,
            equipment: .none,
            image: "jump_rope",
            instructions: "Jump rhythmically while spinning rope under feet.",
            gifUrl: "jump_rope.gif",
            level: "Beginner",
            tempo: "Fast-paced",
            form: [
                "Jump lightly",
                "Keep wrists relaxed",
                "Maintain steady rhythm"
            ],
            variations: [
                "High-speed rope",
                "Alternate-foot jump"
            ],
            commonMistakes: [
                "Jumping too high",
                "Swinging arms too much",
                "Landing hard"
            ]
        )
,
        
        // MOBILITY EXERCISES
        Exercise(
            name: "Cat-Cow Stretch",
            muscleGroup: .mobility,
            equipment: .none,
            image: "cat_cow",
            instructions: "Alternate between arching and rounding spine.",
            gifUrl: "cat_cow.gif",
            level: "Beginner",
            tempo: "Slow and controlled",
            form: [
                "Move with breath",
                "Spread fingers wide",
                "Engage core lightly"
            ],
            variations: [
                "Thread the needle",
                "Child’s pose flow"
            ],
            commonMistakes: [
                "Rushing movement",
                "Hyperextending neck",
                "Not coordinating breath"
            ]
        )
,
        Exercise(
            name: "World's Greatest Stretch",
            muscleGroup: .mobility,
            equipment: .none,
            image: "worlds_greatest",
            instructions: "Deep lunge with rotation to open hips and thoracic spine.",
            gifUrl: "worlds_greatest.gif",
            level: "Intermediate",
            tempo: "Slow",
            form: [
                "Rotate chest open",
                "Keep hips square",
                "Reach long through fingertips"
            ],
            variations: [
                "Dynamic WGS",
                "Hold position static"
            ],
            commonMistakes: [
                "Twisting lower back instead of upper",
                "Short lunge stance",
                "Rushing stretch"
            ]
        )
,
        Exercise(
            name: "Hip Circles",
            muscleGroup: .mobility,
            equipment: .none,
            image: "hip_circles",
            instructions: "Circle leg to lubricate hip joint.",
            gifUrl: "hip_circles.gif",
            level: "Beginner",
            tempo: "Controlled",
            form: [
                "Keep torso stable",
                "Move leg through full range",
                "Avoid rotating hips excessively"
            ],
            variations: [
                "Standing hip circles",
                "Quadruped circles"
            ],
            commonMistakes: [
                "Rushing movement",
                "Arching back",
                "Not stabilizing torso"
            ]
        )
,
        Exercise(
            name: "Shoulder Dislocations",
            muscleGroup: .mobility,
            equipment: .resistanceBand,
            image: "shoulder_dislocations",
            instructions: "Bring band overhead and behind body to open shoulders.",
            gifUrl: "shoulder_dislocations.gif",
            level: "Intermediate",
            tempo: "Slow and controlled",
            form: [
                "Keep arms straight",
                "Use wide grip to reduce strain",
                "Control movement through full arc"
            ],
            variations: [
                "PVC dislocations",
                "Narrow-grip progression"
            ],
            commonMistakes: [
                "Using too much tension",
                "Bending elbows",
                "Moving too fast"
            ]
        )
,
        
        // FULL BODY EXERCISES
        Exercise(
            name: "Kettlebell Swing",
            muscleGroup: .fullBody,
            equipment: .kettlebell,
            image: "kettlebell_swing",
            instructions: "Hinge at hips to swing kettlebell to chest height.",
            gifUrl: "kettlebell_swing.gif",
            level: "Intermediate",
            tempo: "Explosive hip drive",
            form: [
                "Hinge, don’t squat",
                "Snap hips forward",
                "Keep arms relaxed"
            ],
            variations: [
                "American swing",
                "Single-arm swing"
            ],
            commonMistakes: [
                "Squatting instead of hinging",
                "Lifting weight with arms",
                "Rounding back"
            ]
        )
,
        Exercise(
            name: "Thrusters",
            muscleGroup: .fullBody,
            equipment: .dumbbell,
            image: "thrusters",
            instructions: "Squat down with dumbbells at shoulders and press overhead as you stand.",
            gifUrl: "thrusters.gif",
            level: "Intermediate",
            tempo: "Explosive up, 2s down",
            form: [
                "Keep elbows up in squat",
                "Drive through heels",
                "Push dumbbells overhead in one motion"
            ],
            variations: [
                "Barbell thruster",
                "Single-arm thruster"
            ],
            commonMistakes: [
                "Letting knees cave inward",
                "Pressing too early before standing",
                "Rounding upper back"
            ]
        )
,
        Exercise(
            name: "Clean and Press",
            muscleGroup: .fullBody,
            equipment: .barbell,
            image: "clean_press",
            instructions: "Pull barbell to shoulders in a clean, then press overhead.",
            gifUrl: "clean_press.gif",
            level: "Advanced",
            tempo: "Explosive clean, controlled press",
            form: [
                "Keep bar close to body",
                "Catch bar in strong front-rack position",
                "Press overhead with locked core"
            ],
            variations: [
                "Dumbbell clean and press",
                "Push press"
            ],
            commonMistakes: [
                "Rounding back during clean",
                "Catching bar with elbows low",
                "Pressing with unstable core"
            ]
        )
,
        Exercise(
            name: "Turkish Get-Up",
            muscleGroup: .fullBody,
            equipment: .kettlebell,
            image: "turkish_getup",
            instructions: "Stand up and lie back down while holding weight overhead.",
            gifUrl: "turkish_getup.gif",
            level: "Advanced",
            tempo: "Slow and controlled",
            form: [
                "Keep wrist stacked over shoulder",
                "Move through each phase deliberately",
                "Maintain core tension throughout"
            ],
            variations: [
                "Bodyweight get-up",
                "Dumbbell get-up"
            ],
            commonMistakes: [
                "Rushing transitions",
                "Letting kettlebell tilt inward",
                "Losing tension in midline"
            ]
        )
        ,
        Exercise(
            name: "Tree Pose",
            muscleGroup: .legs,
            equipment: .none,
            image: "tree_pose",
            instructions: "Stand on one leg and place the other foot on your calf or thigh while balancing.",
            gifUrl: "tree_pose.gif",
            level: "Beginner",
            tempo: "Hold 20–40 seconds each side",
            form: [
                "Keep core engaged",
                "Avoid placing foot on the knee"
            ],
            variations: [
                "Hands at chest",
                "Arms overhead"
            ],
            commonMistakes: [
                "Locking standing knee",
                "Foot on knee joint"
            ]
        )
,Exercise(
    name: "Leg Raises",
    muscleGroup: .core,
    equipment: .resistanceBand,
    image: "leg_raises_band",
    instructions: "Raise and lower legs while lying down, keeping band tension.",
    gifUrl: "leg_raises_band.gif",
    level: "Beginner",
    tempo: "2s up, 2s down",
    form: [
        "Core tight",
        "Back flat on mat",
        "Slow, controlled movement"
    ],
    variations: [
        "Single-leg raises",
        "Hands under hips"
    ],
    commonMistakes: [
        "Arching back",
        "Using momentum"
    ]
),
        Exercise(
            name: "Face Pulls",
            muscleGroup: .shoulders,
            equipment: .machine,
            image: "face_pulls_machine",
            instructions: "Pull handles toward face with elbows high.",
            gifUrl: "face_pulls_machine.gif",
            level: "Beginner",
            tempo: "1s pull, 2s return",
            form: [
                "Elbows up",
                "Squeeze upper back",
                "Keep chest tall"
            ],
            variations: [
                "Single-arm face pull",
                "Wide grip"
            ],
            commonMistakes: [
                "Shrugging shoulders",
                "Using momentum"
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

