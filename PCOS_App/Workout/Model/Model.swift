//
//  Model.swift
//  PCOS_App
//
//  Created by SDC-USER on 22/11/25.
//
import Foundation
enum Equipment: String, Codable, CaseIterable {
    case allEquipment,none,barbell,dumbbell,kettlebell,machine,resistanceBand,plate
    
    var displayName: String {
            switch self {
            case .allEquipment: return "All Equipment"
            case .none: return "No Equipment"
            case .barbell: return "Barbell"
            case .dumbbell: return "Dumbbell"
            case .kettlebell: return "Kettlebell"
            case .machine: return "Machine"
            case .resistanceBand: return "Resistance Band"
            case .plate: return "Plate"
            }
        }
    var displayImage: String {
            switch self {
            case .allEquipment: return "All Equipment"
            case .none: return "No Equipment"
            case .barbell: return "Barbell"
            case .dumbbell: return "Dumbbell"
            case .kettlebell: return "Kettlebell"
            case .machine: return "Machine"
            case .resistanceBand: return "Resistance Band"
            case .plate: return "Plate"
            }
        }
}
enum MuscleGroup: String, Codable, CaseIterable {
    case allMuscles,core, chest, back, legs, shoulders, arms, glutes, cardio, mobility, fullBody
    
    var displayName: String {
            switch self {
            case .allMuscles: return "All Muscles"
            case .core: return "Core"
            case .chest: return "Chest"
            case .back: return "Back"
            case .legs: return "Legs"
            case .shoulders: return "Shoulders"
            case .arms: return "Arms"
            case .glutes: return "Glutes"
            case .cardio: return "Cardio"
            case .mobility: return "Mobility"
            case .fullBody: return "Full Body"
            }
        }
    
    var displayImage: String {
            switch self {
            case .allMuscles: return "All Muscles"
            case .core: return "Core"
            case .chest: return "Chest"
            case .back: return "Back"
            case .legs: return "Legs"
            case .shoulders: return "Shoulders"
            case .arms: return "Arms"
            case .glutes: return "Glutes"
            case .cardio: return "Cardio"
            case .mobility: return "Mobility"
            case .fullBody: return "Full Body"
            }
        }
    // Helper property to check if exercise type is cardio
        var isCardio: Bool {
            return self == .cardio
        }
}
struct Exercise: Identifiable, Codable {
    var id: UUID
    let name: String
    let muscleGroup: MuscleGroup          // this IS your primary muscle
    let equipment: Equipment
    let image: String?
    let instructions: String?
    
    let gifUrl: String?                   // remote GIF (or local path if you want)
    
    let level: String                     // Beginner, Intermediate, Advanced
    let tempo: String                     // e.g. "2–3s up/down"
    let form: [String]                    // bullet points
    let variations: [String]              // list of variations
    let commonMistakes: [String]          // list of mistakes
    
    init(
        id: UUID = UUID(),
        name: String,
        muscleGroup: MuscleGroup,
        equipment: Equipment,
        image: String? = nil,
        instructions: String? = nil,
        gifUrl: String? = nil,
        level: String,
        tempo: String,
        form: [String],
        variations: [String],
        commonMistakes: [String]
    ) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.equipment = equipment
        self.image = image
        self.instructions = instructions
        self.gifUrl = gifUrl
        self.level = level
        self.tempo = tempo
        self.form = form
        self.variations = variations
        self.commonMistakes = commonMistakes
    }
    
    var isCardio: Bool {
        muscleGroup.isCardio
    }
}

struct RoutineExercise: Codable, Identifiable {
    var id: UUID
    var exercise: Exercise
    var numberOfSets: Int
    var reps: Int
    var weightKg :  Int
    var restTimerSeconds: Int?
    // For cardio exercises
    var durationSeconds: Int?
    var notes: String?
    init(id: UUID = UUID(),
             exercise: Exercise,
             numberOfSets: Int? = nil,
             reps: Int? = nil,
             weightKg: Int = 0,
             restTimerSeconds: Int? = nil,
             durationSeconds: Int? = nil,
             notes: String? = nil) {
            
            self.id = id
            self.exercise = exercise
            self.weightKg = weightKg
            self.notes = notes
            
            // Set smart defaults based on exercise type
            if exercise.isCardio {
                self.numberOfSets = 1
                self.reps = 0
                self.restTimerSeconds = nil
                self.durationSeconds = durationSeconds ?? 600  // 10 minutes default
            } else {
                self.numberOfSets = numberOfSets ?? 3
                self.reps = reps ?? 10
                self.restTimerSeconds = restTimerSeconds ?? 60  // 60 seconds rest
                self.durationSeconds = nil
            }
        }
        
