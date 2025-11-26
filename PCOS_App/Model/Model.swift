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
}

struct Exercise: Identifiable, Codable {
    var id: UUID
    let name: String
    let muscleGroup: MuscleGroup
    let equipment: Equipment
    let image: String?
    let instructions: String?
    let videoUrl: String?
    
    init(id: UUID = UUID(),
             name: String,
             muscleGroup: MuscleGroup,
             equipment: Equipment,
             image: String? = nil,
             instructions: String? = nil,
             videoUrl: String? = nil) {
            self.id = id
            self.name = name
            self.muscleGroup = muscleGroup
            self.equipment = equipment
            self.image = image
            self.instructions = instructions
            self.videoUrl = videoUrl
        }
}


struct PlannedSet: Codable {
    var setNumber: Int
    var restTimerSeconds: Int?

    // For strength
    var weightKg: Int
    var reps: Int?
    
    // For cardio
    var timeInSecsForCardio: Int?
    
    init(setNumber:Int = 1, reps:Int = 10, weightKg:Int=0,restTimerSeconds: Int? = 0,timeInSecsForCardio: Int? = nil) {
        self.setNumber = setNumber
        self.restTimerSeconds = restTimerSeconds
        self.weightKg = weightKg
        self.reps = reps
        self.timeInSecsForCardio = timeInSecsForCardio
    }
    
    var estimatedDurationWithRest: Int {
        var activeTime = 0
        
        if let cardioTime = timeInSecsForCardio {
            activeTime = cardioTime
        } else if let reps = reps {
            activeTime = reps * 4
        }
        
        let restTime = restTimerSeconds ?? 0
        
        return activeTime + restTime
    }
    
    var formattedDuration: String {
        let minutes = estimatedDurationWithRest / 60
        let seconds = estimatedDurationWithRest % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }

}


//An exercise entry for routines - which will contain Exercise struct and an array of PlannedSet struct
struct RoutineExercise: Identifiable, Codable {
    var id: UUID
    let exercise: Exercise
    var sets: [PlannedSet]
    var notes: String?
    
    init(id: UUID = UUID(),
             exercise: Exercise,
             notes: String? = nil,
             sets: [PlannedSet] = [PlannedSet()],
             supersetWith: UUID? = nil) {
            self.id = id
            self.exercise = exercise
            self.notes = notes
            self.sets = sets
        }
        

    var totalSets: Int { sets.count }
    
    var estimatedDuration: Int {
        var total = 0
        for set in sets {
            total += set.estimatedDurationWithRest
        }
        return total
    }
    
    var formattedDuration: String {
            let minutes = estimatedDuration / 60
            let seconds = estimatedDuration % 60
            if minutes > 0 {
                return "\(minutes)m \(seconds)s"
            }
            return "\(seconds)s"
        }


}

struct Routine: Identifiable, Codable {
    var id: UUID
    var name: String
    var routineExercises: [RoutineExercise]
    var createdAt: Date
    
    init(id: UUID = UUID(),
             name: String,
             routineExercises: [RoutineExercise] = [],
             createdAt: Date = Date()) {
            self.id = id
            self.name = name
            self.routineExercises = routineExercises
            self.createdAt = createdAt
        }
    
    var totalExercises: Int { routineExercises.count }
    
    var totalSets: Int {
        var count = 0
        for exercise in routineExercises {
            count += exercise.sets.count
        }
        return count
    }
    var estimatedTotalDuration: Int {
        var total = 0
        for exercise in routineExercises {
            total += exercise.estimatedDuration
        }
        return total
    }
    
    var formattedDuration: String {
            let minutes = estimatedTotalDuration / 60
            if minutes > 60 {
                let hours = minutes / 60
                let remainingMinutes = minutes % 60
                return "\(hours)h \(remainingMinutes)m"
            }
            return "\(minutes)m"
        }

    
}



