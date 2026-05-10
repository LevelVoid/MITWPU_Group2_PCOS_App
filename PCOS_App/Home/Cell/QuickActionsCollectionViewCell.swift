import UIKit

protocol QuickActionsDelegate: AnyObject {
    func quickActionsDidTapAddMeal()
    func quickActionsDidTapStartWorkout()
}

class QuickActionsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dietActionCard: UIView!
    @IBOutlet weak var workoutActionCard: UIView!
    
    @IBOutlet weak var durationGoal: UILabel!
    @IBOutlet weak var stepsGoal: UILabel!
    @IBOutlet weak var fatsGoal: UILabel!
    @IBOutlet weak var carbsGoal: UILabel!
    @IBOutlet weak var proteinGoal: UILabel!
    
    @IBOutlet weak var durationCompleted: UILabel!
    @IBOutlet weak var stepsCompleted: UILabel!
    @IBOutlet weak var fatsCompleted: UILabel!
    @IBOutlet weak var carbsCompleted: UILabel!
    @IBOutlet weak var proteinCompleted: UILabel!
    
    // Missing duration labels in XIB
    @IBOutlet weak var workoutDurationCompleted: UILabel!
    @IBOutlet weak var workoutDurationGoal: UILabel!
    
    @IBOutlet weak var workoutButton: UIButton!
    
    weak var delegate: QuickActionsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dietActionCard.layer.cornerRadius = 20
        workoutActionCard.layer.cornerRadius = 20
        dietActionCard.layer.borderWidth = 0
        workoutActionCard.layer.borderWidth = 0

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure buttons are always pill shaped regardless of height
        if let btn = workoutButton {
            btn.layer.cornerRadius = btn.bounds.height / 2
        }
        // If there's an addMealButton outlet added in future, apply similarly
    }
    
    func configure() {
        // Diet Data from Core Data
        let totals = FoodLogDataStore.todaysMeal.reduce(into: (0.0, 0.0, 0.0)) { result, food in
            result.0 += food.proteinContent
            result.1 += food.carbsContent
            result.2 += food.fatsContent
        }
        proteinCompleted.text = "\(Int(totals.0))"
        carbsCompleted.text = "\(Int(totals.1))"
        fatsCompleted.text = "\(Int(totals.2))"
        
        // Workout Data from Core Data (CDDailyContext) — single source of truth
        let allActivities = DailyActivityDataStore.shared.loadAll()
        let calendar = Calendar.current
        let todayActivity = allActivities.first(where: { calendar.isDateInToday($0.date) })
        
        let todayMinutes = (todayActivity?.activeDurationSeconds ?? 0) / 60
        let todaySteps = todayActivity?.steps ?? 0
        let todayCalories = todayActivity?.totalCalories ?? 0
        
        durationCompleted.text = "\(todayMinutes)"
        stepsCompleted.text = "\(todaySteps)"
        workoutDurationCompleted.text = "\(todayCalories)"
        
        if let profile = ProfileService.shared.buildUserProfile() {
            let goals = GoalEngine.generateGoals(for: profile)
            let workoutGoals = goals.workout
            let dietGoals    = goals.diet

            // Use starting (ramp-adjusted) targets so home-screen cards reflect
            // the achievable day-1 goal for each user's lifestyle baseline.
            let goalProtein = Int(round(Double(dietGoals.startingProteinGrams) / 5.0)) * 5
            let goalCarbs   = Int(round(Double(dietGoals.startingCarbsGrams)   / 5.0)) * 5
            let goalFats    = Int(round(Double(dietGoals.startingFatsGrams)    / 5.0)) * 5

            proteinGoal.text = "/ \(goalProtein) g"
            carbsGoal.text   = "/ \(goalCarbs) g"
            fatsGoal.text    = "/ \(goalFats) g"

            let goalMinutes  = Int(round(Double(workoutGoals.startingMinutesPerDay) / 5.0)) * 5
            let goalCalories = Int(round(Double(workoutGoals.caloriesBurnedPerDay)  / 10.0)) * 10
            let goalSteps    = Int(round(Double(workoutGoals.startingStepsPerDay)   / 100.0)) * 100

            durationGoal.text        = "/ \(goalMinutes) min"
            workoutDurationGoal.text = "/ \(goalCalories) kcal"
            stepsGoal.text           = "/ \(goalSteps)"
        }
    }


    @IBAction func addMeal(_ sender: Any) {
        delegate?.quickActionsDidTapAddMeal()
    }
    
    @IBAction func startWorkout(_ sender: Any) {
        delegate?.quickActionsDidTapStartWorkout()
    }
}
