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
    
    @IBOutlet weak var dietRecView: UIView!
    @IBOutlet weak var workoutRecView: UIView!
    
    weak var delegate: QuickActionsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dietActionCard.layer.cornerRadius = 20
        workoutActionCard.layer.cornerRadius = 20
        dietRecView.layer.cornerRadius = 10
        workoutRecView.layer.cornerRadius = 10
    }
    
    func configure() {
        let totals = FoodLogDataSource.todaysMeal.reduce(into: (0.0, 0.0, 0.0)) { result, food in
            result.0 += food.proteinContent
            result.1 += food.carbsContent
            result.2 += food.fatsContent
        }
        proteinCompleted.text = "\(Int(totals.0))"
        carbsCompleted.text = "\(Int(totals.1))"
        fatsCompleted.text = "\(Int(totals.2))"
    }

    @IBAction func addMeal(_ sender: Any) {
        delegate?.quickActionsDidTapAddMeal()
    }
    
    @IBAction func startWorkout(_ sender: Any) {
        delegate?.quickActionsDidTapStartWorkout()
    }
}
