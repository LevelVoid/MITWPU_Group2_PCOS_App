//
//  ExploreRoutineDatastore.swift
//  PCOS_App
//
//  Created by SDC-USER on 10/12/25.
//
import Foundation

class RoutineDataStore {
    static let shared = RoutineDataStore()
    private init() {}

    // MARK: - Helper to look up exercise by name
    private func ex(_ name: String) -> Exercise {
        guard let exercise = ExerciseDataStore.shared.allExercises.first(where: { $0.name == name }) else {
            fatalError("Exercise '\(name)' not found in ExerciseDataStore")
        }
        return exercise
    }

    // MARK: - All 35 predefined routines (7 per phase)
    lazy var predefinedRoutines: [Routine] = {
        return menstrualRoutines + follicularRoutines + ovulationRoutines + lutealRoutines + unknownRoutines
    }()

    // MARK: - Query Methods

    /// All routines for a given phase
    func routines(for phase: Phase) -> [Routine] {
        return predefinedRoutines.filter { $0.phase == phase }
    }

    /// 4 daily routines for the workout tab (2 yoga + 2 strength), rotating daily
    func dailyRoutines(for phase: Phase) -> [Routine] {
        let phaseRoutines = routines(for: phase)
        let yogaRoutines = phaseRoutines.filter { $0.routineType == .yoga }
        let strengthRoutines = phaseRoutines.filter { $0.routineType == .strength }

        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1

        // Pick 2 yoga routines rotating daily
        var selectedYoga: [Routine] = []
        if yogaRoutines.count >= 2 {
            let startIdx = (dayOfYear - 1) % yogaRoutines.count
            selectedYoga.append(yogaRoutines[startIdx])
            selectedYoga.append(yogaRoutines[(startIdx + 1) % yogaRoutines.count])
        } else {
            selectedYoga = yogaRoutines
        }

        // Pick 2 strength routines rotating daily
        var selectedStrength: [Routine] = []
        if strengthRoutines.count >= 2 {
            let startIdx = (dayOfYear - 1) % strengthRoutines.count
            selectedStrength.append(strengthRoutines[startIdx])
            selectedStrength.append(strengthRoutines[(startIdx + 1) % strengthRoutines.count])
        } else {
            selectedStrength = strengthRoutines
        }

        return selectedYoga + selectedStrength
    }

    /// The single most recommended routine for today (first of dailyRoutines)
    func recommendedRoutine(for phase: Phase) -> Routine {
        let daily = dailyRoutines(for: phase)
        return daily.first ?? predefinedRoutines.first!
    }

    /// Check if a routine is the recommended one for today
    func isRecommendedToday(_ routine: Routine, for phase: Phase) -> Bool {
        return recommendedRoutine(for: phase).id == routine.id
    }