    func generateWorkoutExercise() -> WorkoutExercise {
        if exercise.isCardio {
                   // For cardio, create a single set with duration
                   let cardioSet = ExerciseSet(
                       setNumber: 1,
                       reps: 0,
                       weightKg: 0,
                       restTimerSeconds: nil,
                       durationSeconds: durationSeconds,
                       isCompleted: false
                   )
                   
                   return WorkoutExercise(
                       id: id,
                       exercise: exercise,
                       sets: [cardioSet],
                       notes: notes
                   )
               } else {
                   // For strength exercises
                   let sets = (1...numberOfSets).map {
                       ExerciseSet(
                           setNumber: $0,
                           reps: reps,
                           weightKg: weightKg,
                           restTimerSeconds: restTimerSeconds,
                           durationSeconds: nil,
                           isCompleted: false
                       )
                   }
                   
                   return WorkoutExercise(
                       id: id,
                       exercise: exercise,
                       sets: sets,
                       notes: notes
                   )
               }
           }
    
}


struct ExerciseSet: Codable, Identifiable {
    var id = UUID()
    var setNumber: Int
    var reps: Int
    var weightKg: Int
    var restTimerSeconds: Int?
    var durationSeconds: Int? // For cardio exercises
    var isCompleted: Bool = false
}
struct WorkoutExercise: Codable, Identifiable {
    var id: UUID
    var exercise: Exercise
    var sets: [ExerciseSet]
    var notes: String?
}
struct Routine: Identifiable, Codable {
    var id: UUID
    var name: String
    var exercises: [RoutineExercise]
    var createdAt: Date = Date()
    var thumbnailImageName: String?//new added property 
    var routineDescription: String?
    var totalExercises: Int { exercises.count }
    
    var totalSets: Int {
        exercises.reduce(0) { total, ex in
            // Cardio exercises count as 1 set
            return total + (ex.exercise.isCardio ? 1 : ex.numberOfSets)
        }
    }
    
    var estimatedDurationSeconds: Int {
        exercises.reduce(0) { total, ex in
            if ex.exercise.isCardio {
                // For cardio, use the user-specified duration
                return total + (ex.durationSeconds ?? 0)
            } else {
                // For strength exercises, estimate based on reps and rest
                let activePerSet = ex.reps * 4 // simple estimate
                let rest = ex.restTimerSeconds ?? 0
                return total + (activePerSet + rest) * ex.numberOfSets
            }
        }
    }
    
    var formattedDuration: String {
        let minutes = estimatedDurationSeconds / 60
        if minutes > 60 {
            return "\(minutes/60)h \(minutes%60)m"
        }
        return "\(minutes)m"
    }
}


//new
struct ActiveWorkout {
    var id = UUID()
    var routine: Routine                    // template used
    var exercises: [WorkoutExercise]        // live trackable exercises

    var startTime: Date = Date()
    var endTime: Date?
    var durationSeconds: Int = 0            // will be filled on finish

    mutating func finish() {
        endTime = Date()
        durationSeconds = Int(endTime!.timeIntervalSince(startTime))
        
    }
}
struct CompletedWorkout {
    var id = UUID()
    var routineName: String
    var date: Date
    var durationSeconds: Int
    var exercises: [WorkoutExercise]
}
class WorkoutSessionManager {
    static let shared = WorkoutSessionManager()
    private init() {}
    
    /// Array of saved routine templates
    var savedRoutines: [Routine] = []
    
    /// Active workout session
    var activeWorkout: ActiveWorkout?
    
    /// Past completed workouts
    var completedWorkouts: [CompletedWorkout] = []
    
    // Helper method to add a routine
    func addRoutine(_ routine: Routine) {
        savedRoutines.append(routine)
        print("✅ Routine saved: \(routine.name)")
        print("📊 Total routines: \(savedRoutines.count)")
    }
    
    // Helper method to get a specific routine
    func getRoutine(at index: Int) -> Routine? {
        guard index >= 0 && index < savedRoutines.count else { return nil }
        return savedRoutines[index]
    }
    
    // Helper method to delete a routine
    func deleteRoutine(at index: Int) {
        guard index >= 0 && index < savedRoutines.count else { return }
        savedRoutines.remove(at: index)
    }
}



