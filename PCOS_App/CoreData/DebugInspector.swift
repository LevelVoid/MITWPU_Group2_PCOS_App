//
//  DebugInspector.swift
//  PCOS_App
//
//  Created by Namrata Sadguru on 08/03/26.
//


//
//  DebugInspector.swift
//  PCOS_App
//
//  Temporary debug tool — DELETE before shipping
//

import Foundation
import CoreData
import UIKit

#if DEBUG
struct DebugInspector {
    
    static func printAll() {
        print("\n")
        print("╔══════════════════════════════════════════════════════════════╗")
        print("║              🔍 DEBUG INSPECTOR                             ║")
        print("╠══════════════════════════════════════════════════════════════╣")
        
        printCoreData()
        printUserDefaults()
        
        print("╚══════════════════════════════════════════════════════════════╝")
        print("\n")
    }
    
    // MARK: - Core Data Dump
    
    private static func printCoreData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).viewContext
        
        print("║                                                              ║")
        print("║  📦 CORE DATA                                                ║")
        print("║  ─────────────────────────────────────────────────────────── ║")
        
        // CDUser
        let userRequest: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        if let users = try? context.fetch(userRequest) {
            print("║                                                              ║")
            print("║  👤 CDUser (\(users.count) records)                           ║")
            for user in users {
                print("║    id:            \(user.id?.uuidString ?? "nil")")
                print("║    name:          \(user.name ?? "nil")")
                print("║    dateOfBirth:   \(user.dateOfBirth?.description ?? "nil")")
                print("║    heightCm:      \(user.heightCm)")
                print("║    weightKg:      \(user.weightKg)")
                print("║    BMI:           \(String(format: "%.1f", user.calculatedBMI)) (\(user.bmiCategory))")
                print("║    dietPattern:   \(user.dietPattern ?? "nil")")
                print("║    activityLevel: \(user.activityLevel ?? "nil")")
                print("║    pcosPhenotype:  \(user.pcosPhenotype ?? "nil")")
                print("║    createdAt:     \(user.createdAt?.description ?? "nil")")
            }
            if users.isEmpty {
                print("║    (empty)")
            }
        }
        
        // CDCycleData
        let cycleRequest: NSFetchRequest<CDCycleData> = CDCycleData.fetchRequest()
        cycleRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        if let cycles = try? context.fetch(cycleRequest) {
            print("║                                                              ║")
            print("║  🔴 CDCycleData (\(cycles.count) records)                    ║")
            for (i, cycle) in cycles.enumerated() {
                let status = cycle.isComplete ? "✅ Complete" : "🔄 Ongoing"
                let formatter = DateFormatter()
                formatter.dateFormat = "dd MMM yyyy"
                let start = cycle.startDate != nil ? formatter.string(from: cycle.startDate!) : "nil"
                let end = cycle.endDate != nil ? formatter.string(from: cycle.endDate!) : "nil (ongoing)"
                print("║    [\(i)] \(start) → \(end)  |  period: \(cycle.periodLength)d  cycle: \(cycle.cycleLength)d  \(status)")
            }
            if cycles.isEmpty {
                print("║    (empty)")
            }
        }
        
        // CDSymptomLog
        let symptomRequest: NSFetchRequest<CDSymptomLog> = CDSymptomLog.fetchRequest()
        symptomRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        symptomRequest.fetchLimit = 20
        if let symptoms = try? context.fetch(symptomRequest) {
            print("║                                                              ║")
            print("║  🩺 CDSymptomLog (\(symptoms.count) shown, limit 20)         ║")
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM"
            for s in symptoms {
                let d = s.date != nil ? formatter.string(from: s.date!) : "nil"
                print("║    [\(d)] \(s.symptomName ?? "?") (\(s.symptomCategory ?? "?"))")
            }
            if symptoms.isEmpty {
                print("║    (empty)")
            }
        }
        
        // CDDailyContext with relationships
        let contextRequest2: NSFetchRequest<CDDailyContext> = CDDailyContext.fetchRequest()
        contextRequest2.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        contextRequest2.fetchLimit = 3
        if let dailyContexts = try? context.fetch(contextRequest2) {
            print("║                                                              ║")
            print("║  🔗 CDDailyContext Relationships (\(dailyContexts.count) shown) ║")
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            for c in dailyContexts {
                let d = c.date != nil ? formatter.string(from: c.date!) : "nil"
                let foodCount = (c.foodLogs as? Set<CDFoodLog>)?.count ?? 0
                let symptomCount = (c.symptomLogs as? Set<CDSymptomLog>)?.count ?? 0
                let workoutCount = (c.completedWorkouts as? Set<CDCompletedWorkout>)?.count ?? 0
                print("║    [\(d)] 🍽️\(foodCount) foods | 🩺\(symptomCount) symptoms | 🏋️\(workoutCount) workouts")
                let sleepStr: String
                if c.sleepTime != nil && c.wakeTime != nil {
                    let hrs = c.wakeTime!.timeIntervalSince(c.sleepTime!) / 3600.0
                    sleepStr = String(format: "💤 %.1fh (q:%.0f%%)", hrs, c.sleepQuality * 100)
                } else {
                    sleepStr = "💤 not logged"
                }
                print("║    [\(d)] \(sleepStr) | 🍽️\(foodCount) foods | 🩺\(symptomCount) symptoms | 🏋️\(workoutCount) workouts")

            }
        }


        // CDCompletedWorkout
        let workoutRequest: NSFetchRequest<CDCompletedWorkout> = CDCompletedWorkout.fetchRequest()
        workoutRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        workoutRequest.fetchLimit = 3
        if let workouts = try? context.fetch(workoutRequest) {
            print("║                                                              ║")
            print("║  🏋️ CDCompletedWorkout (\(workouts.count) shown, limit 3)    ║")
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            for w in workouts {
                let d = w.date != nil ? formatter.string(from: w.date!) : "nil"
                let name = w.routineName ?? "Unknown"
                let exCount = w.exercises.count
                print("║    [\(d)] \(name) | \(Int(w.durationSeconds/60))m | \(exCount) exercises")
                // CDWorkoutExercise relationship check
                if let wExercises = (w.workoutExercises as? Set<CDWorkoutExercise>)?.sorted(by: { $0.sortOrder < $1.sortOrder }) {
                    for (j, ex) in wExercises.enumerated() {
                        let setsCount = ex.sets.count
                        let completedSets = ex.sets.filter { $0.completionState == .completed }.count
                        print("║         [\(j)] \(ex.exerciseName ?? "?") — \(completedSets)/\(setsCount) sets ✅")
                    }
                    if wExercises.isEmpty {
                        print("║         (no CDWorkoutExercise rows)")
                    }
                }

            }
            if workouts.isEmpty {
                print("║    (empty)")
            }
        }
        
        
        // CDFoodLog
        let foodRequest: NSFetchRequest<CDFoodLog> = CDFoodLog.fetchRequest()
        foodRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
        foodRequest.fetchLimit = 10
        if let foods = try? context.fetch(foodRequest) {
            print("║                                                              ║")
            print("║  🍽️ CDFoodLog (\(foods.count) shown, limit 10)                ║")
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM HH:mm"
            for f in foods {
                let d = f.timeStamp != nil ? formatter.string(from: f.timeStamp!) : "nil"
                let name = f.name ?? "?"
                let p = Int(f.proteinContent)
                let c = Int(f.carbsContent)
                let fat = Int(f.fatsContent)
                print("║    [\(d)] \(name) | P:\(p) C:\(c) F:\(fat)")
            }
            if foods.isEmpty {
                print("║    (empty)")
            }
        }
        
        // CDRoutine
        let routineRequest: NSFetchRequest<CDRoutine> = CDRoutine.fetchRequest()
        routineRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        if let routines = try? context.fetch(routineRequest) {
            print("║                                                              ║")
            print("║  📋 CDRoutine (\(routines.count) records)                      ║")
            for (i, r) in routines.enumerated() {
                let name = r.name ?? "?"
                let exCount = (r.exercises as? Set<CDRoutineExercise>)?.count ?? 0
                let phase = r.phase ?? "none"
                let type = r.routineType ?? "none"
                let formatter = DateFormatter()
                formatter.dateFormat = "dd MMM yyyy"
                let created = r.createdAt != nil ? formatter.string(from: r.createdAt!) : "nil"
                let lastUsed = r.lastUsedAt != nil ? formatter.string(from: r.lastUsedAt!) : "never"
                print("║    [\(i)] \"\(name)\" | \(exCount) exercises | phase: \(phase) | type: \(type)")
                print("║         created: \(created) | lastUsed: \(lastUsed)")
                
                // Print each exercise in this routine
                if let exercises = (r.exercises as? Set<CDRoutineExercise>)?.sorted(by: { $0.sortOrder < $1.sortOrder }) {
                    for (j, ex) in exercises.enumerated() {
                        let exName = ex.exerciseName ?? "?"
                        if ex.durationSecs > 0 {
                            print("║           [\(j)] \(exName) — \(ex.durationSecs)s (cardio)")
                        } else {
                            print("║           [\(j)] \(exName) — \(ex.targetSets)×\(ex.targetReps) @ \(ex.targetWeight)kg rest:\(ex.restSecs)s")
                        }
                        // Verify exerciseData decodes properly
                        if let decoded = ex.exercise {
                            print("║               ✅ exerciseData decoded: \(decoded.name) (\(decoded.muscleGroup.displayName))")
                        } else {
                            print("║               ❌ exerciseData FAILED to decode!")
                        }
                    }
                }
            }
            if routines.isEmpty {
                print("║    (empty — no user-created routines yet)")
            }
        }

        // CDFoodTag summary per food
        let tagRequest: NSFetchRequest<CDFoodTag> = CDFoodTag.fetchRequest()
        if let allTags = try? context.fetch(tagRequest) {
            let computed = allTags.filter { $0.isComputed }.count
            let staticT = allTags.filter { !$0.isComputed }.count
            print("║                                                              ║")
            print("║  🏷️ CDFoodTag (\(allTags.count) total)                        ║")
            print("║    Static: \(staticT) | Computed: \(computed)")
            
            // Show unique computed tags
            let uniqueComputed = Set(allTags.filter { $0.isComputed }.compactMap { $0.tagName })
            if !uniqueComputed.isEmpty {
                print("║    Computed tags in use: \(uniqueComputed.sorted().joined(separator: ", "))")
            }
        }
        


        
        print("║  ─────────────────────────────────────────────────────────── ║")
    }
    
    // MARK: - UserDefaults Dump
    
    private static func printUserDefaults() {
        let defaults = UserDefaults.standard
        
        print("║                                                              ║")
        print("║  📋 USERDEFAULTS                                             ║")
        print("║  ─────────────────────────────────────────────────────────── ║")
        
        // Known keys we care about
        let keysToCheck: [String] = [
            // Legacy profile (should be gone after migration)
            "savedUserProfile",
            // Onboarding
            "hasCompletedOnboarding",
            "userName", "userDOB", "userHeight", "userWeight",
            "heightIsMetric", "weightIsMetric",
            "userDietType", "userWorkoutType", "userGoalType",
            // Cycle data (should be gone after migration)
            "SavedPeriodDates", "SavedCycles",
            "CycleDataStore_v2_migrated",
            // Symptoms
            "todaysSymptoms",
            // Workout
            "dailyActivities", "completed_workouts_v1",
        ]
        
        for key in keysToCheck {
            let value = defaults.object(forKey: key)
            if let value = value {
                let display: String
                if let data = value as? Data {
                    display = "Data(\(data.count) bytes)"
                } else if let array = value as? [Any] {
                    display = "Array(\(array.count) items)"
                } else {
                    display = "\(value)"
                }
                print("║    ✅ \(key) = \(display)")
            } else {
                print("║    ⬜ \(key) = (not set)")
            }
        }
        
        // Also print any symptom keys (symptoms_YYYY-MM-DD)
        let allKeys = defaults.dictionaryRepresentation().keys
        let symptomKeys = allKeys.filter { $0.hasPrefix("symptoms_") }.sorted()
        if !symptomKeys.isEmpty {
            print("║                                                              ║")
            print("║    🩺 Symptom date keys (\(symptomKeys.count)):")
            for key in symptomKeys.prefix(10) {
                if let data = defaults.data(forKey: key) {
                    print("║       \(key) = Data(\(data.count) bytes)")
                }
            }
            if symptomKeys.count > 10 {
                print("║       ... and \(symptomKeys.count - 10) more")
            }
        }
        
        print("║  ─────────────────────────────────────────────────────────── ║")
    }
}
#endif
