//
//  IngredientsModel.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/12/25.
//

import Foundation

struct Ingredient: Codable, Identifiable {
    let id: UUID
    var name: String
    var quantity: Double
    var weight: Double?
    var unit: String
    var protein: Double
    var carbs: Double
    var fats: Double
    var fibre: Double
    var tags: [ImpactTags]

    var calories: Double? {
        (protein * 4) + (carbs * 4) + (fats * 9)
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        // JSON has UUID as a string like "7236a3bf-..."
        if let uuidString = try? c.decode(String.self, forKey: .id),
           let parsed = UUID(uuidString: uuidString) {
            id = parsed
        } else {
            id = (try? c.decode(UUID.self, forKey: .id)) ?? UUID()
        }
        name     = try c.decode(String.self, forKey: .name)
        quantity = try c.decode(Double.self, forKey: .quantity)
        weight   = try c.decodeIfPresent(Double.self, forKey: .weight)
        unit     = try c.decodeIfPresent(String.self, forKey: .unit) ?? "g"
        protein  = try c.decode(Double.self, forKey: .protein)
        carbs    = try c.decode(Double.self, forKey: .carbs)
        fats     = try c.decode(Double.self, forKey: .fats)
        fibre    = try c.decode(Double.self, forKey: .fibre)
        tags     = try c.decodeIfPresent([ImpactTags].self, forKey: .tags) ?? []
    }

    // Manual init for creating Ingredients in code
    init(id: UUID = UUID(), name: String, quantity: Double, weight: Double? = nil,
         unit: String = "g", protein: Double, carbs: Double, fats: Double,
         fibre: Double, tags: [ImpactTags] = []) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.weight = weight
        self.unit = unit
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
        self.fibre = fibre
        self.tags = tags
    }
}
