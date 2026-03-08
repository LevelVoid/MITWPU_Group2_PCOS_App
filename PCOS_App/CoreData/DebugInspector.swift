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
                print("║    primaryFocus:  \(user.primaryFocus ?? "nil")")
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
