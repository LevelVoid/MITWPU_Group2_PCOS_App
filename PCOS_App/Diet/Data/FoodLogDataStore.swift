//
//  FoodLogDataStore.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/12/25.
//

import Foundation

struct FoodLogDataSource {
    
    static func addFoodBarCode(_ barCode: Food) {
        sampleFoods.append(barCode)
    }
    
    
    static var sampleFoods: [Food] = [
        // TODAY - Morning
        Food(
            id: UUID(),
            name: "Greek Yogurt with Berries",
            image: "GreekYogurtWithBerries",
            timeStamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
            quantity: 200,
            proteinContent: 17,
            carbsContent: 15,
            fatsContent: 4,
            fibreContent: 3,
            customCalories: 282.1,
            tags: [.highProtein, .lowGlycemic, .gutFriendly, .pcosFriendly],
            ingredients: [
                Ingredient(
                    id: UUID(),
                    name: "Greek Yogurt",
                    quantity: 120,
                    protein: 10,   // typical for 120g Greek yogurt
                    carbs: 4,
                    fats: 3.6,
                    fibre: 0,
                    tags: [.highProtein]
                ),
                Ingredient(
                    id: UUID(),
                    name: "Honey",
                    quantity: 50,
                    protein: 0,
                    carbs: 41,     // honey is mostly carbs
                    fats: 0,
                    fibre: 0,
                    tags: [.wholeFood]
                ),
                Ingredient(
                    id: UUID(),
                    name: "Blueberries",
                    quantity: 30,
                    protein: 0.2,
                    carbs: 7,
                    fats: 0.1,
                    fibre: 1.2,
                    tags: [.lowGlycemic]
                )
            ]
        ),
        // TODAY - Lunch
        Food(
            id: UUID(),
            name: "Avocado Toast",
            image: "AvacadoToast",
            timeStamp: Calendar.current.date(byAdding: .hour, value: -5, to: Date()) ?? Date(),
            quantity: 150,
            proteinContent: 6,
            carbsContent: 25,
            fatsContent: 14,
            fibreContent: 7,
            customCalories: 220.39,
            tags: [.healthyFats, .lowGlycemic, .antiInflammatory, .wholeFood],
            ingredients: [
                            Ingredient(id: UUID(), name: "Avocado", quantity: 70,
                                       protein: 1.4, carbs: 4, fats: 10, fibre: 3,
                                       tags: [.healthyFats]),
                            Ingredient(id: UUID(), name: "Whole Grain Bread", quantity: 80,
                                       protein: 4.5, carbs: 20, fats: 1.2, fibre: 4,
                                       tags: [.wholeFood, .lowGlycemic])
                        ]
        ),
        // TODAY - Snack
        Food(
            id: UUID(),
            name: "Almonds",
            image: "Almonds",
            timeStamp: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date(),
            quantity: 30,
            proteinContent: 6,
            carbsContent: 6,
            fatsContent: 14,
            fibreContent: 3,
            tags: [.healthyFats, .highProtein, .wholeFood]
        ),
        
        // YESTERDAY - Breakfast
        Food(
            id: UUID(),
            name: "Oatmeal with Chia Seeds",
            image: nil,
            timeStamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            quantity: 250,
            proteinContent: 12,
            carbsContent: 45,
            fatsContent: 8,
            fibreContent: 10,
            tags: [.lowGlycemic, .wholeFood, .pcosFriendly]
        ),
        // YESTERDAY - Lunch
        Food(
            id: UUID(),
            name: "Grilled Chicken Salad",
            image: nil,
            timeStamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            quantity: 350,
            proteinContent: 32,
            carbsContent: 12,
            fatsContent: 10,
            fibreContent: 5,
            tags: [.highProtein, .lowCarb, .antiInflammatory, .wholeFood],
            ingredients: [
                           Ingredient(id: UUID(), name: "Chicken Breast", quantity: 120,
                                      protein: 31, carbs: 0, fats: 3.6, fibre: 0,
                                      tags: [.highProtein]),
                           Ingredient(id: UUID(), name: "Lettuce", quantity: 50,
                                      protein: 0.5, carbs: 2, fats: 0.1, fibre: 1,
                                      tags: [.wholeFood]),
                           Ingredient(id: UUID(), name: "Olive Oil", quantity: 10,
                                      protein: 0, carbs: 0, fats: 10, fibre: 0,
                                      tags: [.healthyFats])
                       ]
        ),
        
        // 2 DAYS AGO
        Food(
            id: UUID(),
            name: "Salmon with Quinoa",
            image: nil,
            timeStamp: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            quantity: 400,
            proteinContent: 35,
            carbsContent: 40,
            fatsContent: 18,
            fibreContent: 5,
            tags: [.highProtein, .healthyFats, .antiInflammatory, .wholeFood]
        ),
        Food(
            id: UUID(),
            name: "Chocolate Milkshake",
            image: nil,
            timeStamp: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            quantity: 300,
            proteinContent: 8,
            carbsContent: 55,
            fatsContent: 12,
            fibreContent: 1,
            tags: [.sugary, .insulinSpiking, .processed, .chocolate, .dairySensitive]
        ),
        
        // 3 DAYS AGO
        Food(
            id: UUID(),
            name: "Spinach Smoothie",
            image: nil,
            timeStamp: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            quantity: 350,
            proteinContent: 10,
            carbsContent: 28,
            fatsContent: 5,
            fibreContent: 6,
            tags: [.antiInflammatory, .lowGlycemic, .wholeFood]
        ),
        
        // 4 DAYS AGO
        Food(
            id: UUID(),
            name: "Lentil Soup",
            image: nil,
            timeStamp: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(),
            quantity: 300,
            proteinContent: 18,
            carbsContent: 40,
            fatsContent: 3,
            fibreContent: 16,
            tags: [.highProtein, .lowGlycemic, .wholeFood, .pcosFriendly]
        ),
        
        // 5 DAYS AGO
        Food(
            id: UUID(),
            name: "Egg White Omelette",
            image: nil,
            timeStamp: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            quantity: 200,
            proteinContent: 25,
            carbsContent: 5,
            fatsContent: 2,
            fibreContent: 2,
            tags: [.highProtein, .lowCarb, .wholeFood]
        )
    ]
}
