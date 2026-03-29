import UIKit

// Reuse the same delegate
protocol NutritionCellDelegate: AnyObject {
    func didTapProteinView()
    func didTapCarbsView()
    func didTapFatsView()
}

class NutritionHeaderCollectionViewCell: UICollectionViewCell {

    // Copy ALL @IBOutlets from NutritionHeader.swift here:
    @IBOutlet weak var nutritionCard: UIView!
    @IBOutlet weak var proteinView: UIView!
    @IBOutlet weak var carbsView: UIView!
    @IBOutlet weak var fatsView: UIView!
    @IBOutlet weak var stackMacros: UIStackView!
    @IBOutlet weak var progressCircle: CompletionCircleView!
    @IBOutlet weak var fatsProgress: UIProgressView!
    @IBOutlet weak var carbsProgress: UIProgressView!
    @IBOutlet weak var proteinProgress: UIProgressView!
    @IBOutlet weak var calToBeConsumed: UILabel!
    @IBOutlet weak var caloriesConsumed: UILabel!
    @IBOutlet weak var fatsGm: UILabel!
    @IBOutlet weak var carbsGm: UILabel!
    @IBOutlet weak var proteinGm: UILabel!
    @IBOutlet weak var calculatedProtein: UILabel!
    @IBOutlet weak var calculatedCarbohydrates: UILabel!
    @IBOutlet weak var calculatedFats: UILabel!

    weak var delegate: NutritionCellDelegate?

    var calories: Double = 0
    var fats: Double = 0
    var protein: Double = 0
    var carbs: Double = 0
    var fibre: Double = 0

    var goalCalories: Double = 2000
    var goalProtein: Double  = 90
    var goalCarbs: Double    = 180
    var goalFats: Double     = 60

    static let identifier = "NutritionHeaderCollectionViewCell"
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Reset progress bars from XIB defaults
        proteinProgress.progress = 0
        carbsProgress.progress = 0
        fatsProgress.progress = 0
        progressCircle.setProgress(to: 0)
    }

    // Copy the configure(), setGoalLabels(), setupTapGestures(),
    // setValues(), updateValues(_:), subtractValues(_:),
    // updateLabelsAndBars(), and animateTap(_:) methods
    // EXACTLY from NutritionHeader.swift — they work the same way.

    func configure() {
        nutritionCard.layer.cornerRadius = 20
        nutritionCard.layer.masksToBounds = true
        nutritionCard.layer.borderColor = UIColor.systemGray5.cgColor
        nutritionCard.layer.borderWidth = 0.5
        stackMacros.layer.cornerRadius = 20
        setupTapGestures()

        if let user = ProfileService.shared.buildUserProfile() {
            let goals = GoalEngine.generateGoals(for: user)
            goalProtein  = Double(Int(round(Double(goals.diet.startingProteinGrams) / 5.0)) * 5)
            goalCarbs    = Double(Int(round(Double(goals.diet.startingCarbsGrams)   / 5.0)) * 5)
            goalFats     = Double(Int(round(Double(goals.diet.startingFatsGrams)    / 5.0)) * 5)
            goalCalories = Double(Int(round(Double(goals.diet.dailyCalories) / 10.0)) * 10)
        }

        setGoalLabels()
        setValues()
    }

    private func setGoalLabels() {
        calToBeConsumed.text         = " / \(Int(goalCalories)) kcal"
        calculatedProtein.text       = " / \(Int(goalProtein)) g"
        calculatedCarbohydrates.text = " / \(Int(goalCarbs)) g"
        calculatedFats.text          = " / \(Int(goalFats)) g"
    }

    private func setupTapGestures() {
        proteinView.isUserInteractionEnabled = true
        carbsView.isUserInteractionEnabled = true
        fatsView.isUserInteractionEnabled = true

        proteinView.layer.cornerRadius = 8
        carbsView.layer.cornerRadius = 8
        fatsView.layer.cornerRadius = 8

        let proteinTap = UITapGestureRecognizer(target: self, action: #selector(proteinViewTapped))
        proteinView.addGestureRecognizer(proteinTap)

        let carbsTap = UITapGestureRecognizer(target: self, action: #selector(carbsViewTapped))
        carbsView.addGestureRecognizer(carbsTap)

        let fatsTap = UITapGestureRecognizer(target: self, action: #selector(fatsViewTapped))
        fatsView.addGestureRecognizer(fatsTap)
    }

    @objc private func proteinViewTapped() {
        animateTap(proteinView)
        delegate?.didTapProteinView()
    }

    @objc private func carbsViewTapped() {
        animateTap(carbsView)
        delegate?.didTapCarbsView()
    }

    @objc private func fatsViewTapped() {
        animateTap(fatsView)
        delegate?.didTapFatsView()
    }

    private func animateTap(_ view: UIView) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            view.alpha = 0.7
        }) { _ in
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                view.transform = .identity
                view.alpha = 1.0
            })
        }
    }

    func setValues() {
        calories = 0; fats = 0; protein = 0; carbs = 0
        for food in FoodLogDataStore.todaysMeal {
            calories += food.calories
            fats += food.fatsContent
            protein += food.proteinContent
            carbs += food.carbsContent
        }
        updateLabelsAndBars()
    }

    func updateValues(_ food: Food) {
        calories += food.calories
        fats += food.fatsContent
        protein += food.proteinContent
        carbs += food.carbsContent
        updateLabelsAndBars()
    }

    func subtractValues(_ food: Food) {
        calories = max(0, calories - food.calories)
        fats     = max(0, fats     - food.fatsContent)
        protein  = max(0, protein  - food.proteinContent)
        carbs    = max(0, carbs    - food.carbsContent)
        updateLabelsAndBars()
    }

    private func updateLabelsAndBars() {
        let iCal     = Int(calories)
        let iProtein = Int(protein)
        let iCarbs   = Int(carbs)
        let iFats    = Int(fats)

        caloriesConsumed.text = "\(iCal)"
        proteinGm.text        = "\(iProtein)"
        carbsGm.text          = "\(iCarbs)"
        fatsGm.text           = "\(iFats)"

        // Use Int-truncated values so bars match labels (e.g. 0.3g → label "0", bar 0)
        let pProg = Float(min(Double(iProtein) / goalProtein, 1.0))
        let cProg = Float(min(Double(iCarbs)   / goalCarbs,   1.0))
        let fProg = Float(min(Double(iFats)    / goalFats,    1.0))

        proteinProgress.progress = pProg
        carbsProgress.progress   = cProg
        fatsProgress.progress    = fProg

        // Hide tint at zero to avoid iOS's tiny-sliver rendering bug
        proteinProgress.progressTintColor = pProg > 0 ? .systemGreen  : .clear
        carbsProgress.progressTintColor   = cProg > 0 ? .systemOrange : .clear
        fatsProgress.progressTintColor    = fProg > 0 ? .systemIndigo : .clear

        progressCircle.setProgress(to: Float(min(Double(iCal) / goalCalories, 1.0)))
    }
}
