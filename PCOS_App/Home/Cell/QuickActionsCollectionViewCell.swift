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
    }


    @IBAction func addMeal(_ sender: Any) {
        delegate?.quickActionsDidTapAddMeal()
    }
    
    @IBAction func startWorkout(_ sender: Any) {
        delegate?.quickActionsDidTapStartWorkout()
    }
}

