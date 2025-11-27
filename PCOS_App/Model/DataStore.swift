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
            instructions: "Hold a push-up position with forearms on the ground. Keep body straight from head to heels. Engage core and hold position.",
            videoUrl: nil
        ),
        Exercise(
            name: "Russian Twists",
            muscleGroup: .core,
            equipment: .none,
            image: "russian_twists",
            instructions: "Sit with knees bent, lean back slightly. Twist torso side to side, touching ground beside hips.",
            videoUrl: nil
        ),
        Exercise(
            name: "Cable Crunches",
            muscleGroup: .core,
            equipment: .machine,
            image: "cable_crunches",
            instructions: "Kneel below cable machine, hold rope behind head. Crunch down using abs, not arms.",
            videoUrl: nil
        ),
        Exercise(
            name: "Bicycle Crunches",
            muscleGroup: .core,
            equipment: .none,
            image: "bicycle_crunches",
            instructions: "Lie on back, bring opposite elbow to opposite knee in cycling motion.",
            videoUrl: nil
        ),
        
        // CHEST EXERCISES
        Exercise(
            name: "Bench Press",
            muscleGroup: .chest,
            equipment: .barbell,
            image: "bench_press",
            instructions: "Lie on bench, lower barbell to chest, press up until arms are extended.",
            videoUrl: nil
        ),
        Exercise(
            name: "Dumbbell Chest Press",
            muscleGroup: .chest,
            equipment: .dumbbell,
            image: "dumbbell_press",
            instructions: "Lie on bench with dumbbells at chest level. Press up until arms extended, lower controlled.",
            videoUrl: nil
        ),
        Exercise(
            name: "Push-ups",
            muscleGroup: .chest,
            equipment: .none,
            image: "pushups",
            instructions: "Start in plank position, lower body until chest nearly touches ground, push back up.",
            videoUrl: nil
        ),
        Exercise(
            name: "Chest Fly",
            muscleGroup: .chest,
            equipment: .dumbbell,
            image: "chest_fly",
            instructions: "Lie on bench, arms extended with dumbbells. Lower arms out to sides, bring back together.",
            videoUrl: nil
        ),
        Exercise(
            name: "Cable Chest Fly",
            muscleGroup: .chest,
            equipment: .machine,
            image: "cable_fly",
            instructions: "Stand between cable towers, bring handles together in front of chest.",
            videoUrl: nil
        ),
        
        // BACK EXERCISES
        Exercise(
            name: "Deadlift",
            muscleGroup: .back,
            equipment: .barbell,
            image: "deadlift",
            instructions: "Stand with feet hip-width, bend to grip barbell. Lift by extending hips and knees, keep back straight.",
            videoUrl: nil
        ),
        Exercise(
            name: "Lat Pulldown",
            muscleGroup: .back,
            equipment: .machine,
            image: "lat_pulldown",
            instructions: "Sit at machine, grip bar wide. Pull down to upper chest, squeeze shoulder blades together.",
            videoUrl: nil
        ),
        Exercise(
            name: "Bent Over Barbell Row",
            muscleGroup: .back,
            equipment: .barbell,
            image: "barbell_row",
            instructions: "Bend forward at hips with barbell. Pull bar to lower chest, squeeze shoulder blades.",
            videoUrl: nil
        ),
        Exercise(
            name: "Dumbbell Row",
            muscleGroup: .back,
            equipment: .dumbbell,
            image: "dumbbell_row",
            instructions: "Support yourself on bench, row dumbbell to hip. Keep elbow close to body.",
            videoUrl: nil
        ),
        Exercise(
            name: "Pull-ups",
            muscleGroup: .back,
            equipment: .none,
            image: "pullups",
            instructions: "Hang from bar with overhand grip. Pull body up until chin over bar, lower controlled.",
            videoUrl: nil
        ),
        Exercise(
            name: "Seated Cable Row",
            muscleGroup: .back,
            equipment: .machine,
            image: "cable_row",
            instructions: "Sit at cable machine, pull handle to torso. Keep back straight, squeeze shoulder blades.",
            videoUrl: nil
        ),
        
        // LEG EXERCISES
        Exercise(
            name: "Barbell Squat",
            muscleGroup: .legs,
            equipment: .barbell,
            image: "barbell_squat",
            instructions: "Bar on upper back, feet shoulder-width. Lower hips back and down, drive through heels to stand.",
            videoUrl: nil
        ),
        Exercise(
            name: "Leg Press",
            muscleGroup: .legs,
            equipment: .machine,
            image: "leg_press",
            instructions: "Sit in machine with feet on platform. Push platform away by extending legs.",
            videoUrl: nil
        ),
        Exercise(
            name: "Lunges",
            muscleGroup: .legs,
            equipment: .none,
            image: "lunges",
            instructions: "Step forward, lower back knee toward ground. Push back to standing. Alternate legs.",
            videoUrl: nil
        ),
        Exercise(
            name: "Dumbbell Lunges",
            muscleGroup: .legs,
            equipment: .dumbbell,
            image: "dumbbell_lunges",
            instructions: "Hold dumbbells at sides. Step forward into lunge, return to start. Alternate legs.",
            videoUrl: nil
        ),
        Exercise(
            name: "Leg Extension",
            muscleGroup: .legs,
            equipment: .machine,
            image: "leg_extension",
            instructions: "Sit in machine, extend legs to straighten knees. Lower controlled.",
            videoUrl: nil
        ),
        Exercise(
            name: "Leg Curl",
            muscleGroup: .legs,
            equipment: .machine,
            image: "leg_curl",
            instructions: "Lie face down, curl legs up toward glutes. Lower controlled.",
            videoUrl: nil
        ),
        Exercise(
            name: "Goblet Squat",
            muscleGroup: .legs,
            equipment: .dumbbell,
            image: "goblet_squat",
            instructions: "Hold dumbbell at chest. Squat down keeping chest up, drive through heels to stand.",
            videoUrl: nil
        ),
        
        // SHOULDER EXERCISES
        Exercise(
            name: "Overhead Press",
            muscleGroup: .shoulders,
            equipment: .barbell,
            image: "overhead_press",
            instructions: "Stand with barbell at shoulders. Press overhead until arms extended, lower controlled.",
            videoUrl: nil
        ),
        Exercise(
            name: "Dumbbell Shoulder Press",
            muscleGroup: .shoulders,
            equipment: .dumbbell,
            image: "dumbbell_press",
            instructions: "Sit or stand with dumbbells at shoulders. Press up overhead, lower to start.",
            videoUrl: nil
        ),
        Exercise(
            name: "Lateral Raises",
            muscleGroup: .shoulders,
            equipment: .dumbbell,
            image: "lateral_raises",
            instructions: "Stand with dumbbells at sides. Raise arms out to sides until parallel to ground.",
            videoUrl: nil
        ),
        Exercise(
            name: "Front Raises",
            muscleGroup: .shoulders,
            equipment: .dumbbell,
            image: "front_raises",
            instructions: "Stand with dumbbells in front of thighs. Raise arms forward to shoulder height.",
            videoUrl: nil
        ),
        Exercise(
            name: "Face Pulls",
            muscleGroup: .shoulders,
            equipment: .machine,
            image: "face_pulls",
            instructions: "Pull rope toward face, separating handles. Squeeze shoulder blades together.",
            videoUrl: nil
        ),
        
        // ARM EXERCISES
        Exercise(
            name: "Barbell Curl",
            muscleGroup: .arms,
            equipment: .barbell,
            image: "barbell_curl",
            instructions: "Stand with barbell, curl up to shoulders keeping elbows stationary. Lower controlled.",
            videoUrl: nil
        ),
        Exercise(
            name: "Dumbbell Curl",
            muscleGroup: .arms,
            equipment: .dumbbell,
            image: "dumbbell_curl",
            instructions: "Stand with dumbbells at sides. Curl up, rotating palms up. Lower controlled.",
            videoUrl: nil
        ),
        Exercise(
            name: "Tricep Dips",
            muscleGroup: .arms,
            equipment: .none,
            image: "tricep_dips",
            instructions: "Support body on bars or bench. Lower body by bending elbows, push back up.",
            videoUrl: nil
        ),
        Exercise(
            name: "Tricep Pushdown",
            muscleGroup: .arms,
            equipment: .machine,
            image: "tricep_pushdown",
            instructions: "Stand at cable machine. Push rope or bar down by extending elbows, return controlled.",
            videoUrl: nil
        ),
        Exercise(
            name: "Hammer Curl",
            muscleGroup: .arms,
            equipment: .dumbbell,
            image: "hammer_curl",
            instructions: "Hold dumbbells with neutral grip. Curl up keeping palms facing each other.",
            videoUrl: nil
        ),
        Exercise(
            name: "Overhead Tricep Extension",
            muscleGroup: .arms,
            equipment: .dumbbell,
            image: "overhead_tricep",
            instructions: "Hold dumbbell overhead with both hands. Lower behind head, extend arms back up.",
            videoUrl: nil
        ),
        
        // GLUTE EXERCISES
        Exercise(
            name: "Hip Thrust",
            muscleGroup: .glutes,
            equipment: .barbell,
            image: "hip_thrust",
            instructions: "Upper back on bench, barbell over hips. Drive hips up, squeeze glutes at top.",
            videoUrl: nil
        ),
        Exercise(
            name: "Glute Bridge",
            muscleGroup: .glutes,
            equipment: .none,
            image: "glute_bridge",
            instructions: "Lie on back, knees bent. Drive hips up, squeeze glutes, lower controlled.",
            videoUrl: nil
        ),
        Exercise(
            name: "Bulgarian Split Squat",
            muscleGroup: .glutes,
            equipment: .dumbbell,
            image: "bulgarian_split",
            instructions: "Rear foot elevated on bench. Lower into lunge, drive through front heel to stand.",
            videoUrl: nil
        ),
        Exercise(
            name: "Cable Kickbacks",
            muscleGroup: .glutes,
            equipment: .machine,
            image: "cable_kickbacks",
            instructions: "Attach ankle strap. Kick leg back, squeeze glute. Return controlled.",
            videoUrl: nil
        ),
        Exercise(
            name: "Dumbbell Romanian Deadlift",
            muscleGroup: .glutes,
            equipment: .dumbbell,
            image: "romanian_deadlift",
            instructions: "Hold dumbbells, hinge at hips keeping back straight. Feel stretch in hamstrings, return to stand.",
            videoUrl: nil
        ),
        
        // CARDIO EXERCISES
        Exercise(
            name: "Jumping Jacks",
            muscleGroup: .cardio,
            equipment: .none,
            image: "jumping_jacks",
            instructions: "Jump while spreading legs and raising arms overhead. Return to start. Repeat continuously.",
            videoUrl: nil
        ),
        Exercise(
            name: "Burpees",
            muscleGroup: .cardio,
            equipment: .none,
            image: "burpees",
            instructions: "Squat, place hands down, jump feet back, do push-up, jump feet forward, jump up.",
            videoUrl: nil
        ),
        Exercise(
            name: "Mountain Climbers",
            muscleGroup: .cardio,
            equipment: .none,
            image: "mountain_climbers",
            instructions: "Start in plank. Alternate bringing knees to chest in running motion.",
            videoUrl: nil
        ),
        Exercise(
            name: "High Knees",
            muscleGroup: .cardio,
            equipment: .none,
            image: "high_knees",
            instructions: "Run in place bringing knees up to hip level. Move quickly.",
            videoUrl: nil
        ),
        Exercise(
            name: "Jump Rope",
            muscleGroup: .cardio,
            equipment: .none,
            image: "jump_rope",
            instructions: "Swing rope and jump over it continuously. Stay on balls of feet.",
            videoUrl: nil
        ),
        
        // MOBILITY EXERCISES
        Exercise(
            name: "Cat-Cow Stretch",
            muscleGroup: .mobility,
            equipment: .none,
            image: "cat_cow",
            instructions: "On hands and knees, alternate between arching back and rounding spine.",
            videoUrl: nil
        ),
        Exercise(
            name: "World's Greatest Stretch",
            muscleGroup: .mobility,
            equipment: .none,
            image: "worlds_greatest",
            instructions: "Lunge position, rotate torso, reach arm overhead. Hold briefly, switch sides.",
            videoUrl: nil
        ),
        Exercise(
            name: "Hip Circles",
            muscleGroup: .mobility,
            equipment: .none,
            image: "hip_circles",
            instructions: "Stand on one leg, make large circles with other leg. Switch directions and legs.",
            videoUrl: nil
        ),
        Exercise(
            name: "Shoulder Dislocations",
            muscleGroup: .mobility,
            equipment: .resistanceBand,
            image: "shoulder_dislocations",
            instructions: "Hold band wide, bring over head and behind back. Return forward. Keep arms straight.",
            videoUrl: nil
        ),
        
        // FULL BODY EXERCISES
        Exercise(
            name: "Kettlebell Swing",
            muscleGroup: .fullBody,
            equipment: .kettlebell,
            image: "kettlebell_swing",
            instructions: "Hinge at hips, swing kettlebell between legs. Drive hips forward, swing to shoulder height.",
            videoUrl: nil
        ),
        Exercise(
            name: "Thrusters",
            muscleGroup: .fullBody,
            equipment: .dumbbell,
            image: "thrusters",
            instructions: "Hold dumbbells at shoulders, squat down. Drive up and press dumbbells overhead.",
            videoUrl: nil
        ),
        Exercise(
            name: "Clean and Press",
            muscleGroup: .fullBody,
            equipment: .barbell,
            image: "clean_press",
            instructions: "Pull barbell to shoulders, then press overhead. Lower with control.",
            videoUrl: nil
        ),
        Exercise(
            name: "Turkish Get-Up",
            muscleGroup: .fullBody,
            equipment: .kettlebell,
            image: "turkish_getup",
            instructions: "Lie down holding kettlebell. Stand up while keeping weight overhead. Reverse to return.",
            videoUrl: nil
        )
    ]
    
    // MARK: - Sample Routines
