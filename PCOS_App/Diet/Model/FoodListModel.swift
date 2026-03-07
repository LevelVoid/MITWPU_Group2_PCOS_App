//
//  FoodListDataSource.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/12/25.
//

import Foundation

struct FoodItem: Codable, Identifiable {
    let id: Int
    let name: String
    let calories: Int
    var image: String
    let servingSize: Double
    var unit: String
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var category: String
    var mealType: String
    var impactTags: [ImpactTags]
    var isSelected: Bool
    var desc: String
    var ingredients: [Ingredient]

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id           = try c.decode(Int.self, forKey: .id)
        name         = try c.decode(String.self, forKey: .name)
        calories     = try c.decode(Int.self, forKey: .calories)
        image        = try c.decodeIfPresent(String.self, forKey: .image) ?? "dietPlaceholder"
        servingSize  = try c.decode(Double.self, forKey: .servingSize)
        unit         = try c.decodeIfPresent(String.self, forKey: .unit) ?? "g"
        protein      = try c.decode(Double.self, forKey: .protein)
        carbs        = try c.decode(Double.self, forKey: .carbs)
        fat          = try c.decode(Double.self, forKey: .fat)
        fiber        = try c.decodeIfPresent(Double.self, forKey: .fiber) ?? 0
        category     = try c.decodeIfPresent(String.self, forKey: .category) ?? ""
        mealType     = try c.decodeIfPresent(String.self, forKey: .mealType) ?? ""
        impactTags   = try c.decodeIfPresent([ImpactTags].self, forKey: .impactTags) ?? []
        isSelected   = try c.decodeIfPresent(Bool.self, forKey: .isSelected) ?? false
        desc         = try c.decodeIfPresent(String.self, forKey: .desc) ?? ""
        ingredients  = try c.decodeIfPresent([Ingredient].self, forKey: .ingredients) ?? []
    }

    // Manual init for creating FoodItems in code (DescribeFoodVC, AddDescribedMealVC)
    init(id: Int, name: String, calories: Int, image: String = "dietPlaceholder",
         servingSize: Double, unit: String = "g", protein: Double, carbs: Double,
         fat: Double, fiber: Double = 0, category: String = "", mealType: String = "",
         impactTags: [ImpactTags] = [], isSelected: Bool = false, desc: String = "",
         ingredients: [Ingredient] = []) {
        self.id = id
        self.name = name
        self.calories = calories
        self.image = image
        self.servingSize = servingSize
        self.unit = unit
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.category = category
        self.mealType = mealType
        self.impactTags = impactTags
        self.isSelected = isSelected
        self.desc = desc
        self.ingredients = ingredients
    }
}