    // MARK: - Menstrual Phase Routines (gentle, restorative — low cortisol impact)

    
    private lazy var menstrualRoutines: [Routine] = [
        Routine(
            id: UUID(), name: "Gentle Flow",
            exercises: [
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Bhujangasana"), durationSeconds: 420)
            ],
            thumbnailImageName: "routine_9", routineTagline: "Ease into movement with breath-led yoga",
            routineDescription: "A gentle 35-minute yoga flow designed for the menstrual phase...",
            phase: .menstrual, routineType: .yoga
        ),
        Routine(
            id: UUID(), name: "Restorative Stretch",
            exercises: [
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Hip Rotation"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Malasana (Yogic Squat)"), durationSeconds: 420)
            ],
            thumbnailImageName: "routine_10", routineTagline: "Deep stretches to ease tension and cramps",
            routineDescription: "Restorative 30-40 min stretching targets the hips, pelvis, and lower back.",
            phase: .menstrual, routineType: .yoga
        ),
        Routine(
            id: UUID(), name: "Light Core Activation",
            exercises: [
                RoutineExercise(exercise: ex("Jumping Jacks"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Bird Dog"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Glute Bridge"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Plank"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Leg Raises"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Incline Treadmill Walk"), durationSeconds: 600),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 120)
            ],
            thumbnailImageName: "routine_11", routineTagline: "Gentle core work without overstressing",
            routineDescription: "Light core activation keeps muscles engaged without spiking cortisol.",
            phase: .menstrual, routineType: .strength
        ),
        Routine(
            id: UUID(), name: "Lower Body Ease",
            exercises: [
                RoutineExercise(exercise: ex("Jumping Jacks"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Glute Bridge"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Lunges"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Seated Calf Raises"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Incline Treadmill Walk"), durationSeconds: 600),
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 120)
            ],
            thumbnailImageName: "routine_12", routineTagline: "Keep legs moving with low-impact strength",
            routineDescription: "A 35-40 min session following the consistency-first PCOS protocol.",
            phase: .menstrual, routineType: .strength
        ),
        Routine(
            id: UUID(), name: "Low Energy Movement",
            exercises: [
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Glute Bridge"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Bird Dog"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Incline Treadmill Walk"), durationSeconds: 900),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 180)
            ],
            thumbnailImageName: "routine_13", routineTagline: "When fatigue is high and your body needs gentle support",
            routineDescription: "Designed for days of low energy and physical fatigue, prioritizing gentle activation.",
            phase: .menstrual, routineType: .mixed
        ),
        Routine(
            id: UUID(), name: "Calm & Steady",
            exercises: [
                RoutineExercise(exercise: ex("Hip Rotation"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Face Pulls"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Cable Row"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Elliptical Trainer"), durationSeconds: 900),
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 180)
            ],
            thumbnailImageName: "routine_14", routineTagline: "Slow, stabilizing movement for overwhelming days",
            routineDescription: "This 35-40 min routine supports stress regulation.",
            phase: .menstrual, routineType: .mixed
        ),
        Routine(
            id: UUID(), name: "Gentle Mobility",
            exercises: [
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Bird Dog"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Plank"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Incline Treadmill Walk"), durationSeconds: 900),
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 180)
            ],
            thumbnailImageName: "routine_15", routineTagline: "Open hips and move gently",
            routineDescription: "Mobility-focused with light walking to promote lymphatic drainage.",
            phase: .menstrual, routineType: .mixed
        )
    ]

    // MARK: - Follicular Phase Routines (rising energy — progressive challenge)

    
    private lazy var follicularRoutines: [Routine] = [
        Routine(
            id: UUID(), name: "Energizing Yoga Flow",
            exercises: [
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Bhujangasana"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Bow Pose"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Malasana (Yogic Squat)"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 420)
            ],
            thumbnailImageName: "routine_9", routineTagline: "Channel rising energy into dynamic yoga",
            routineDescription: "Estrogen rises during the follicular phase, energy increases. 30-40 min flow.",
            phase: .follicular, routineType: .yoga
        ),
        Routine(
            id: UUID(), name: "Sun Salutation Series",
            exercises: [
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Bhujangasana"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Plank"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 420)
            ],
            thumbnailImageName: "routine_10", routineTagline: "Classic sun salutation adapted for PCOS",
            routineDescription: "A 35-minute sun salutation sequence that builds body heat.",
            phase: .follicular, routineType: .yoga
        ),
        Routine(
            id: UUID(), name: "Progressive Lower Body",
            exercises: [
                RoutineExercise(exercise: ex("Jump Rope"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Lunges"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Leg Press"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Seated Calf Raises"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Treadmill Run"), durationSeconds: 600),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 120)
            ],
            thumbnailImageName: "routine_11", routineTagline: "Build strength while primed for gains",
            routineDescription: "Progressive lower body strength session for 35-40 minutes.",
            phase: .follicular, routineType: .strength
        ),
        Routine(
            id: UUID(), name: "Upper Body Builder",
            exercises: [
                RoutineExercise(exercise: ex("Jumping Jacks"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Lat Pulldown"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Cable Row"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Face Pulls"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Lateral Raises"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Elliptical Trainer"), durationSeconds: 600),
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 120)
            ],
            thumbnailImageName: "routine_12", routineTagline: "Sculpt and strengthen upper body",
            routineDescription: "Upper body strength training leveraging peak 30-40 minute consistency layout.",
            phase: .follicular, routineType: .strength
        ),
        Routine(
            id: UUID(), name: "Cardio & Core Combo",
            exercises: [
                RoutineExercise(exercise: ex("Hip Rotation"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Bicycle Crunch"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Leg Raises"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Jump Rope"), durationSeconds: 900),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 180)
            ],
            thumbnailImageName: "routine_13", routineTagline: "Boost metabolism with cardio and core",
            routineDescription: "Combines cardiovascular intervals with core strengthening.",
            phase: .follicular, routineType: .mixed
        ),
        Routine(
            id: UUID(), name: "Dynamic Warm-Up",
            exercises: [
                RoutineExercise(exercise: ex("Jumping Jacks"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Lunges"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Treadmill Run"), durationSeconds: 900),
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 180)
            ],
            thumbnailImageName: "routine_14", routineTagline: "Warm up progressively for peak performance",
            routineDescription: "A 30-40 minute preparation routine transitioning from mobility to strength.",
            phase: .follicular, routineType: .mixed
        ),
        Routine(
            id: UUID(), name: "Full Body Activation",
            exercises: [
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Bent Over Row"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Glute Bridge"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Elliptical Trainer"), durationSeconds: 900),
                RoutineExercise(exercise: ex("Plank"), durationSeconds: 180)
            ],
            thumbnailImageName: "routine_15", routineTagline: "Total body activation",
            routineDescription: "Balanced 35-40 min full body session.",
            phase: .follicular, routineType: .mixed
        )
    ]

    // MARK: - Ovulation Phase Routines (peak energy — high intensity)

    
    private lazy var ovulationRoutines: [Routine] = [
        Routine(
            id: UUID(), name: "Power Yoga",
            exercises: [
                RoutineExercise(exercise: ex("Plank"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Bhujangasana"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Bow Pose"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Malasana (Yogic Squat)"), durationSeconds: 420)
            ],
            thumbnailImageName: "routine_9", routineTagline: "Challenge your body with power yoga",
            routineDescription: "Power yoga during ovulation harnesses peak estrogen and testosterone.",
            phase: .ovulation, routineType: .yoga
        ),
        Routine(
            id: UUID(), name: "Flexibility Flow",
            exercises: [
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Bow Pose"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Malasana (Yogic Squat)"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Bhujangasana"), durationSeconds: 420)
            ],
            thumbnailImageName: "routine_10", routineTagline: "Push flexibility boundaries",
            routineDescription: "A 35-minute flow focusing on longer holds to build range of motion.",
            phase: .ovulation, routineType: .yoga
        ),
        Routine(
            id: UUID(), name: "Build & Burn Legs",
            exercises: [
                RoutineExercise(exercise: ex("Jump Rope"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Deadlift"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Leg Press"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Seated Calf Raises"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Treadmill Run"), durationSeconds: 600),
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 120)
            ],
            thumbnailImageName: "routine_11", routineTagline: "Peak energy calls for compounds",
            routineDescription: "A consistency-first, 30-40 min PCOS lower body session.",
            phase: .ovulation, routineType: .strength
        ),
        Routine(
            id: UUID(), name: "Maximum Strength Upper",
            exercises: [
                RoutineExercise(exercise: ex("Jumping Jacks"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Bent Over Row"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Lat Pulldown"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Hammer Curl"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Lateral Raises"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Elliptical Trainer"), durationSeconds: 600),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 120)
            ],
            thumbnailImageName: "routine_12", routineTagline: "Push your limits during your strongest phase",
            routineDescription: "Mid-cycle peak upper body focus for ~35 minutes.",
            phase: .ovulation, routineType: .strength
        ),
        Routine(
            id: UUID(), name: "HIIT Fusion",
            exercises: [
                RoutineExercise(exercise: ex("Jump Rope"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Bicycle Crunch"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Treadmill Run"), durationSeconds: 900),
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 180)
            ],
            thumbnailImageName: "routine_13", routineTagline: "High-intensity intervals for peak days",
            routineDescription: "Alternating high-intensity cardio with steady components.",
            phase: .ovulation, routineType: .mixed
        ),
        Routine(
            id: UUID(), name: "Total Body Challenge",
            exercises: [
                RoutineExercise(exercise: ex("Hip Rotation"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Deadlift"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Cable Row"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Elliptical Trainer"), durationSeconds: 900),
                RoutineExercise(exercise: ex("Plank"), durationSeconds: 180)
            ],
            thumbnailImageName: "routine_14", routineTagline: "A complete full-body challenge",
            routineDescription: "Combining heavy compounds with ~15 min core steady state.",
            phase: .ovulation, routineType: .mixed
        ),
        Routine(
            id: UUID(), name: "Peak Performance",
            exercises: [
                RoutineExercise(exercise: ex("Jumping Jacks"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Lat Pulldown"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Treadmill Run"), durationSeconds: 900),
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 180)
            ],
            thumbnailImageName: "routine_15", routineTagline: "Train at your peak",
            routineDescription: "35-minute peak performance workout.",
            phase: .ovulation, routineType: .mixed
        )
    ]

    // MARK: - Luteal Phase Routines (declining energy — moderate, mindful)

    
    private lazy var lutealRoutines: [Routine] = [
        Routine(
            id: UUID(), name: "Calming Yoga",
            exercises: [
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Hip Rotation"), durationSeconds: 420)
            ],
            thumbnailImageName: "routine_9", routineTagline: "Calm your nervous system",
            routineDescription: "A soothing 30-40 min session to calm anxiety and ease PMS.",
            phase: .luteal, routineType: .yoga
        ),
        Routine(
            id: UUID(), name: "Yin Stretch",
            exercises: [
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Malasana (Yogic Squat)"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Hip Rotation"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 420)
            ],
            thumbnailImageName: "routine_10", routineTagline: "Long-held stretches for release",
            routineDescription: "Yin-style 35-min session targeting connective fascia.",
            phase: .luteal, routineType: .yoga
        ),
        Routine(
            id: UUID(), name: "Moderate Lower Body",
            exercises: [
                RoutineExercise(exercise: ex("Hip Rotation"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Glute Bridge"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Lunges"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Leg Extension"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Incline Treadmill Walk"), durationSeconds: 600),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 120)
            ],
            thumbnailImageName: "routine_11", routineTagline: "Maintain strength without overload",
            routineDescription: "Focuses on consistency during the latter half of the cycle. 35 mins.",
            phase: .luteal, routineType: .strength
        ),
        Routine(
            id: UUID(), name: "Steady Resistance",
            exercises: [
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Cable Row"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Lat Pulldown"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Face Pulls"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Seated Calf Raises"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Elliptical Trainer"), durationSeconds: 600),
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 120)
            ],
            thumbnailImageName: "routine_12", routineTagline: "Consistent steady resistance",
            routineDescription: "Machine-based and controlled 30-40 min workout to stay on track.",
            phase: .luteal, routineType: .strength
        ),
        Routine(
            id: UUID(), name: "Slow Burn",
            exercises: [
                RoutineExercise(exercise: ex("Hip Rotation"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Glute Bridge"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Bird Dog"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Incline Treadmill Walk"), durationSeconds: 900),
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 180)
            ],
            thumbnailImageName: "routine_13", routineTagline: "Low-impact movement to keep momentum",
            routineDescription: "Incline walking with glute activation for a full 35-min duration.",
            phase: .luteal, routineType: .mixed
        ),
        Routine(
            id: UUID(), name: "Mindful Movement",
            exercises: [
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Plank"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Elliptical Trainer"), durationSeconds: 900),
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 180)
            ],
            thumbnailImageName: "routine_14", routineTagline: "Move with intention and body awareness",
            routineDescription: "Bridges yoga and traditional training evenly.",
            phase: .luteal, routineType: .mixed
        ),
        Routine(
            id: UUID(), name: "Balanced Recovery",
            exercises: [
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Lunges"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Bicycle Crunch"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Incline Treadmill Walk"), durationSeconds: 900),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 180)
            ],
            thumbnailImageName: "routine_15", routineTagline: "Balance activity and recovery",
            routineDescription: "Low cortisol 30-40 min workout promoting circulation.",
            phase: .luteal, routineType: .mixed
        )
    ]

    // MARK: - Unknown Phase Routines (general, balanced — safe for any phase)

    private lazy var unknownRoutines: [Routine] = [
        Routine(
            id: UUID(), name: "Gentle Yoga Flow",
            exercises: [
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Bhujangasana"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 420)
            ],
            thumbnailImageName: "routine_9", routineTagline: "A safe, gentle yoga flow",
            routineDescription: "When cycle phase is unknown, this 30-40 min gentle flow is perfect.",
            phase: .unknown, routineType: .yoga
        ),
        Routine(
            id: UUID(), name: "Grounding Stretch",
            exercises: [
                RoutineExercise(exercise: ex("Malasana (Yogic Squat)"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Hip Rotation"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 420),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 420)
            ],
            thumbnailImageName: "routine_10", routineTagline: "Ground yourself with pelvic stretches",
            routineDescription: "A 35-min grounding sequence improving circulation.",
            phase: .unknown, routineType: .yoga
        ),
        Routine(
            id: UUID(), name: "General Strength Legs",
            exercises: [
                RoutineExercise(exercise: ex("Jumping Jacks"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Glute Bridge"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Leg Press"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Seated Calf Raises"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Treadmill Run"), durationSeconds: 600),
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 120)
            ],
            thumbnailImageName: "routine_11", routineTagline: "Foundational strength training",
            routineDescription: "A balanced lower body strength session for 35 minutes.",
            phase: .unknown, routineType: .strength
        ),
        Routine(
            id: UUID(), name: "Body Balance Back",
            exercises: [
                RoutineExercise(exercise: ex("Hip Rotation"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Bent Over Row"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Cable Row"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Lat Pulldown"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Face Pulls"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Elliptical Trainer"), durationSeconds: 600),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 120)
            ],
            thumbnailImageName: "routine_12", routineTagline: "Balance upper body strength",
            routineDescription: "Symmetrical training stimulus mirroring the trainer's 35 min guide.",
            phase: .unknown, routineType: .strength
        ),
        Routine(
            id: UUID(), name: "Adaptive Movement",
            exercises: [
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Bird Dog"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Incline Treadmill Walk"), durationSeconds: 900),
                RoutineExercise(exercise: ex("Glute Bridge"), durationSeconds: 180)
            ],
            thumbnailImageName: "routine_13", routineTagline: "Adapt your workout to how you feel",
            routineDescription: "A moderately paced 30-40 min session.",
            phase: .unknown, routineType: .mixed
        ),
        Routine(
            id: UUID(), name: "Core & Stretch",
            exercises: [
                RoutineExercise(exercise: ex("Hip Rotation"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Bicycle Crunch"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Leg Raises"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Incline Treadmill Walk"), durationSeconds: 900),
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 180)
            ],
            thumbnailImageName: "routine_14", routineTagline: "Strengthen core and stretch",
            routineDescription: "Core strength paired with endurance and deep stretching.",
            phase: .unknown, routineType: .mixed
        ),
        Routine(
            id: UUID(), name: "Easy Full Body",
            exercises: [
                RoutineExercise(exercise: ex("Jumping Jacks"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Face Pulls"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Elliptical Trainer"), durationSeconds: 900),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 180)
            ],
            thumbnailImageName: "routine_15", routineTagline: "An easy full body session",
            routineDescription: "A light 35 min full-body circuit with warm-up, and consistent reps.",
            phase: .unknown, routineType: .mixed
        )
    ]
}
