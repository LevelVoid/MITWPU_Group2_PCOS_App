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
    
    weak var delegate: NutritionHeaderDelegate?
    var calories : Double = 0
    var fats : Double = 0
    var protein : Double = 0
    var carbs : Double = 0
    var fibre: Double = 0
    
    static var identifier = "NutritionHeader"
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    
    func configure(){
        nutritionCard.layer.cornerRadius = 16
        nutritionCard.layer.masksToBounds = true
        nutritionCard.layer.borderColor = UIColor.systemGray5.cgColor
        nutritionCard.layer.borderWidth = 0.5
        stackMacros.layer.cornerRadius = 16
        setupTapGestures()
        setValues()
    }
    
    private func setupTapGestures() {
        // Enable user interaction
        proteinView.isUserInteractionEnabled = true
        carbsView.isUserInteractionEnabled = true
        fatsView.isUserInteractionEnabled = true
        
        // Style the views
        proteinView.layer.cornerRadius = 8
        carbsView.layer.cornerRadius = 8
        fatsView.layer.cornerRadius = 8
        
        // Add tap gestures
        let proteinTap = UITapGestureRecognizer(target: self, action: #selector(proteinViewTapped))
        proteinView.addGestureRecognizer(proteinTap)
        
        let carbsTap = UITapGestureRecognizer(target: self, action: #selector(carbsViewTapped))
        carbsView.addGestureRecognizer(carbsTap)
        
        let fatsTap = UITapGestureRecognizer(target: self, action: #selector(fatsViewTapped))
        fatsView.addGestureRecognizer(fatsTap)
        
        print("✅ Tap gestures configured")
    }
    
    @objc private func proteinViewTapped() {
        print("🎯 Protein card tapped")
        animateTap(proteinView)
        delegate?.didTapProteinView()
    }
    
    @objc private func carbsViewTapped() {
        print("🎯 Carbs card tapped")
        animateTap(carbsView)
        delegate?.didTapCarbsView()
    }
    
    @objc private func fatsViewTapped() {
        print("🎯 Fats card tapped")
        animateTap(fatsView)
        delegate?.didTapFatsView()
    }
    
    private func animateTap(_ view: UIView) {
        // Quick spring animation
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
        // Reset accumulators
        calories = 0
        fats = 0
        protein = 0
        carbs = 0
        
        // Simply sum today's meals from Core Data — no mutation needed
        for food in FoodLogDataStore.todaysMeal {
            calories += food.calories
            fats += food.fatsContent
            protein += food.proteinContent
            carbs += food.carbsContent
        }
        
        calToBeConsumed.text = "/2000kcal"
        caloriesConsumed.text = "\(Int(calories))"
        fatsGm.text = "\(Int(fats))"
        proteinGm.text = "\(Int(protein))"
        carbsGm.text = "\(Int(carbs))"
        
        fatsProgress.progress = Float(fats / 60)
        carbsProgress.progress = Float(carbs / 180)
        proteinProgress.progress = Float(protein / 90)
        
        progressCircle.setProgress(to: Float(calories) / 2000)
    }

    
    func updateValues(_ food: Food){
        calories += food.calories
        fats += food.fatsContent
        protein += food.proteinContent
        carbs += food.carbsContent
        
        caloriesConsumed.text = "\(Int(calories))"
        fatsGm.text = "\(Int(fats))"
        proteinGm.text = "\(Int(protein))"
        carbsGm.text = "\(Int(carbs))"
        
        fatsProgress.progress = Float(fats/60)
        carbsProgress.progress = Float(carbs/180)
        proteinProgress.progress = Float(protein/90)
        
        progressCircle.setProgress(to: Float(calories)/2000)
    }
}

extension NutritionHeader {
    func subtractValues(_ food: Food) {
        // Subtract from local state variables
        calories -= food.calories
        fats -= food.fatsContent
        protein -= food.proteinContent
        carbs -= food.carbsContent
        
        // Ensure values don't go below 0
        calories = max(0, calories)
        fats = max(0, fats)
        protein = max(0, protein)
        carbs = max(0, carbs)
        
        // Update labels
        caloriesConsumed.text = "\(Int(calories))"
        fatsGm.text = "\(Int(fats))"
        proteinGm.text = "\(Int(protein))"
        carbsGm.text = "\(Int(carbs))"
        
        // Update progress bars
        fatsProgress.progress = Float(fats/60)
        carbsProgress.progress = Float(carbs/180)
        proteinProgress.progress = Float(protein/90)
        
        // Update circular progress
        progressCircle.setProgress(to: Float(calories)/2000)
    }
}
