//
//  FoodDataSource.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/12/25.
//

import Foundation

struct Food: Codable, Identifiable {
    let id: UUID
    var name: String
    var image: String?
    var timeStamp: Date
    var quantity: Double
    
    // Base macros (if not ingredient-based)
    var proteinContent: Double
    var carbsContent: Double
    var fatsContent: Double
    var fibreContent: Double
    
    // Optional override
    var customCalories: Double?
    
    // Tags
    var tags: [ImpactTags]?
    
    // Ingredient list
    var ingredients: [Ingredient]? = nil
    
    var calories: Double {
            // 1: Explicit override
            if let customCalories = customCalories {
                return customCalories
            }
            
            // 2: Ingredient-based calories
            if let ingredients = ingredients {
                let total = ingredients.reduce(0) { $0 + $1.calories }
                return total.rounded(toPlaces: 2)
            }
            
            // 3: Macro-based calories
            let total = (proteinContent * 4) +
                        (carbsContent * 4) +
                        (fatsContent * 9)
            
            return total.rounded(toPlaces: 2)
        }
    
    var Insights: [String]?
    
}


struct OFFResponse: Codable {
    let status: Int
    let code: String
    let product: OFFProduct?
}

struct OFFProduct: Codable {
    let product_name: String?
    let image_url: String?
    let nutriments: OFFNutriments?
    let ingredients: [OFFIngredient]?
    
}

struct OFFNutriments: Codable {
    let energyKcal100g: Double?
    let proteins100g: Double?
    let carbohydrates100g: Double?
    let fat100g: Double?
    let fiber100g: Double?
    
    enum CodingKeys: String, CodingKey {
        case energyKcal100g = "energy-kcal_100g"
        case proteins100g = "proteins_100g"
        case carbohydrates100g = "carbohydrates_100g"
        case fat100g = "fat_100g"
        case fiber100g = "fiber_100g"
    }
}

struct OFFIngredient: Codable {
    let text: String?
}

extension OFFProduct{
    func toFood() -> Food {
            // Extract nutrients safely
            let nutr = nutriments
            
            // Map OFF ingredients (only have text) into our Ingredient model with safe defaults
            let mappedIngredients: [Ingredient]? = ingredients?.compactMap { offIng in
                guard let name = offIng.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
                    return nil
                }
                return Ingredient(
                    id: UUID(),
                    name: name,
                    quantity: 100,          // default to 100g
                    protein: 0,             // unknown per-ingredient macros
                    carbs: 0,
                    fats: 0,
                    fibre: 0,
                    tags: []                // no tags from OFF
                )
            }
            
            let food: Food = Food(
                id: UUID(),
                name: product_name ?? "Unknown Food",
                image: image_url,
                timeStamp: Date(),
                quantity: 100,
                proteinContent: nutr?.proteins100g ?? 0,
                carbsContent: nutr?.carbohydrates100g ?? 0,
                fatsContent: nutr?.fat100g ?? 0,
                fibreContent: nutr?.fiber100g ?? 0,
                customCalories: nutr?.energyKcal100g,
                tags: [],
                ingredients: mappedIngredients,
            )
            return food
        }
}
