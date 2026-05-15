import Foundation
import TipKit

@available(iOS 17.0, *)
struct LogPeriodTip: Tip {
    var title: Text { Text("Log Your First Period") }
    var message: Text? { Text("Tap this button to log your first period and kick off your PCOS journey!") }
    var image: Image? { Image(systemName: "drop.fill") }
}

@available(iOS 17.0, *)
struct LogSymptomTip: Tip {
    var title: Text { Text("Log Your Symptoms") }
    var message: Text? { Text("How are you feeling today? Tap here to log your symptoms.") }
    var image: Image? { Image(systemName: "list.clipboard.fill") }
}

@available(iOS 17.0, *)
struct ChatbotTip: Tip {
    var title: Text { Text("Meet Adira, Your AI Coach") }
    var message: Text? { Text("Ask Adira anything about PCOS — diet, symptoms, cycle, you name it! Tap to chat now.") }
    var image: Image? { Image(systemName: "bubble.left.and.bubble.right.fill") }
}

@available(iOS 17.0, *)
struct CustomRoutineTip: Tip {
    var title: Text { Text("Custom Routines") }
    var message: Text? { Text("Create your own custom workout routine by tapping here.") }
    var image: Image? { Image(systemName: "figure.run") }
}

@available(iOS 17.0, *)
struct RecommendedRoutineTip: Tip {
    var title: Text { Text("Recommended For You") }
    var message: Text? {
        let workoutType = UserDefaults.standard.string(forKey: "userWorkoutType") ?? "activity"
        return Text("We've curated these routines specifically for your \(workoutType.lowercased()) level and current menstrual phase.")
    }
    var image: Image? { Image(systemName: "star.fill") }
}

@available(iOS 17.0, *)
struct LogMealTip: Tip {
    var title: Text { Text("Log Your First Meal") }
    var message: Text? { Text("Tap here to log your first meal and start tracking your nutrition.") }
    var image: Image? { Image(systemName: "fork.knife") }
}

@available(iOS 17.0, *)
struct AddExerciseTip: Tip {
    var title: Text { Text("Add Exercises") }
    var message: Text? { Text("Tap this button to browse and add exercises to your custom routine.") }
    var image: Image? { Image(systemName: "plus.circle.fill") }
}

@available(iOS 17.0, *)
struct EditNameTip: Tip {
    var title: Text { Text("Edit & Save") }
    var message: Text? { Text("You can customize the reps and sets of each exercise below. Then, give your routine a name and hit Save!") }
    var image: Image? { Image(systemName: "pencil") }
}

// MARK: - Add Meal Options Tips

@available(iOS 17.0, *)
struct AddMealScanBarcodeTip: Tip {
    var title: Text { Text("Scan Barcode") }
    var message: Text? { Text("Instantly log packaged foods by scanning their barcode.") }
    var image: Image? { Image(systemName: "viewfinder") }
}

@available(iOS 17.0, *)
struct AddMealScanImageTip: Tip {
    var title: Text { Text("Scan Image") }
    var message: Text? { Text("Take a photo of your plate and let AI instantly analyze the meal.") }
    var image: Image? { Image(systemName: "camera.fill") }
}

@available(iOS 17.0, *)
struct AddMealDescribeTip: Tip {
    var title: Text { Text("Describe Meal") }
    var message: Text? { Text("Type or dictate what you ate and our AI will calculate the macros.") }
    var image: Image? { Image(systemName: "bubble.left.fill") }
}

@available(iOS 17.0, *)
struct AddMealSearchTip: Tip {
    var title: Text { Text("Search Meals") }
    var message: Text? { Text("Search our database for foods, or quickly pick from your recent meals.") }
    var image: Image? { Image(systemName: "magnifyingglass") }
}
