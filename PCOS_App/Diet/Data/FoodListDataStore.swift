//
//  FoodListDataStore.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/12/25.
//

import Foundation

/// Read-only catalog of food items loaded from the bundled JSON.
/// The catalog is loaded once and cached in memory.
class FoodListdataStore {
    
    static var shared = FoodListdataStore()
    private init() {}
    
    /// Cached catalog — loaded once from JSON, reused on every call.
    private var cachedItems: [FoodItem]?
    
    // MARK: - Load Food Items (from bundled JSON)
    
    func loadFoodItems() -> [FoodItem] {
        // Return cache if already loaded
        if let cached = cachedItems {
            return cached
        }
        
        guard let url = Bundle.main.url(forResource: "csvjson", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("FoodListDataStore: csvjson.json not found in bundle")
            return []
        }
        
        do {
            let items = try JSONDecoder().decode([FoodItem].self, from: data)
            cachedItems = items
            print("FoodListDataStore: Loaded \(items.count) food items from JSON")
            return items
        } catch {
            print("FoodListDataStore: JSON decode error — \(error)")
            return []
        }
    }
    
    // MARK: - Lookup by ID (for resolving CDFoodLog.foodId → FoodItem)
    
    func foodItem(byId id: Int) -> FoodItem? {
        return loadFoodItems().first { $0.id == id }
    }
    
    // MARK: - Search Food Items
    
    func searchFoodItems(query: String) -> [FoodItem] {
        let items = loadFoodItems()
        if query.isEmpty { return items }
        return items.filter { $0.name.lowercased().contains(query.lowercased()) }
    }
}
