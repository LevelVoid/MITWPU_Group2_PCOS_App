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
        // YOGA 1
        Routine(
            id: UUID(),
            name: "Gentle Flow",
            exercises: [
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 120),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Bhujangasana"), durationSeconds: 60)
            ],
            thumbnailImageName: "routine_9",
            routineTagline: "Ease into movement with breath-led yoga",
            routineDescription: "A gentle yoga flow designed for the menstrual phase when energy is lowest. Prioritizes spinal mobility, hip opening, and diaphragmatic breathing to reduce cramp intensity and calm the nervous system. Research shows gentle yoga during menstruation reduces prostaglandin activity and lowers perceived pain in PCOS.",
            phase: .menstrual,
            routineType: .yoga
        ),
        // YOGA 2
        Routine(
            id: UUID(),
            name: "Restorative Stretch",
            exercises: [
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 120),
                RoutineExercise(exercise: ex("Hip Rotation"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Malasana (Yogic Squat)"), durationSeconds: 60)
            ],
            thumbnailImageName: "routine_10",
            routineTagline: "Deep stretches to ease tension and cramps",
            routineDescription: "Restorative stretching targets the hips, pelvis, and lower back — areas most affected during menstruation. Slow holds reduce muscle guarding and promote parasympathetic activation. For PCOS, this helps manage the elevated cortisol levels that worsen insulin resistance during the menstrual phase.",
            phase: .menstrual,
            routineType: .yoga
        ),
        // STRENGTH 1
        Routine(
            id: UUID(),
            name: "Light Core Activation",
            exercises: [
                RoutineExercise(exercise: ex("Bird Dog"), numberOfSets: 2, reps: 8),
                RoutineExercise(exercise: ex("Glute Bridge"), numberOfSets: 2, reps: 10),
                RoutineExercise(exercise: ex("Plank"), durationSeconds: 30),
                RoutineExercise(exercise: ex("Leg Raises"), numberOfSets: 2, reps: 8)
            ],
            thumbnailImageName: "routine_11",
            routineTagline: "Gentle core work without overstressing the body",
            routineDescription: "Light core activation keeps muscles engaged without spiking cortisol. Bird dog and glute bridge stabilize the pelvis during menstruation. Studies on PCOS recommend low-intensity resistance work during menses to maintain metabolic benefits without exacerbating inflammation or fatigue.",
            phase: .menstrual,
            routineType: .strength
        ),
        // STRENGTH 2
        Routine(
            id: UUID(),
            name: "Lower Body Ease",
            exercises: [
                RoutineExercise(exercise: ex("Glute Bridge"), numberOfSets: 2, reps: 12),
                RoutineExercise(exercise: ex("Lunges"), numberOfSets: 2, reps: 8),
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 2, reps: 10),
                RoutineExercise(exercise: ex("Seated Calf Raises"), numberOfSets: 2, reps: 12)
            ],
            thumbnailImageName: "routine_12",
            routineTagline: "Keep legs moving with low-impact strength",
            routineDescription: "A bodyweight-friendly lower body session with reduced volume. Glute activation supports pelvic blood flow. Evidence suggests maintaining lower body movement during menstruation improves mood and reduces bloating, while the low volume prevents cortisol overproduction common in PCOS.",
            phase: .menstrual,
            routineType: .strength
        ),
        // MIXED 1
        Routine(
            id: UUID(),
            name: "Low Energy Movement",
            exercises: [
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 120),
                RoutineExercise(exercise: ex("Hip Rotation"), durationSeconds: 120),
                RoutineExercise(exercise: ex("Glute Bridge"), numberOfSets: 2, reps: 12),
                RoutineExercise(exercise: ex("Incline Treadmill Walk"), durationSeconds: 300)
            ],
            thumbnailImageName: "routine_13",
            routineTagline: "When fatigue is high and your body needs gentle support",
            routineDescription: "Designed for days of low energy and physical fatigue, this routine prioritizes gentle activation and mobility to avoid excessive cortisol spikes. Slow, controlled movement supports hormonal balance, improves circulation, and encourages recovery without overloading the nervous system—making it ideal for PCOS users on depleted days.",
            phase: .menstrual,
            routineType: .mixed
        ),
        // MIXED 2
        Routine(
            id: UUID(),
            name: "Calm & Steady",
            exercises: [
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 120),
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Plank"), durationSeconds: 30),
                RoutineExercise(exercise: ex("Face Pulls"), numberOfSets: 2, reps: 12),
                RoutineExercise(exercise: ex("Cable Row"), numberOfSets: 2, reps: 10)
            ],
            thumbnailImageName: "routine_14",
            routineTagline: "Slow, stabilizing movement for overwhelming days",
            routineDescription: "This routine supports stress regulation by emphasizing steady, grounding movements that help calm the nervous system. By reducing sympathetic overactivation and cortisol output, it aids hormonal stability while improving posture and muscular control—especially useful during mentally overwhelming or emotionally taxing days.",
            phase: .menstrual,
            routineType: .mixed
        ),
        // MIXED 3
        Routine(
            id: UUID(),
            name: "Gentle Mobility",
            exercises: [
                RoutineExercise(exercise: ex("Hip Rotation"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Malasana (Yogic Squat)"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Bird Dog"), numberOfSets: 2, reps: 8),
                RoutineExercise(exercise: ex("Incline Treadmill Walk"), durationSeconds: 300)
            ],
            thumbnailImageName: "routine_15",
            routineTagline: "Open hips and move gently through discomfort",
            routineDescription: "Mobility-focused with light walking to promote lymphatic drainage and reduce pelvic congestion during menstruation. Hip openers relieve cramp tension while the walking component keeps metabolism active. For PCOS, maintaining light activity during menses prevents the cortisol spike that comes from complete inactivity.",
            phase: .menstrual,
            routineType: .mixed
        )
    ]

    // MARK: - Follicular Phase Routines (rising energy — progressive challenge)

    private lazy var follicularRoutines: [Routine] = [
        // YOGA 1
        Routine(
            id: UUID(),
            name: "Energizing Yoga Flow",
            exercises: [
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Bhujangasana"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Bow Pose"), durationSeconds: 45),
                RoutineExercise(exercise: ex("Malasana (Yogic Squat)"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 60)
            ],
            thumbnailImageName: "routine_9",
            routineTagline: "Channel rising energy into dynamic yoga",
            routineDescription: "As estrogen rises during the follicular phase, energy, motivation, and tolerance for intensity increase. This flow uses backbends and dynamic holds to build heat and improve spinal flexibility. Research shows follicular-phase exercise yields greater strength gains in PCOS due to improved insulin sensitivity.",
            phase: .follicular,
            routineType: .yoga
        ),
        // YOGA 2
        Routine(
            id: UUID(),
            name: "Sun Salutation Series",
            exercises: [
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 45),
                RoutineExercise(exercise: ex("Bhujangasana"), durationSeconds: 45),
                RoutineExercise(exercise: ex("Plank"), durationSeconds: 45),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 45),
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 60)
            ],
            thumbnailImageName: "routine_10",
            routineTagline: "Classic sun salutation adapted for PCOS",
            routineDescription: "A sun salutation sequence that builds body heat and cardiovascular endurance while maintaining mindfulness. The follicular phase's rising estrogen supports muscle recovery, making this the ideal time for moderate-intensity yoga. For PCOS, this improves glucose uptake and reduces androgen levels.",
            phase: .follicular,
            routineType: .yoga
        ),
        // STRENGTH 1
        Routine(
            id: UUID(),
            name: "Progressive Strength",
            exercises: [
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Bent Over Row"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Lunges"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Lateral Raises"), numberOfSets: 3, reps: 12),
                RoutineExercise(exercise: ex("Plank"), durationSeconds: 45)
            ],
            thumbnailImageName: "routine_11",
            routineTagline: "Build strength while your body is primed for gains",
            routineDescription: "The follicular phase is when your body responds best to progressive overload. Rising estrogen enhances muscle protein synthesis and recovery. This full-body strength session targets major muscle groups to improve insulin sensitivity — the single most important metabolic intervention for PCOS management.",
            phase: .follicular,
            routineType: .strength
        ),
        // STRENGTH 2
        Routine(
            id: UUID(),
            name: "Upper Body Builder",
            exercises: [
                RoutineExercise(exercise: ex("Lat Pulldown"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Cable Row"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Face Pulls"), numberOfSets: 3, reps: 12),
                RoutineExercise(exercise: ex("Hammer Curl"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Lateral Raises"), numberOfSets: 3, reps: 12)
            ],
            thumbnailImageName: "routine_12",
            routineTagline: "Sculpt and strengthen with focused upper body work",
            routineDescription: "Upper body strength training during the follicular phase leverages peak estrogen for superior recovery. Compound pulls build lean mass which directly improves basal metabolic rate — critical for PCOS weight management. Higher testosterone tolerance during this phase supports heavier lifting.",
            phase: .follicular,
            routineType: .strength
        ),
        // MIXED 1
        Routine(
            id: UUID(),
            name: "Cardio & Core Combo",
            exercises: [
                RoutineExercise(exercise: ex("Jumping Jacks"), durationSeconds: 120),
                RoutineExercise(exercise: ex("Bicycle Crunch"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Plank"), durationSeconds: 45),
                RoutineExercise(exercise: ex("Jump Rope"), durationSeconds: 120),
                RoutineExercise(exercise: ex("Leg Raises"), numberOfSets: 3, reps: 12)
            ],
            thumbnailImageName: "routine_13",
            routineTagline: "Boost metabolism with cardio and core fusion",
            routineDescription: "Combining cardiovascular intervals with core strengthening maximizes calorie burn and EPOC. During the follicular phase, your body handles higher heart rates more efficiently. For PCOS, this combination improves VO2 max and reduces visceral fat — a key driver of insulin resistance.",
            phase: .follicular,
            routineType: .mixed
        ),
        // MIXED 2
        Routine(
            id: UUID(),
            name: "Dynamic Warm-Up",
            exercises: [
                RoutineExercise(exercise: ex("Jumping Jacks"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Hip Rotation"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 3, reps: 12),
                RoutineExercise(exercise: ex("Lunges"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 60)
            ],
            thumbnailImageName: "routine_14",
            routineTagline: "Warm up progressively for peak performance",
            routineDescription: "A dynamic preparation routine that transitions from mobility to bodyweight strength. Perfect for the follicular phase when your neuromuscular system is primed for coordination and power. For PCOS, dynamic warm-ups improve blood glucose regulation before and after meals.",
            phase: .follicular,
            routineType: .mixed
        ),
        // MIXED 3
        Routine(
            id: UUID(),
            name: "Full Body Activation",
            exercises: [
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Bent Over Row"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Glute Bridge"), numberOfSets: 3, reps: 12),
                RoutineExercise(exercise: ex("Treadmill Run"), durationSeconds: 300),
                RoutineExercise(exercise: ex("Plank"), durationSeconds: 45)
            ],
            thumbnailImageName: "routine_15",
            routineTagline: "Total body activation for rising energy days",
            routineDescription: "A comprehensive full-body session that includes compound strength, posterior chain work, and cardiovascular endurance. The follicular phase supports higher training volume. For PCOS, full-body sessions are most effective at improving whole-body insulin sensitivity and reducing circulating androgens.",
            phase: .follicular,
            routineType: .mixed
        )
    ]

    // MARK: - Ovulation Phase Routines (peak energy — high intensity)

    private lazy var ovulationRoutines: [Routine] = [
        // YOGA 1
        Routine(
            id: UUID(),
            name: "Power Yoga",
            exercises: [
                RoutineExercise(exercise: ex("Plank"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 45),
                RoutineExercise(exercise: ex("Bhujangasana"), durationSeconds: 45),
                RoutineExercise(exercise: ex("Bow Pose"), durationSeconds: 45),
                RoutineExercise(exercise: ex("Malasana (Yogic Squat)"), durationSeconds: 45)
            ],
            thumbnailImageName: "routine_9",
            routineTagline: "Challenge your body with power yoga at peak energy",
            routineDescription: "Power yoga during ovulation harnesses peak estrogen and testosterone levels for maximum strength and endurance in yoga poses. Extended plank and deep backbends build functional strength. Evidence shows vigorous yoga during ovulation significantly improves insulin sensitivity in PCOS, with lasting effects into the luteal phase.",
            phase: .ovulation,
            routineType: .yoga
        ),
        // YOGA 2
        Routine(
            id: UUID(),
            name: "Flexibility Flow",
            exercises: [
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Bow Pose"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Malasana (Yogic Squat)"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Bhujangasana"), durationSeconds: 60)
            ],
            thumbnailImageName: "routine_10",
            routineTagline: "Push flexibility boundaries when your body is most supple",
            routineDescription: "Estrogen peaks at ovulation, increasing joint laxity and flexibility. This flow uses deeper stretches to build range of motion safely. For PCOS, maintaining flexibility reduces musculoskeletal pain driven by chronic inflammation and improves lymphatic circulation to reduce water retention.",
            phase: .ovulation,
            routineType: .yoga
        ),
        // STRENGTH 1
        Routine(
            id: UUID(),
            name: "Build & Burn",
            exercises: [
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 4, reps: 8),
                RoutineExercise(exercise: ex("Deadlift"), numberOfSets: 3, reps: 8),
                RoutineExercise(exercise: ex("Lat Pulldown"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Leg Press"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Jumping Jacks"), durationSeconds: 120)
            ],
            thumbnailImageName: "routine_11",
            routineTagline: "Peak energy calls for maximum effort compound lifts",
            routineDescription: "Built for peak-energy ovulation days, this routine focuses on heavy compound movements that maximize insulin sensitivity, lean muscle mass, and metabolic efficiency — all critical for PCOS management. Peak testosterone supports personal bests while structured rest prevents cortisol overload.",
            phase: .ovulation,
            routineType: .strength
        ),
        // STRENGTH 2
        Routine(
            id: UUID(),
            name: "Maximum Strength",
            exercises: [
                RoutineExercise(exercise: ex("Leg Press"), numberOfSets: 4, reps: 8),
                RoutineExercise(exercise: ex("Bent Over Row"), numberOfSets: 3, reps: 8),
                RoutineExercise(exercise: ex("Leg Extension"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Hammer Curl"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Lateral Raises"), numberOfSets: 3, reps: 12)
            ],
            thumbnailImageName: "routine_12",
            routineTagline: "Push your limits during your strongest phase",
            routineDescription: "Higher intensity strength training during ovulation yields the greatest muscle adaptation due to peak hormone levels. Compound lower-body and pulling movements build the most metabolically active tissue. For PCOS, every kg of muscle gained improves resting glucose disposal by up to 10%.",
            phase: .ovulation,
            routineType: .strength
        ),
        // MIXED 1
        Routine(
            id: UUID(),
            name: "HIIT Fusion",
            exercises: [
                RoutineExercise(exercise: ex("Jump Rope"), durationSeconds: 120),
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 3, reps: 12),
                RoutineExercise(exercise: ex("Jumping Jacks"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Bicycle Crunch"), numberOfSets: 3, reps: 15),
                RoutineExercise(exercise: ex("Treadmill Run"), durationSeconds: 300)
            ],
            thumbnailImageName: "routine_13",
            routineTagline: "High-intensity intervals for peak performance days",
            routineDescription: "HIIT during ovulation takes advantage of the body's highest cardiovascular capacity and fastest recovery. Alternating high-intensity cardio with strength movements maximizes EPOC and fat oxidation. PCOS research strongly supports HIIT for reducing visceral fat and normalizing androgen levels.",
            phase: .ovulation,
            routineType: .mixed
        ),
        // MIXED 2
        Routine(
            id: UUID(),
            name: "Total Body Challenge",
            exercises: [
                RoutineExercise(exercise: ex("Deadlift"), numberOfSets: 3, reps: 8),
                RoutineExercise(exercise: ex("Lunges"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Cable Row"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Plank"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Elliptical Trainer"), durationSeconds: 300)
            ],
            thumbnailImageName: "routine_14",
            routineTagline: "A complete full-body challenge at your strongest",
            routineDescription: "Combining heavy compounds, core stability, and steady-state cardio creates the most comprehensive metabolic stimulus. Ovulation phase hormones support this training density. For PCOS, this combination addresses all three metabolic pillars: insulin sensitivity, lean mass, and cardiovascular fitness.",
            phase: .ovulation,
            routineType: .mixed
        ),
        // MIXED 3
        Routine(
            id: UUID(),
            name: "Peak Performance",
            exercises: [
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 4, reps: 10),
                RoutineExercise(exercise: ex("Lat Pulldown"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Leg Raises"), numberOfSets: 3, reps: 12),
                RoutineExercise(exercise: ex("Jump Rope"), durationSeconds: 180),
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 60)
            ],
            thumbnailImageName: "routine_15",
            routineTagline: "Train at your peak — your body is ready",
            routineDescription: "This session balances heavy strength work with explosive cardio and a finishing yoga stretch. The ovulation window is optimal for performance testing. Studies show PCOS patients who train intensively during ovulation show greater reductions in fasting insulin and HOMA-IR compared to consistent-intensity training.",
            phase: .ovulation,
            routineType: .mixed
        )
    ]

    // MARK: - Luteal Phase Routines (declining energy — moderate, mindful)

    private lazy var lutealRoutines: [Routine] = [
        // YOGA 1
        Routine(
            id: UUID(),
            name: "Calming Yoga",
            exercises: [
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 120),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Hip Rotation"), durationSeconds: 60)
            ],
            thumbnailImageName: "routine_9",
            routineTagline: "Calm your nervous system as energy winds down",
            routineDescription: "The luteal phase brings rising progesterone and often PMS symptoms. Calming yoga activates the parasympathetic nervous system, reducing cortisol and the anxiety common in PCOS. Hip openers and forward folds help relieve the bloating and pelvic heaviness typical of this phase.",
            phase: .luteal,
            routineType: .yoga
        ),
        // YOGA 2
        Routine(
            id: UUID(),
            name: "Yin Stretch",
            exercises: [
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 120),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 120),
                RoutineExercise(exercise: ex("Malasana (Yogic Squat)"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Hip Rotation"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 90)
            ],
            thumbnailImageName: "routine_10",
            routineTagline: "Long-held stretches for deep tissue release",
            routineDescription: "Yin-style holds of 60+ seconds target connective tissue and fascia. During the luteal phase, progesterone increases joint laxity, making deep stretches both safer and more effective. For PCOS, reducing muscular tension lowers cortisol and improves sleep quality — a frequent luteal complaint.",
            phase: .luteal,
            routineType: .yoga
        ),
        // STRENGTH 1
        Routine(
            id: UUID(),
            name: "Moderate Strength",
            exercises: [
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Glute Bridge"), numberOfSets: 3, reps: 12),
                RoutineExercise(exercise: ex("Lunges"), numberOfSets: 2, reps: 10),
                RoutineExercise(exercise: ex("Face Pulls"), numberOfSets: 2, reps: 12)
            ],
            thumbnailImageName: "routine_11",
            routineTagline: "Maintain strength without overloading your system",
            routineDescription: "Moderate-intensity strength training during the luteal phase maintains muscle gains while respecting the body's lower recovery capacity. Progesterone raises core body temperature and heart rate, so perceived effort is higher. For PCOS, maintaining resistance training through the luteal phase prevents the metabolic decline that leads to weight cycling.",
            phase: .luteal,
            routineType: .strength
        ),
        // STRENGTH 2
        Routine(
            id: UUID(),
            name: "Steady Resistance",
            exercises: [
                RoutineExercise(exercise: ex("Cable Row"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Lat Pulldown"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Leg Extension"), numberOfSets: 2, reps: 12),
                RoutineExercise(exercise: ex("Seated Calf Raises"), numberOfSets: 2, reps: 15)
            ],
            thumbnailImageName: "routine_12",
            routineTagline: "Consistent resistance to stay on track",
            routineDescription: "Machine-based exercises provide stable, controlled resistance that's ideal when coordination and balance may be reduced during the luteal phase. Back-focused exercises improve posture after prolonged sitting. For PCOS, consistent resistance training even at moderate intensity keeps GLUT4 glucose transporters active.",
            phase: .luteal,
            routineType: .strength
        ),
        // MIXED 1
        Routine(
            id: UUID(),
            name: "Slow Burn",
            exercises: [
                RoutineExercise(exercise: ex("Incline Treadmill Walk"), durationSeconds: 300),
                RoutineExercise(exercise: ex("Glute Bridge"), numberOfSets: 3, reps: 12),
                RoutineExercise(exercise: ex("Bird Dog"), numberOfSets: 2, reps: 10),
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 90)
            ],
            thumbnailImageName: "routine_13",
            routineTagline: "Low-impact movement to keep momentum going",
            routineDescription: "Incline walking combined with glute and core activation provides steady calorie burn without cortisol spikes. During the luteal phase, the body's fat-burning capacity increases, making low-intensity steady-state exercise more efficient. For PCOS, this is optimal for fat oxidation without triggering inflammatory responses.",
            phase: .luteal,
            routineType: .mixed
        ),
        // MIXED 2
        Routine(
            id: UUID(),
            name: "Mindful Movement",
            exercises: [
                RoutineExercise(exercise: ex("Hip Rotation"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Plank"), durationSeconds: 30),
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 2, reps: 10),
                RoutineExercise(exercise: ex("Elliptical Trainer"), durationSeconds: 300)
            ],
            thumbnailImageName: "routine_14",
            routineTagline: "Move with intention and body awareness",
            routineDescription: "Mindful movement bridges the gap between yoga and traditional training. Focus on body awareness and controlled tempo reduces injury risk during the luteal phase when concentration may waver. For PCOS, mindful exercise reduces binge-eating risk — a common luteal phase behavior driven by serotonin drops.",
            phase: .luteal,
            routineType: .mixed
        ),
        // MIXED 3
        Routine(
            id: UUID(),
            name: "Balanced Recovery",
            exercises: [
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Lunges"), numberOfSets: 2, reps: 8),
                RoutineExercise(exercise: ex("Bicycle Crunch"), numberOfSets: 2, reps: 12),
                RoutineExercise(exercise: ex("Incline Treadmill Walk"), durationSeconds: 300)
            ],
            thumbnailImageName: "routine_15",
            routineTagline: "Balance activity and recovery as your cycle winds down",
            routineDescription: "This session balances mobility, light strength, and walking to support the body's transition toward menstruation. The combination keeps metabolism active while respecting the body's increased need for recovery. For PCOS, maintaining exercise consistency through the luteal phase prevents the metabolic regression that worsens symptoms.",
            phase: .luteal,
            routineType: .mixed
        )
    ]

    // MARK: - Unknown Phase Routines (general, balanced — safe for any phase)

    private lazy var unknownRoutines: [Routine] = [
        // YOGA 1
        Routine(
            id: UUID(),
            name: "Gentle Yoga Flow",
            exercises: [
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Bhujangasana"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 60)
            ],
            thumbnailImageName: "routine_9",
            routineTagline: "A safe, gentle yoga flow for any day",
            routineDescription: "When your cycle phase is unknown, this gentle yoga flow provides benefits without risk. Spinal mobility, hip opening, and breathing exercises support hormonal balance regardless of phase. For PCOS, regular yoga practice reduces cortisol, improves insulin sensitivity, and lowers anxiety scores.",
            phase: .unknown,
            routineType: .yoga
        ),
        // YOGA 2
        Routine(
            id: UUID(),
            name: "Grounding Stretch",
            exercises: [
                RoutineExercise(exercise: ex("Malasana (Yogic Squat)"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Hip Rotation"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 90)
            ],
            thumbnailImageName: "routine_10",
            routineTagline: "Ground yourself with pelvic and hip stretches",
            routineDescription: "Grounding stretches focus on the pelvic floor and hip complex — areas most affected in PCOS. Deep squats and hip openers improve circulation to reproductive organs. These stretches are safe and beneficial in any cycle phase, improving pelvic floor awareness and reducing chronic tension.",
            phase: .unknown,
            routineType: .yoga
        ),
        // STRENGTH 1
        Routine(
            id: UUID(),
            name: "General Strength",
            exercises: [
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Bent Over Row"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Glute Bridge"), numberOfSets: 3, reps: 12),
                RoutineExercise(exercise: ex("Plank"), durationSeconds: 45)
            ],
            thumbnailImageName: "routine_11",
            routineTagline: "Foundational strength training for PCOS",
            routineDescription: "A balanced full-body strength session that's safe for any cycle phase. Compound movements like squats and rows build the most metabolically active tissue. For PCOS, resistance training is the single most evidence-backed exercise intervention for improving insulin sensitivity and reducing androgen levels.",
            phase: .unknown,
            routineType: .strength
        ),
        // STRENGTH 2
        Routine(
            id: UUID(),
            name: "Body Balance",
            exercises: [
                RoutineExercise(exercise: ex("Lunges"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Cable Row"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Leg Press"), numberOfSets: 3, reps: 10),
                RoutineExercise(exercise: ex("Lateral Raises"), numberOfSets: 3, reps: 12)
            ],
            thumbnailImageName: "routine_12",
            routineTagline: "Balance upper and lower body strength equally",
            routineDescription: "Balancing push and pull patterns with lower body strength creates a symmetrical training stimulus. This prevents the muscle imbalances that lead to joint pain and postural issues. For PCOS, balanced resistance training normalizes growth hormone and IGF-1 patterns disrupted by hyperandrogenism.",
            phase: .unknown,
            routineType: .strength
        ),
        // MIXED 1
        Routine(
            id: UUID(),
            name: "Adaptive Movement",
            exercises: [
                RoutineExercise(exercise: ex("Incline Treadmill Walk"), durationSeconds: 300),
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 2, reps: 10),
                RoutineExercise(exercise: ex("Bird Dog"), numberOfSets: 2, reps: 10),
                RoutineExercise(exercise: ex("Cat Cow"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Glute Bridge"), numberOfSets: 2, reps: 12)
            ],
            thumbnailImageName: "routine_13",
            routineTagline: "Adapt your workout to how you feel today",
            routineDescription: "A moderately paced session that works regardless of your energy level. Walking, bodyweight strength, and mobility form a foundation that can be intensified or softened based on daily energy. For PCOS, consistent moderate exercise shows the strongest long-term improvements in metabolic markers.",
            phase: .unknown,
            routineType: .mixed
        ),
        // MIXED 2
        Routine(
            id: UUID(),
            name: "Core & Stretch",
            exercises: [
                RoutineExercise(exercise: ex("Plank"), durationSeconds: 45),
                RoutineExercise(exercise: ex("Bicycle Crunch"), numberOfSets: 3, reps: 12),
                RoutineExercise(exercise: ex("Leg Raises"), numberOfSets: 2, reps: 10),
                RoutineExercise(exercise: ex("Butterfly Stretch"), durationSeconds: 90),
                RoutineExercise(exercise: ex("Downward Dog"), durationSeconds: 60)
            ],
            thumbnailImageName: "routine_14",
            routineTagline: "Strengthen your core and stretch to recover",
            routineDescription: "Core strength paired with deep stretching creates an effective yet low-impact session. Strong core muscles support the spine and reduce lower back pain — a common PCOS complaint. Stretching afterwards promotes recovery and reduces the inflammatory markers elevated in PCOS.",
            phase: .unknown,
            routineType: .mixed
        ),
        // MIXED 3
        Routine(
            id: UUID(),
            name: "Easy Full Body",
            exercises: [
                RoutineExercise(exercise: ex("Jumping Jacks"), durationSeconds: 60),
                RoutineExercise(exercise: ex("Squats"), numberOfSets: 2, reps: 10),
                RoutineExercise(exercise: ex("Glute Bridge"), numberOfSets: 2, reps: 12),
                RoutineExercise(exercise: ex("Face Pulls"), numberOfSets: 2, reps: 12),
                RoutineExercise(exercise: ex("Child Pose"), durationSeconds: 60)
            ],
            thumbnailImageName: "routine_15",
            routineTagline: "An easy full body session to keep you moving",
            routineDescription: "A light full-body circuit with warm-up, lower body, upper body, and cool-down components. Low volume keeps cortisol manageable while providing a systemic metabolic stimulus. For PCOS, even brief exercise sessions improve post-meal glucose responses for up to 24 hours.",
            phase: .unknown,
            routineType: .mixed
        )
    ]
}