//    let sampleRoutines: [Routine] = [
//        Routine(
//            name: "Upper Body Strength",
//            routineExercises: [
//                RoutineExercise(
//                    exercise: Exercise(name: "Bench Press", muscleGroup: .chest, equipment: .barbell),
//                    sets: [
//                        PlannedSet(setNumber: 1, reps: 8, weightKg: 60, restTimerSeconds: 120),
//                        PlannedSet(setNumber: 2, reps: 8, weightKg: 65, restTimerSeconds: 120),
//                        PlannedSet(setNumber: 3, reps: 6, weightKg: 70, restTimerSeconds: 120)
//                    ]
//                ),
//                RoutineExercise(
//                    exercise: Exercise(name: "Bent Over Barbell Row", muscleGroup: .back, equipment: .barbell),
//                    sets: [
//                        PlannedSet(setNumber: 1, reps: 10, weightKg: 50, restTimerSeconds: 90),
//                        PlannedSet(setNumber: 2, reps: 10, weightKg: 55, restTimerSeconds: 90),
//                        PlannedSet(setNumber: 3, reps: 8, weightKg: 60, restTimerSeconds: 90)
//                    ]
//                ),
//                RoutineExercise(
//                    exercise: Exercise(name: "Overhead Press", muscleGroup: .shoulders, equipment: .barbell),
//                    sets: [
//                        PlannedSet(setNumber: 1, reps: 10, weightKg: 40, restTimerSeconds: 90),
//                        PlannedSet(setNumber: 2, reps: 8, weightKg: 45, restTimerSeconds: 90)
//                    ]
//                )
//            ]
//        ),
//        
//        Routine(
//            name: "Lower Body Power",
//            routineExercises: [
//                RoutineExercise(
//                    exercise: Exercise(name: "Barbell Squat", muscleGroup: .legs, equipment: .barbell),
//                    sets: [
//                        PlannedSet(setNumber: 1, reps: 12, weightKg: 80, restTimerSeconds: 180),
//                        PlannedSet(setNumber: 2, reps: 10, weightKg: 90, restTimerSeconds: 180),
//                        PlannedSet(setNumber: 3, reps: 8, weightKg: 100, restTimerSeconds: 180)
//                    ]
//                ),
//                RoutineExercise(
//                    exercise: Exercise(name: "Dumbbell Romanian Deadlift", muscleGroup: .glutes, equipment: .dumbbell),
//                    sets: [
//                        PlannedSet(setNumber: 1, reps: 12, weightKg: 20, restTimerSeconds: 90),
//                        PlannedSet(setNumber: 2, reps: 12, weightKg: 25, restTimerSeconds: 90),
//                        PlannedSet(setNumber: 3, reps: 10, weightKg: 30, restTimerSeconds: 90)
//                    ]
//                ),
//                RoutineExercise(
//                    exercise: Exercise(name: "Leg Press", muscleGroup: .legs, equipment: .machine),
//                    sets: [
//                        PlannedSet(setNumber: 1, reps: 15, weightKg: 100, restTimerSeconds: 60),
//                        PlannedSet(setNumber: 2, reps: 15, weightKg: 120, restTimerSeconds: 60)
//                    ]
//                )
//            ]
//        ),
//        
//        Routine(
//            name: "HIIT Cardio Blast",
//            routineExercises: [
//                RoutineExercise(
//                    exercise: Exercise(name: "Jumping Jacks", muscleGroup: .cardio, equipment: .none),
//                    sets: [
//                        PlannedSet(setNumber: 1, weightKg: 0, restTimerSeconds: 30, timeInSecsForCardio: 60)
//                    ]
//                ),
//                RoutineExercise(
//                    exercise: Exercise(name: "Burpees", muscleGroup: .cardio, equipment: .none),
//                    sets: [
//                        PlannedSet(setNumber: 1, weightKg: 0, restTimerSeconds: 45, timeInSecsForCardio: 45)
//                    ]
//                ),
//                RoutineExercise(
//                    exercise: Exercise(name: "Mountain Climbers", muscleGroup: .cardio, equipment: .none),
//                    sets: [
//                        PlannedSet(setNumber: 1, weightKg: 0, restTimerSeconds: 30, timeInSecsForCardio: 60)
//                    ]
//                ),
//                RoutineExercise(
//                    exercise: Exercise(name: "High Knees", muscleGroup: .cardio, equipment: .none),
//                    sets: [
//                        PlannedSet(setNumber: 1, weightKg: 0, restTimerSeconds: 30, timeInSecsForCardio: 45)
//                    ]
//                )
//            ]
//        ),
//        
//        Routine(
//            name: "Full Body Beginner",
//            routineExercises: [
//                RoutineExercise(
//                    exercise: Exercise(name: "Goblet Squat", muscleGroup: .legs, equipment: .dumbbell),
//                    sets: [
//                        PlannedSet(setNumber: 1, reps: 12, weightKg: 12, restTimerSeconds: 60),
//                        PlannedSet(setNumber: 2, reps: 12, weightKg: 12, restTimerSeconds: 60)
//                    ]
//                ),
//                RoutineExercise(
//                    exercise: Exercise(name: "Push-ups", muscleGroup: .chest, equipment: .none),
//                    sets: [
//                        PlannedSet(setNumber: 1, reps: 10, weightKg: 0, restTimerSeconds: 60),
//                        PlannedSet(setNumber: 2, reps: 10, weightKg: 0, restTimerSeconds: 60)
//                    ]
//                ),
//                RoutineExercise(
//                    exercise: Exercise(name: "Dumbbell Row", muscleGroup: .back, equipment: .dumbbell),
//                    sets: [
//                        PlannedSet(setNumber: 1, reps: 10, weightKg: 15, restTimerSeconds: 60),
//                        PlannedSet(setNumber: 2, reps: 10, weightKg: 15, restTimerSeconds: 60)
//                    ]
//                ),
//                RoutineExercise(
//                    exercise: Exercise(name: "Plank", muscleGroup: .core, equipment: .none),
//                    sets: [
//                        PlannedSet(setNumber: 1, weightKg: 0, restTimerSeconds: 60, timeInSecsForCardio: 30),
//                        PlannedSet(setNumber: 2, weightKg: 0, restTimerSeconds: 60, timeInSecsForCardio: 30)
//                    ]
//                )
//            ]
//        )
//    ]
    
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
