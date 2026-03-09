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
    
    func configure(steps: Int = 0, calories: Int = 0, duration: Int = 0, recommendedRoutineName: String? = nil) {
        // Diet data
        let totals = FoodLogDataSource.todaysMeal.reduce(into: (0.0, 0.0, 0.0)) { result, food in
            result.0 += food.proteinContent
            result.1 += food.carbsContent
            result.2 += food.fatsContent
        }
        proteinCompleted.text = "\(Int(totals.0))"
        carbsCompleted.text = "\(Int(totals.1))"
        fatsCompleted.text = "\(Int(totals.2))"

        // Workout data — mapped correctly based on Workout tab:
        // Flame icon (calories): stepsCompleted / stepsGoal
        // Walk icon (steps): durationCompleted / durationGoal
        // Clock icon (duration): workoutDurationCompleted / workoutDurationGoal
        
        stepsCompleted.text = "\(calories)"
        stepsGoal?.text = "/ 300 cal"
        
        durationCompleted.text = "\(steps)"
        durationGoal?.text = "/ 800"
        
        // Workout View Controller stores duration goal as 120s directly in the cards logic.
        workoutDurationCompleted?.text = "\(duration)"
        workoutDurationGoal?.text = "/ 120s"

        // Set recommended routine name on the workout button
//        if let routineName = recommendedRoutineName {
//            workoutButton?.setTitle(routineName, for: .normal)
//            var config = workoutButton?.configuration
//            config?.title = routineName
//            workoutButton?.configuration = config
//        }
    }

    @IBAction func addMeal(_ sender: Any) {
        delegate?.quickActionsDidTapAddMeal()
    }
    
    @IBAction func startWorkout(_ sender: Any) {
        delegate?.quickActionsDidTapStartWorkout()
    }
}

