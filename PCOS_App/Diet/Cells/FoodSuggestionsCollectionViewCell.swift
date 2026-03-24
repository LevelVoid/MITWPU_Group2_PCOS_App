import UIKit

class FoodSuggestionsCollectionViewCell: UICollectionViewCell {
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyling()
        showLoadingState()
    }
    
    // MARK: - Styling
        private func setupStyling() {
            // Focus button (aesthetic label — not tappable)
            Todaysfocus.isUserInteractionEnabled = false
            Todaysfocus.layer.cornerRadius = Todaysfocus.frame.height / 2
            Todaysfocus.clipsToBounds = true
            Todaysfocus.backgroundColor = UIColor(red: 0.18, green: 0.47, blue: 1.0, alpha: 1)
            Todaysfocus.setTitleColor(.white, for: .normal)
            Todaysfocus.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)

            DescriptionFocus.font = .systemFont(ofSize: 13)
            DescriptionFocus.textColor = .secondaryLabel
            DescriptionFocus.numberOfLines = 2

            // Apply rounded corners to each food card view
            for card in [ImpactTag1_1, ImpactTag1_2, ImpactTag1_3,
                         ImpactTag2_1, ImpactTag2_2, ImpactTag2_3] {
                stylePillTag(card!)
            }
        }

        private func stylePillTag(_ label: UILabel) {
            label.layer.cornerRadius = 6
            label.clipsToBounds = true
        }

        // MARK: - Loading State
        func showLoadingState() {
            Todaysfocus.setTitle("Loading...", for: .normal)
            DescriptionFocus.text = "Generating your personalised meal suggestions..."
            MealName1.text = "—"; mealGram1.text = "—"; ImpactTag1_1.text = ""; ImpactTag2_1.text = ""
            MealName2.text = "—"; mealGram2.text = "—"; ImpactTag1_2.text = ""; ImpactTag2_2.text = ""
            MealName3.text = "—"; mealGram3.text = "—"; ImpactTag1_3.text = ""; ImpactTag2_3.text = ""
        }

        // MARK: - Configure with AI Output
        func configure(with output: MealRecommendationOutput) {
            // Focus tag button
            Todaysfocus.setTitle(output.focusTag, for: .normal)

            // Observation line
            DescriptionFocus.text = output.observationLine

            // Guard we have 3 foods
            let foods = output.foods
            guard foods.count >= 3 else { return }

            configure(
                meal: foods[0],
                name: MealName1, gram: mealGram1,
                tag1: ImpactTag1_1, tag2: ImpactTag2_1,
                color: "pink"
            )
            configure(
                meal: foods[1],
                name: MealName2, gram: mealGram2,
                tag1: ImpactTag1_2, tag2: ImpactTag2_2,
                color: "green"
            )
            configure(
                meal: foods[2],
                name: MealName3, gram: mealGram3,
                tag1: ImpactTag1_3, tag2: ImpactTag2_3,
                color: "amber"
            )
        }

        private func configure(
            meal: FoodCard,
            name: UILabel, gram: UILabel,
            tag1: UILabel, tag2: UILabel,
            color: String
        ) {
            name.text = meal.name
            name.font = .systemFont(ofSize: 13, weight: .semibold)
            name.numberOfLines = 2
            name.textAlignment = .natural

            gram.text = meal.primaryMacro
            gram.font = .systemFont(ofSize: 12, weight: .semibold)
            gram.textColor = accentColor(for: meal.colorHint)

            tag1.text = meal.impactTags.count > 0 ? meal.impactTags[0] : ""
            tag2.text = meal.impactTags.count > 1 ? meal.impactTags[1] : ""

            let pillBg = pillBackgroundColor(for: color)
            for tag in [tag1, tag2] {
                tag.font = .systemFont(ofSize: 11, weight: .medium)
                tag.textColor = accentColor(for: color).withAlphaComponent(0.9)
                tag.backgroundColor = pillBg
                tag.layer.cornerRadius = 6
                tag.clipsToBounds = true
            }
        }

        private func accentColor(for colorHint: String) -> UIColor {
            switch colorHint.lowercased() {
            case "pink":  return UIColor(red: 0.90, green: 0.30, blue: 0.45, alpha: 1)
            case "green": return UIColor(red: 0.20, green: 0.65, blue: 0.35, alpha: 1)
            case "amber": return UIColor(red: 0.90, green: 0.55, blue: 0.10, alpha: 1)
            default:      return .systemBlue
            }
        }

        private func pillBackgroundColor(for colorHint: String) -> UIColor {
            switch colorHint.lowercased() {
            case "pink":  return UIColor(red: 0.97, green: 0.80, blue: 0.82, alpha: 1)
            case "green": return UIColor(red: 0.74, green: 0.90, blue: 0.76, alpha: 1)
            case "amber": return UIColor(red: 0.97, green: 0.87, blue: 0.65, alpha: 1)
            default:      return UIColor.systemGray5
            }
        }
    }
