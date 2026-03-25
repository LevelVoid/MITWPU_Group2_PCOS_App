//
//  FoodLogDataStore.swift
//  PCOS_App
//
//  Migrated to Core Data
//

import Foundation
import CoreData
import UIKit

struct FoodLogDataStore {
    
    static var shared = FoodLogDataStore()
    
    private static var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.viewContext
    }
    
    static var ingredient = Ingredient(id: UUID(), name: "Default Ingredient", quantity: 0, protein: 0, carbs: 0, fats: 0, fibre: 0, tags: [.none])
    
    // MARK: - Queries
    
    /// All foods, sorted newest first
    static var sampleFoods: [Food] {
        let request: NSFetchRequest<CDFoodLog> = CDFoodLog.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
        return (try? context.fetch(request))?.map { $0.toFood() } ?? []
    }
    
    /// Today's foods only
    static var todaysMeal: [Food] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }
        
        let request: NSFetchRequest<CDFoodLog> = CDFoodLog.fetchRequest()
        request.predicate = NSPredicate(format: "timeStamp >= %@ AND timeStamp < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
        return (try? context.fetch(request))?.map { $0.toFood() } ?? []
    }
    
    static func filteredFoods() -> [Food] {
        return todaysMeal
    }
    
    // MARK: - Add
    static func addFoodBarCode(_ food: Food) {
        let cdFood = CDFoodLog.from(food, context: context)
        
        // Link to CDDailyContext
        let dailyContext = DailyActivityDataStore.shared.getOrCreateContext(for: food.timeStamp)
        cdFood.dailyContext = dailyContext
        
        // Compute and save impact tags
        CDFoodTag.saveTags(for: cdFood, staticTags: food.tags, context: context)
        
        // ── Upsert CDCustomFood ──
        upsertCustomFood(from: food)
        
        saveContext()
        print("CDFoodLog saved: \(food.name) with \((cdFood.foodTags as? Set<CDFoodTag>)?.count ?? 0) tags")
    }
    
    /// Upserts a CDCustomFood: if a food with the same name exists, increments timesUsed.
    /// Otherwise creates a new CDCustomFood entry.
    private static func upsertCustomFood(from food: Food) {
        let request: NSFetchRequest<CDCustomFood> = CDCustomFood.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[cd] %@", food.name)
        request.fetchLimit = 1
        
        if let existing = try? context.fetch(request).first {
            // Already exists — just bump the usage count
            existing.timesUsed += 1
        } else {
            // New food — create CDCustomFood entry
            let isAI = food.image == "dietPlaceholder" || food.image == nil
            CDCustomFood.from(food, isAI: isAI, context: context)
        }
    }


    // MARK: - Remove
    
    static func removeFood(_ food: Food) {
        let request: NSFetchRequest<CDFoodLog> = CDFoodLog.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", food.id as CVarArg)
        request.fetchLimit = 1
        
        if let result = try? context.fetch(request).first {
            context.delete(result)
            saveContext()
            print("CDFoodLog deleted: \(food.name)")
        }
    }
    
    // MARK: - Update
    
    static func updateFood(_ food: Food) {
        let request: NSFetchRequest<CDFoodLog> = CDFoodLog.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", food.id as CVarArg)
        request.fetchLimit = 1
        
        guard let existing = try? context.fetch(request).first else {
            print("CDFoodLog not found for update: \(food.name)")
            return
        }
        
        // Update all fields
        existing.name = food.name
        existing.servingSize = food.servingSize
        existing.weight = food.weight ?? 0
        existing.proteinContent = food.proteinContent
        existing.carbsContent = food.carbsContent
        existing.fatsContent = food.fatsContent
        existing.customCalories = food.customCalories ?? 0
        existing.ingredients = food.ingredients
        existing.tags = food.tags
        
        // Update image
        if let img = food.image {
            if img.hasPrefix("http") {
                existing.imageURL = img
                existing.localImage = nil
            } else {
                existing.localImage = img
                existing.imageURL = nil
            }
        }
        
        saveContext()
        print("CDFoodLog updated: \(food.name)")
    }

    
    // MARK: - Dates with meals (for calendar)
    
    static func allMealDates() -> Set<Date> {
        let request: NSFetchRequest<CDFoodLog> = CDFoodLog.fetchRequest()
        let results = (try? context.fetch(request)) ?? []
        let calendar = Calendar.current
        return Set(results.map { calendar.startOfDay(for: $0.timeStamp ?? Date()) })
    }
    
    // MARK: - Save
    
    private static func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("CDFoodLog save error: \(error)")
            }
        }
    }
    
    // MARK: - Seed Sample Data
    
    static func seedSampleDataIfNeeded() {
        let request: NSFetchRequest<CDFoodLog> = CDFoodLog.fetchRequest()
        let count = (try? context.count(for: request)) ?? 0
        if count > 0 { return } // Already have data
        
        let sampleData: [(String, String?, Date, Double, Double, Double, Double, Double?, [ImpactTags], [Ingredient]?)] = [
            ("Greek Yogurt with Berries", "GreekYogurtWithBerries",
             Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
             200, 17, 15, 4, 282.1,
             [.highProtein, .lowGlycemic, .gutFriendly, .pcosFriendly],
             [
                Ingredient(name: "Greek Yogurt", quantity: 120, protein: 10, carbs: 4, fats: 3.6, fibre: 0, tags: [.highProtein]),
                Ingredient(name: "Honey", quantity: 50, protein: 0, carbs: 41, fats: 0, fibre: 0, tags: [.wholeFood]),
                Ingredient(name: "Blueberries", quantity: 30, protein: 0.2, carbs: 7, fats: 0.1, fibre: 1.2, tags: [.lowGlycemic])
             ]),
            ("Avocado Toast", "AvacadoToast",
             Calendar.current.date(byAdding: .hour, value: -5, to: Date())!,
             150, 6, 25, 14, 220.39,
             [.healthyFats, .lowGlycemic, .antiInflammatory, .wholeFood],
             [
                Ingredient(name: "Avocado", quantity: 70, protein: 1.4, carbs: 4, fats: 10, fibre: 3, tags: [.healthyFats]),
                Ingredient(name: "Whole Grain Bread", quantity: 80, protein: 4.5, carbs: 20, fats: 1.2, fibre: 4, tags: [.wholeFood, .lowGlycemic])
             ]),
            ("Almonds", "Almonds",
             Calendar.current.date(byAdding: .hour, value: -1, to: Date())!,
             30, 6, 6, 14, nil,
             [.healthyFats, .highProtein, .wholeFood], nil),
            ("Oatmeal with Chia Seeds", nil,
             Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
             250, 12, 45, 8, nil,
             [.lowGlycemic, .wholeFood, .pcosFriendly], nil),
            ("Grilled Chicken Salad", nil,
             Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
             350, 32, 12, 10, nil,
             [.highProtein, .lowCarb, .antiInflammatory, .wholeFood], nil),
            ("Salmon with Quinoa", nil,
             Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
             400, 35, 40, 18, nil,
             [.highProtein, .healthyFats, .antiInflammatory, .wholeFood], nil),
            ("Spinach Smoothie", nil,
             Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
             350, 10, 28, 5, nil,
             [.antiInflammatory, .lowGlycemic, .wholeFood], nil),
            ("Lentil Soup", nil,
             Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
             300, 18, 40, 3, nil,
             [.highProtein, .lowGlycemic, .wholeFood, .pcosFriendly], nil),
        ]
        
        for (name, image, time, serving, protein, carbs, fats, customCal, tags, ingredients) in sampleData {
            let food = Food(
                id: UUID(), name: name, image: image, timeStamp: time,
                servingSize: serving, proteinContent: protein, carbsContent: carbs,
                fatsContent: fats, customCalories: customCal, tags: tags, ingredients: ingredients
            )
            let cdFood = CDFoodLog.from(food, context: context)
            
            // Link to CDDailyContext (Fix for Problem 4)
            let dailyContext = DailyActivityDataStore.shared.getOrCreateContext(for: food.timeStamp)
            cdFood.dailyContext = dailyContext
        }
        
        saveContext()
        print("Seeded \(sampleData.count) sample CDFoodLog records")
    }
}
