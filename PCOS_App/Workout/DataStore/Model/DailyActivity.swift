import Foundation

struct DailyActivity: Codable {
    let date: Date
    var steps: Int
    var caloriesBurned: Int
    var activeDurationSeconds: Int
    var healthKitCalories: Int
    
    // Total calories metric used by Charts
    var totalCalories: Int {
        if healthKitCalories > 0 {
            return healthKitCalories + caloriesBurned
        }
        return caloriesBurned
    }
}
