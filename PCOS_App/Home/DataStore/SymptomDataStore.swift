//
//  SymptomDataStore.swift
//  PCOS_App
//
//  Migrated from UserDefaults to Core Data
//

import Foundation
import CoreData
import UIKit

class SymptomDataStore {
    
    static let shared = SymptomDataStore()
    
    private static var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.viewContext
    }
    
    private init() {
        SymptomDataStore.migrateLegacyDataIfNeeded()
    }
    
    // MARK: - Load Symptoms for a Date
    
    static func loadSymptoms(for date: Date) -> [SymptomItem] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        
        let request: NSFetchRequest<CDSymptomLog> = CDSymptomLog.fetchRequest()
        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        request.sortDescriptors = [NSSortDescriptor(key: "symptomName", ascending: true)]
        
        do {
            let results = try context.fetch(request)
            return results.map { $0.toSymptomItem() }
        } catch {
            print("❌ Failed to fetch CDSymptomLog: \(error)")
            return []
        }
    }
    
    // MARK: - Save Symptoms for a Date
    
    static func saveSymptoms(_ symptoms: [SymptomItem], for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        // 1. Delete existing symptoms for this date
        let fetchExisting: NSFetchRequest<CDSymptomLog> = CDSymptomLog.fetchRequest()
        fetchExisting.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        do {
            let existing = try context.fetch(fetchExisting)
            for obj in existing {
                context.delete(obj)
            }
        } catch {
            print("❌ Failed to delete old symptoms: \(error)")
        }

        
        // 2. Insert new symptoms
        let dailyContext = DailyActivityDataStore.shared.getOrCreateContext(for: startOfDay)
                for symptom in symptoms {
                    let log = CDSymptomLog(context: context)
                    log.id = UUID()
                    log.date = symptom.date ?? startOfDay
                    log.symptomName = symptom.name
                    log.symptomCategory = symptom.category
                    log.iconName = symptom.icon
                    log.dailyContext = dailyContext
                }
        
        // 3. Save
        if context.hasChanges {
            do {
                try context.save()
                print("✅ \(symptoms.count) symptoms saved for \(startOfDay)")
            } catch {
                print("❌ Core Data save error: \(error)")
            }
        }
    }
    
    // MARK: - Load Unique Symptoms (Last N Days)
    
    static func loadAllSymptomsLastNDays(_ days: Int = 30) -> [SymptomItem] {
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) else {
            return []
        }
        
        let request: NSFetchRequest<CDSymptomLog> = CDSymptomLog.fetchRequest()
        request.predicate = NSPredicate(
            format: "date >= %@",
            calendar.startOfDay(for: startDate) as NSDate
        )
        
        do {
            let results = try context.fetch(request)
            let unique = Dictionary(grouping: results, by: { $0.symptomName ?? "" })
                .compactMap { $0.value.first?.toSymptomItem() }
            return unique
        } catch {
            print("❌ Failed to fetch symptoms: \(error)")
            return []
        }
    }
    
    static func loadAllSymptomsBefore(date: Date, limitDays: Int = 365) -> [SymptomItem] {
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .day, value: -limitDays, to: Date()) else {
            return []
        }
        
        let request: NSFetchRequest<CDSymptomLog> = CDSymptomLog.fetchRequest()
        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            calendar.startOfDay(for: startDate) as NSDate,
            calendar.startOfDay(for: date) as NSDate
        )
        
        do {
            let results = try context.fetch(request)
            let unique = Dictionary(grouping: results, by: { $0.symptomName ?? "" })
                .compactMap { $0.value.first?.toSymptomItem() }
            return unique
        } catch {
            print("❌ Failed to fetch historical symptoms: \(error)")
            return []
        }
    }
    
    // MARK: - One-Time Migration
    
    private static func migrateLegacyDataIfNeeded() {
        let migrationKey = "CDSymptomLog_migrated"
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }
        
        print("🔄 Migrating symptoms from UserDefaults → Core Data...")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        var totalMigrated = 0
        
        // Scan last 90 days for symptom keys
        for offset in 0..<90 {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            let dateKey = "symptoms_\(formatter.string(from: date))"
            
            guard let savedData = UserDefaults.standard.data(forKey: dateKey),
                  let decoded = try? JSONDecoder().decode([SymptomItem].self, from: savedData) else {
                continue
            }
            
            for symptom in decoded {
                let log = CDSymptomLog(context: context)
                log.id = UUID()
                log.date = symptom.date ?? date
                log.symptomName = symptom.name
                log.symptomCategory = symptom.category
                log.iconName = symptom.icon
                totalMigrated += 1
            }
            
            // Remove old key
            UserDefaults.standard.removeObject(forKey: dateKey)
        }
        
        // Clean up todaysSymptoms key too
        UserDefaults.standard.removeObject(forKey: "todaysSymptoms")
        
        if context.hasChanges {
            try? context.save()
        }
        
        UserDefaults.standard.set(true, forKey: migrationKey)
        print("✅ Migrated \(totalMigrated) symptom records to Core Data")
    }
}
