import UIKit

class FoodSuggestionsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var mainContent: UIView!
    @IBOutlet weak var Todaysfocus: UIButton!
    @IBOutlet weak var DescriptionFocus: UILabel!
    
    @IBOutlet weak var MealName1: UILabel!
    @IBOutlet weak var mealGram1: UILabel!
    @IBOutlet weak var ImpactTag1_1: UILabel!
    @IBOutlet weak var ImpactTag2_1: UILabel!
    
    @IBOutlet weak var MealName2: UILabel!
    @IBOutlet weak var mealGram2: UILabel!
    @IBOutlet weak var ImpactTag1_2: UILabel!
    @IBOutlet weak var ImpactTag2_2: UILabel!
    
    @IBOutlet weak var MealName3: UILabel!
    @IBOutlet weak var mealGram3: UILabel!
    @IBOutlet weak var ImpactTag1_3: UILabel!
    @IBOutlet weak var ImpactTag2_3: UILabel!
    
    
    static let identifier = "FoodSuggestionsCollectionViewCell"
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    // MARK: - Loading State
    func showLoadingState() {
        Todaysfocus.setTitle("Loading", for: .normal)
        DescriptionFocus.text = "Generating personalised meal suggestions"
        MealName1.text = "—"; mealGram1.text = "—"; ImpactTag1_1.text = ""; ImpactTag2_1.text = ""
        MealName2.text = "—"; mealGram2.text = "—"; ImpactTag1_2.text = ""; ImpactTag2_2.text = ""
        MealName3.text = "—"; mealGram3.text = "—"; ImpactTag1_3.text = ""; ImpactTag2_3.text = ""
    }

    // MARK: - Configure with AI Output
    func configure(with output: MealRecommendationOutput) {
        firstView.layer.cornerRadius = 10
        secondView.layer.cornerRadius = 10
        thirdView.layer.cornerRadius = 10
        Todaysfocus.setTitle(output.focusTag, for: .normal)
        DescriptionFocus.text = output.observationLine

        let foods = output.foods
        guard foods.count >= 3 else { return }

        MealName1.text = foods[0].name
        mealGram1.text = foods[0].primaryMacro
        ImpactTag1_1.text = foods[0].impactTags.count > 0 ? foods[0].impactTags[0] : ""
        ImpactTag2_1.text = foods[0].impactTags.count > 1 ? foods[0].impactTags[1] : ""

        MealName2.text = foods[1].name
        mealGram2.text = foods[1].primaryMacro
        ImpactTag1_2.text = foods[1].impactTags.count > 0 ? foods[1].impactTags[0] : ""
        ImpactTag2_2.text = foods[1].impactTags.count > 1 ? foods[1].impactTags[1] : ""

        MealName3.text = foods[2].name
        mealGram3.text = foods[2].primaryMacro
        ImpactTag1_3.text = foods[2].impactTags.count > 0 ? foods[2].impactTags[0] : ""
        ImpactTag2_3.text = foods[2].impactTags.count > 1 ? foods[2].impactTags[1] : ""
    }
}
