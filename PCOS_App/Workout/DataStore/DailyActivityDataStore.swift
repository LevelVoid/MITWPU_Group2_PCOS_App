//
//  DailyActivityDataStore.swift
//  PCOS_App
//
//  Migrated from UserDefaults to Core Data CDDailyContext
//

import Foundation
import CoreData
import UIKit

class DailyActivityDataStore {
    static let shared = DailyActivityDataStore()
    
    private static var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.viewContext
    }
    
    private init() {
        if loadAll().isEmpty {
            DailyActivityDataStore.migrateLegacyDataIfNeeded()
            // If still empty after migration (e.g., fresh install), populate demo data
            if loadAll().isEmpty {
//                populateSampleData()
            }
        }
    }
    
    // MARK: - API
    
    /// Returns all days, sorted newest first, mapped to structs for the UI Charts
    func loadAll() -> [DailyActivity] {
        let request: NSFetchRequest<CDDailyContext> = CDDailyContext.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let results = try Self.context.fetch(request)
            return results.map { $0.toDailyActivity() }
        } catch {
            print("❌ Failed to fetch CDDailyContext: \(error)")
            return []
        }
    }
    
    /// Internal helper: Manually enforces 1 record per day (CloudKit safe)
    func getOrCreateContext(for date: Date) -> CDDailyContext {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        let request: NSFetchRequest<CDDailyContext> = CDDailyContext.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", startOfDay as NSDate)
        request.fetchLimit = 1
        
        let ctx = Self.context
        let dailyCtx: CDDailyContext
        
        if let existing = try? ctx.fetch(request).first {
            dailyCtx = existing
        } else {
            dailyCtx = CDDailyContext(context: ctx)
            dailyCtx.id = UUID()
            dailyCtx.date = startOfDay
        }
        
        // ── Populate cycle phase (runs every time to stay in sync) ──
        populateCycleInfo(for: dailyCtx, date: startOfDay)
        
        return dailyCtx
    }
    
    private func populateCycleInfo(for dailyCtx: CDDailyContext, date: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        
        // Find the cycle that contains this date
        let cycles = CycleDataStore.shared.cycles
        guard let cycle = cycles.first(where: { cycle in
            let cycleStart = calendar.startOfDay(for: cycle.startDate)
            let cycleEnd: Date
            if let end = cycle.endDate {
                cycleEnd = calendar.startOfDay(for: end)
            } else {
                // Ongoing cycle — extend to today + buffer
                cycleEnd = calendar.date(byAdding: .day, value: cycle.cycleLength, to: cycleStart) ?? today
            }
            return today >= cycleStart && today <= cycleEnd
        }) else {
            return  // No cycle covers this date
        }
        
        let cycleStart = calendar.startOfDay(for: cycle.startDate)
        let daysDiff = calendar.dateComponents([.day], from: cycleStart, to: today).day ?? 0
        let cycleDay = daysDiff + 1
        
        let phase = CycleDataStore.shared.phaseForDay(
            day: cycleDay,
            cycleLength: cycle.cycleLength,
            periodLength: cycle.periodLength,
            isOvulationConfirmed: cycle.isOvulationConfirmed
        )
        
        dailyCtx.cycleDay = Int16(cycleDay)
        dailyCtx.cyclePhase = phase.displayName
    }


    
    // MARK: - Updates
    
    /// Recalculates today's workout totals from all completed workouts and writes them
    /// to CDDailyContext. Safe to call multiple times — uses assignment (=) not accumulation (+=).
    func syncAllWorkouts(for date: Date = Date()) {
        let calendar = Calendar.current
        let todayWorkouts = CompletedWorkoutsDataStore.shared.loadAll()
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
        
        let totalDuration = todayWorkouts.reduce(0) { $0 + $1.durationSeconds }
        // Only use real calorie data (from Apple Watch via SummaryViewController).
        // No time-based fallback — if caloriesBurned == 0, store 0.
        let totalCals = todayWorkouts.reduce(0.0) { $0 + $1.caloriesBurned }
        
        let ctx = getOrCreateContext(for: date)
        ctx.activeDurationSeconds = Int32(totalDuration)
        ctx.caloriesBurned = Int32(totalCals)
        
        saveContext()
    }
    
    func mergeHealthKitData(date: Date = Date(), steps: Int, healthKitDailyCalories: Int) {
        let ctx = getOrCreateContext(for: date)
        
        if steps > 0 { ctx.steps = Int32(steps) }
        if healthKitDailyCalories > 0 { ctx.healthKitCalories = Int32(healthKitDailyCalories) }
        
        saveContext()
    }
    
    private func saveContext() {
        let ctx = Self.context
        if ctx.hasChanges {
            do {
                try ctx.save()
            } catch {
                print("❌ CDDailyContext save error: \(error)")
            }
        }
    }
    
    // MARK: - Dummy Data & Migration
    
    private func populateSampleData() {
        let calendar = Calendar.current
        let today = Date()
        
        for dayOffset in 0..<60 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let variance = Double.random(in: 0.7...1.3)
            
            let steps = Int32(Double.random(in: 3000...10000) * variance)
            let calories = Int32(Double.random(in: 150...450) * variance)
            let duration = Int32(Double.random(in: 1800...5400) * variance)
            
            let ctx = CDDailyContext(context: Self.context)
            ctx.id = UUID()
            ctx.date = calendar.startOfDay(for: date)
            ctx.steps = steps
            ctx.caloriesBurned = calories
            ctx.activeDurationSeconds = duration
        }
        
        saveContext()
        print("✅ Populated 60 days of sample CDDailyContext data")
    }
    
    private static func migrateLegacyDataIfNeeded() {
        let key = "dailyActivities"
        guard let data = UserDefaults.standard.data(forKey: key),
              let legacyActivities = try? JSONDecoder().decode([DailyActivity].self, from: data) else {
            return
        }
        
        print("🔄 Migrating DailyActivity from UserDefaults → Core Data...")
        
        for activity in legacyActivities {
            let ctx = CDDailyContext(context: context)
            ctx.id = UUID()
            ctx.date = Calendar.current.startOfDay(for: activity.date)
            ctx.steps = Int32(activity.steps)
            ctx.caloriesBurned = Int32(activity.caloriesBurned)
            ctx.healthKitCalories = Int32(activity.healthKitCalories)
            ctx.activeDurationSeconds = Int32(activity.activeDurationSeconds)
        }
        
        if context.hasChanges {
            try? context.save()
        }
        
        UserDefaults.standard.removeObject(forKey: key)
        print("✅ Migrated \(legacyActivities.count) daily records to Core Data")
    }
    
    func clearAll() {
        // Utility for testing if needed
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDDailyContext.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try Self.context.execute(deleteRequest)
            Self.context.reset()
        } catch {
            print("❌ Failed to clear all CDDailyContext: \(error)")
        }
    }
}
