//
//  DailyGoalsCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/03/26.
//

import UIKit

class DailyGoalsCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var Goal1View: UIView!
    @IBOutlet weak var GoalImage_1: UIImageView!
    @IBOutlet weak var GoalCategory_1: UILabel!
    @IBOutlet weak var GoalTitle_1: UILabel!
    @IBOutlet weak var GoalDescription_1: UILabel!
    
    
    @IBOutlet weak var Goal2View: UIView!
    @IBOutlet weak var GoalImage_2: UIImageView!
    @IBOutlet weak var GoalCategory_2: UILabel!
    @IBOutlet weak var GoalTitle_2: UILabel!
    @IBOutlet weak var GoalDescription_2: UILabel!
    
    static let identifier = "DailyGoalsCollectionViewCell"
       static func nib() -> UINib {
           return UINib(nibName: identifier, bundle: nil)
       }

       override func awakeFromNib() {
           super.awakeFromNib()
           styleGoalView(Goal1View)
           styleGoalView(Goal2View)
           showLoadingState()
       }

       // MARK: - Configure
       func configure(with output: DailyGoalsOutput) {
           let goals = output.goals
           if goals.count > 0 { configureGoal(goals[0], view: Goal1View,
               image: GoalImage_1, category: GoalCategory_1,
               title: GoalTitle_1, desc: GoalDescription_1) }
           if goals.count > 1 { configureGoal(goals[1], view: Goal2View,
               image: GoalImage_2, category: GoalCategory_2,
               title: GoalTitle_2, desc: GoalDescription_2) }
       }

       func showLoadingState() {
           for (title, desc, cat) in [
               (GoalTitle_1, GoalDescription_1, GoalCategory_1),
               (GoalTitle_2, GoalDescription_2, GoalCategory_2)
           ] {
               title?.text = "Generating goal..."
               desc?.text = ""
               cat?.text = ""
           }
       }

       // MARK: - Private
       private func configureGoal(
           _ goal: GoalCard,
           view: UIView,
           image: UIImageView,
           category: UILabel,
           title: UILabel,
           desc: UILabel
       ) {
           let color = categoryColor(goal.category)

           // Card background tint
           view.backgroundColor = color.withAlphaComponent(0.08)
           view.layer.cornerRadius = 12
           view.layer.borderWidth = 1
           view.layer.borderColor = color.withAlphaComponent(0.2).cgColor

           // Icon
           image.image = UIImage(systemName: categoryIcon(goal.category))
           image.tintColor = color
           image.contentMode = .scaleAspectFit

           // Category pill
           category.text = goal.category.capitalized
           category.textColor = color
           category.font = .systemFont(ofSize: 11, weight: .semibold)

           // Title
           title.text = goal.title
           title.font = .systemFont(ofSize: 14, weight: .medium)
           title.textColor = .label
           title.numberOfLines = 2

           // Description
           desc.text = goal.sentence
           desc.font = .systemFont(ofSize: 13)
           desc.textColor = .secondaryLabel
           desc.numberOfLines = 3
       }

       private func styleGoalView(_ view: UIView) {
           view.layer.cornerRadius = 12
           view.layer.masksToBounds = true
       }

       private func categoryColor(_ category: String) -> UIColor {
           switch category.lowercased() {
           case "sleep":     return UIColor(red: 0.35, green: 0.30, blue: 0.85, alpha: 1)
           case "nutrition": return UIColor(red: 0.20, green: 0.65, blue: 0.35, alpha: 1)
           case "exercise":  return UIColor(red: 0.95, green: 0.50, blue: 0.10, alpha: 1)
           case "symptoms":  return UIColor(red: 0.85, green: 0.25, blue: 0.45, alpha: 1)
           default:          return UIColor(red: 0.85, green: 0.25, blue: 0.45, alpha: 1)
           }
       }

       private func categoryIcon(_ category: String) -> String {
           switch category.lowercased() {
           case "sleep":     return "moon.zzz.fill"
           case "nutrition": return "fork.knife"
           case "exercise":  return "figure.strengthtraining.traditional"
           case "symptoms":  return "heart.text.clipboard"
           default:          return "checkmark.circle.fill"
           }
       }
   }
