import UIKit

class FoodSuggestionsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainContent: UIView!
    @IBOutlet weak var headerIcon: UIImageView!
    @IBOutlet weak var DescriptionFocus: UILabel!
    @IBOutlet weak var subDescriptionFocus: UILabel!
    @IBOutlet weak var separatorLine: UIView!
    
    // Meal 1
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var mealIconContainer1: UIView!
    @IBOutlet weak var mealIcon1: UIImageView!
    @IBOutlet weak var MealName1: UILabel!
    @IBOutlet weak var mealDescription1: UILabel!
    @IBOutlet weak var mealGram1: UILabel!
    @IBOutlet weak var mealCalories1: UILabel!
    @IBOutlet weak var tagContainer1: UIView!
    @IBOutlet weak var ImpactTag_1: UILabel!
    
    // Meal 2
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var mealIconContainer2: UIView!
    @IBOutlet weak var mealIcon2: UIImageView!
    @IBOutlet weak var MealName2: UILabel!
    @IBOutlet weak var mealDescription2: UILabel!
    @IBOutlet weak var mealGram2: UILabel!
    @IBOutlet weak var mealCalories2: UILabel!
    @IBOutlet weak var tagContainer2: UIView!
    @IBOutlet weak var ImpactTag_2: UILabel!
    
    // Meal 3
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var mealIconContainer3: UIView!
    @IBOutlet weak var mealIcon3: UIImageView!
    @IBOutlet weak var MealName3: UILabel!
    @IBOutlet weak var mealDescription3: UILabel!
    @IBOutlet weak var mealGram3: UILabel!
    @IBOutlet weak var mealCalories3: UILabel!
    @IBOutlet weak var tagContainer3: UIView!
    @IBOutlet weak var ImpactTag_3: UILabel!
    
    static let identifier = "FoodSuggestionsCollectionViewCell"
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        mainContent.layer.cornerRadius = 20
        mainContent.clipsToBounds = true
        
        // Header Icon Circle
        headerIcon.layer.cornerRadius = headerIcon.bounds.height / 2
        headerIcon.backgroundColor = .systemGray6
        
        [mealIconContainer1, mealIconContainer2, mealIconContainer3].forEach {
            $0?.layer.cornerRadius = ($0?.bounds.height ?? 40) / 2
            $0?.clipsToBounds = true
        }
        
        [tagContainer1, tagContainer2, tagContainer3].forEach {
            $0?.layer.cornerRadius = 12
            $0?.clipsToBounds = true
        }
        
        [firstView, secondView, thirdView].forEach {
            $0?.layer.cornerRadius = 12
            $0?.layer.borderWidth = 1
            $0?.layer.borderColor = UIColor.systemGray6.cgColor
            $0?.backgroundColor = .clear
        }
        
        // Keep protein/sep/cal labels hugged to the left — prevent stretching
        [mealGram1, mealGram2, mealGram3, mealCalories1, mealCalories2, mealCalories3].forEach {
            $0?.setContentHuggingPriority(.required, for: .horizontal)
            $0?.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
    }

    func showLoadingState() {
        DescriptionFocus.text = "Fetching recommendations..."
        subDescriptionFocus.text = "Crafting a personalized meal suggestion for you."
        [firstView, secondView, thirdView, separatorLine].forEach { $0?.isHidden = true }
    }

    func showErrorState(message: String) {
        DescriptionFocus.text = "Something went wrong"
        subDescriptionFocus.text = message
        [firstView, secondView, thirdView, separatorLine].forEach { $0?.isHidden = true }
    }

    func showGoalsMetState(observation: String, subObservation: String) {
        DescriptionFocus.text = observation
        subDescriptionFocus.text = subObservation
        [firstView, secondView, thirdView, separatorLine].forEach { $0?.isHidden = true }
    }

    func configure(with output: MealRecommendationOutput,
                    observationOverride: String? = nil,
                    subObservationOverride: String? = nil) {
        [firstView, secondView, thirdView, separatorLine].forEach { $0?.isHidden = false }
        
        // Use Swift-computed observation if provided, otherwise fall back to AI's
        DescriptionFocus.text = observationOverride ?? output.observationLine
        subDescriptionFocus.text = subObservationOverride ?? output.subObservationLine
        
        let foods = output.foods
        
        if foods.count > 0 { configureMeal(0, view: firstView, food: foods[0]) } else { firstView.isHidden = true }
        if foods.count > 1 { configureMeal(1, view: secondView, food: foods[1]) } else { secondView.isHidden = true }
        if foods.count > 2 { configureMeal(2, view: thirdView, food: foods[2]) } else { thirdView.isHidden = true }
    }
    
    private func configureMeal(_ index: Int, view: UIView, food: FoodCard) {
        let nameLabel: UILabel?
        let descLabel: UILabel?
        let gramLabel: UILabel?
        let calLabel: UILabel?
        let tagLabel: UILabel?
        let tagView: UIView?
        let iconView: UIImageView?
        let iconContainer: UIView?
        
        switch index {
        case 0:
            nameLabel = MealName1; descLabel = mealDescription1; gramLabel = mealGram1; calLabel = mealCalories1; tagLabel = ImpactTag_1; tagView = tagContainer1; iconView = mealIcon1; iconContainer = mealIconContainer1
        case 1:
            nameLabel = MealName2; descLabel = mealDescription2; gramLabel = mealGram2; calLabel = mealCalories2; tagLabel = ImpactTag_2; tagView = tagContainer2; iconView = mealIcon2; iconContainer = mealIconContainer2
        case 2:
            nameLabel = MealName3; descLabel = mealDescription3; gramLabel = mealGram3; calLabel = mealCalories3; tagLabel = ImpactTag_3; tagView = tagContainer3; iconView = mealIcon3; iconContainer = mealIconContainer3
        default: return
        }
        
        nameLabel?.text = food.name
        descLabel?.text = food.description
        gramLabel?.text = "\(food.primaryMacro)  |  \(food.calories)"
        tagLabel?.text = food.impactTag
        
        // Hide the separate calorie label and separator view — they're now combined into gramLabel
        calLabel?.isHidden = true
        if let infoStack = gramLabel?.superview as? UIStackView {
            for subview in infoStack.arrangedSubviews where !(subview is UILabel) {
                subview.isHidden = true  // hides the vSep separator view
            }
        }
        
        // Color coding — derived from impactTag, not AI's colorHint
        let color: UIColor
        let iconName: String
        let normalizedTag = food.impactTag.lowercased()
        
        switch normalizedTag {
        case let tag where tag.contains("protein"):
            color = UIColor(hex: "ea635d")
            iconName = "nuts_red"
        case let tag where tag.contains("healthy fats"):
            color = UIColor(red: 0.81, green: 0.47, blue: 0.18, alpha: 1)
            iconName = "fruits_yellow"
        default:
            // Low GI, High Fibre, Whole Food, etc.
            color = UIColor(red: 0.17, green: 0.55, blue: 0.25, alpha: 1)
            iconName = "salad_green"
        }
        
        tagView?.backgroundColor = color.withAlphaComponent(0.1)
        tagLabel?.textColor = color
        iconContainer?.backgroundColor = color.withAlphaComponent(0.05)
        iconView?.image = UIImage(named: iconName)
    }
}
