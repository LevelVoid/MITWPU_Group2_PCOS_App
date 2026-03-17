//
//  NutritionHeader.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/12/25.
//

import UIKit

protocol NutritionHeaderDelegate: AnyObject {
    func didTapProteinView()
    func didTapCarbsView()
    func didTapFatsView()
}

class NutritionHeader: UITableViewHeaderFooterView {

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
    
    weak var delegate: NutritionHeaderDelegate?
    var calories: Double = 0
   var fats: Double = 0
   var protein: Double = 0
   var carbs: Double = 0
   var fibre: Double = 0

   // ── Goal targets — set these from your VC before calling configure() ─────
   var goalCalories: Double = 2000
   var goalProtein: Double  = 90
   var goalCarbs: Double    = 180
   var goalFats: Double     = 60
   
   static var identifier = "NutritionHeader"
   static func nib() -> UINib {
       return UINib(nibName: identifier, bundle: nil)
   }
   
   func configure() {
       nutritionCard.layer.cornerRadius = 16
       nutritionCard.layer.masksToBounds = true
       nutritionCard.layer.borderColor = UIColor.systemGray5.cgColor
       nutritionCard.layer.borderWidth = 0.5
       stackMacros.layer.cornerRadius = 16
       setupTapGestures()
       
       if let user = ProfileService.shared.buildUserProfile() {
           let goals = GoalEngine.generateGoals(for: user)
           
           // Use starting (ramp-adjusted) macro targets so irregular/high-sugar
           // eaters begin with an achievable day-1 goal rather than the full ideal.
           goalProtein = Double(Int(round(Double(goals.diet.startingProteinGrams) / 5.0)) * 5)
           goalCarbs   = Double(Int(round(Double(goals.diet.startingCarbsGrams)   / 5.0)) * 5)
           goalFats    = Double(Int(round(Double(goals.diet.startingFatsGrams)    / 5.0)) * 5)
           
           let totalCalories = (goalProtein * 4) + (goalCarbs * 4) + (goalFats * 9)
           goalCalories = Double(Int(round(totalCalories / 10.0)) * 10)
       }
       
       setGoalLabels()
       setValues()
   }

   // ── Fills the "goal" labels from whatever the VC passed in ───────────────
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
       
       print("Tap gestures configured")
   }
   
   @objc private func proteinViewTapped() {
       print("Protein card tapped")
       animateTap(proteinView)
       delegate?.didTapProteinView()
   }
   
   @objc private func carbsViewTapped() {
       print("Carbs card tapped")
       animateTap(carbsView)
       delegate?.didTapCarbsView()
   }
   
   @objc private func fatsViewTapped() {
       print("Fats card tapped")
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
       calories = 0
       fats = 0
       protein = 0
       carbs = 0
       
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

   // ── Single source of truth for labels + progress bars ────────────────────
   private func updateLabelsAndBars() {
       caloriesConsumed.text = "\(Int(calories))"
       proteinGm.text        = "\(Int(protein))"
       carbsGm.text          = "\(Int(carbs))"
       fatsGm.text           = "\(Int(fats))"

       proteinProgress.progress = Float(min(protein / goalProtein, 1.0))
       carbsProgress.progress   = Float(min(carbs   / goalCarbs,   1.0))
       fatsProgress.progress    = Float(min(fats    / goalFats,    1.0))

       progressCircle.setProgress(to: Float(min(calories / goalCalories, 1.0)))
   }
}

extension NutritionHeader {
   func subtractValues(_ food: Food) {
       calories = max(0, calories - food.calories)
       fats     = max(0, fats     - food.fatsContent)
       protein  = max(0, protein  - food.proteinContent)
       carbs    = max(0, carbs    - food.carbsContent)
       updateLabelsAndBars()
   }
}
