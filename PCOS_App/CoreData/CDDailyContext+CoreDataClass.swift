import Foundation
import CoreData

@objc(CDDailyContext)
public class CDDailyContext: NSManagedObject {
    
    /// Total calories for the day: session cals + background Apple Health cals.
    var totalCalories: Int {
        if healthKitCalories > 0 {
            return Int(healthKitCalories + caloriesBurned)
        }
        return Int(caloriesBurned)
    }
    
    var sleepHours: Double? {
        guard let sleep = sleepTime, let wake = wakeTime else { return nil }
        return wake.timeIntervalSince(sleep) / 3600.0
    }
    
    /// Bridge to the DailyActivity struct used by SwiftUI Charts in MetricsViewController
    func toDailyActivity() -> DailyActivity {
        DailyActivity(
            date: date ?? Date(),
            steps: Int(steps),
            caloriesBurned: Int(caloriesBurned),
            activeDurationSeconds: Int(activeDurationSeconds),
            healthKitCalories: Int(healthKitCalories)
        )
    }
}
