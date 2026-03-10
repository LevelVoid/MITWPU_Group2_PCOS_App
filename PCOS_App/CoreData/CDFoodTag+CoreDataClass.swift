import Foundation
import CoreData

@objc(CDFoodTag)
public class CDFoodTag: NSManagedObject {
    
    /// Convert to ImpactTags enum
    var impactTag: ImpactTags? {
        guard let name = tagName else { return nil }
        return ImpactTags(rawValue: name)
    }
    
    // MARK: - Research-Backed Computed Tag Engine
    
    /// Computes macro-based impact tags using peer-reviewed nutrition formulas.
    ///
    /// Sources:
    /// - Protein Energy %: EU Regulation (EC) No 1924/2006
    /// - Carbohydrate Energy %: IOM Dietary Reference Intakes
    /// - Fiber Density: EFSA Nutrition Claims Regulation
    /// - Available Carbs: FAO/WHO Expert Consultation (1998)
    ///
    /// - Parameters:
    ///   - protein: grams of protein per serving
    ///   - carbs: grams of total carbohydrates per serving
    ///   - fats: grams of fat per serving
    ///   - fiber: grams of dietary fiber per serving
    ///   - calories: total kcal per serving (pass 0 to skip % based tags)
    ///   - servingGrams: serving size in grams (for density calculations)
    /// - Returns: Array of ImpactTags raw value strings
    static func computeTags(
        protein: Double,
        carbs: Double,
        fats: Double,
        fiber: Double,
        calories: Double,
        servingGrams: Double
    ) -> [String] {
        var tags: [String] = []
        
        // ━━━ 1. Protein Energy % ━━━
        // Formula: (Protein(g) × 4 / Calories) × 100
        // Source: European Commission Regulation (EC) No 1924/2006
        if calories > 0 {
            let proteinEnergyPct = (protein * 4.0 / calories) * 100.0
            if proteinEnergyPct >= 20.0 {
                tags.append(ImpactTags.highProtein.rawValue)
            } else if proteinEnergyPct < 10.0 {
                tags.append(ImpactTags.lowProtein.rawValue)
            }
        }
        
        // ━━━ 2. Carbohydrate Energy % ━━━
        // Formula: (Carbs(g) × 4 / Calories) × 100
        // Source: IOM Dietary Reference Intakes
        if calories > 0 {
            let carbEnergyPct = (carbs * 4.0 / calories) * 100.0
            if carbEnergyPct > 60.0 {
                tags.append(ImpactTags.highCarb.rawValue)
            } else if carbEnergyPct < 40.0 {
                tags.append(ImpactTags.lowCarb.rawValue)
            }
        }
        
        // ━━━ 3. Fiber Density ━━━
        // Formula: Fiber(g) per 100g food
        // Source: EFSA Nutrition Claims Regulation
        if servingGrams > 0 {
            let fiberPer100g = (fiber / servingGrams) * 100.0
            if fiberPer100g >= 6.0 {
                tags.append(ImpactTags.highFibre.rawValue)
            } else if fiberPer100g < 3.0 {
                tags.append(ImpactTags.lowFibre.rawValue)
            }
        }
        
        // ━━━ 4. Fat Quality (threshold-based) ━━━
        // Simplified: >15g fat per serving = fat-dominant
        // Full fat quality ratio needs unsaturated/saturated split (future)
        // Source: Schwingshackl et al., BMJ (2018)
        if fats >= 15.0 {
            tags.append(ImpactTags.healthyFats.rawValue)
        } else if fats < 3.0 && calories > 0 {
            // Very low fat
        }
        
        // ━━━ 5. Available Carbs (for future GL) ━━━
        // Formula: AvailableCarbs = Carbs - Fiber
        // Source: FAO/WHO (1998)
        // Note: GL = (GI × AvailableCarbs) / 100
        // GI is per-food from catalog, not computable from macros.
        // When GI data is available on FoodItem, add:
        //   let availableCarbs = max(carbs - fiber, 0)
        //   let gl = (gi * availableCarbs) / 100.0
        //   if gl <= 10 { tags.append("lowGlycemic") }
        //   if gl >= 20 { tags.append("highGlycemic") }
        
        return tags
    }
    
    // MARK: - Save Tags to Core Data
    
    /// Saves both static (catalog) and computed (formula-derived) tags for a CDFoodLog.
    /// Replaces any existing computed tags, keeps static tags.
    static func saveTags(
        for cdFoodLog: CDFoodLog,
        staticTags: [ImpactTags]?,
        context: NSManagedObjectContext
    ) {
        // 1. Delete old computed tags (keep static ones)
        if let existing = cdFoodLog.foodTags as? Set<CDFoodTag> {
            let oldComputed = existing.filter { $0.isComputed }
            for tag in oldComputed {
                context.delete(tag)
            }
        }
        
        // 2. Add static tags (from catalog/barcode/AI)
        if let staticTags = staticTags {
            for tag in staticTags where tag != .none {
                let cdTag = CDFoodTag(context: context)
                cdTag.id = UUID()
                cdTag.tagName = tag.rawValue
                cdTag.isComputed = false
                cdTag.foodLog = cdFoodLog
            }
        }
        
        // 3. Compute and add formula-derived tags
        let calories: Double
        if cdFoodLog.customCalories > 0 {
            calories = cdFoodLog.customCalories
        } else {
            calories = (cdFoodLog.proteinContent * 4) +
                       (cdFoodLog.carbsContent * 4) +
                       (cdFoodLog.fatsContent * 9)
        }
        
        let computedTags = computeTags(
            protein: cdFoodLog.proteinContent,
            carbs: cdFoodLog.carbsContent,
            fats: cdFoodLog.fatsContent,
            fiber: cdFoodLog.fiberContent,
            calories: calories,
            servingGrams: cdFoodLog.servingSize
        )
        
        for tagName in computedTags {
            // Avoid duplicates: skip if already added as static
            if let staticTags = staticTags,
               staticTags.contains(where: { $0.rawValue == tagName }) {
                continue
            }
            let cdTag = CDFoodTag(context: context)
            cdTag.id = UUID()
            cdTag.tagName = tagName
            cdTag.isComputed = true
            cdTag.foodLog = cdFoodLog
        }
    }
}
