//
//  foodLogIngredientViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class FoodLogIngredientViewController: UIViewController {
    
    @IBOutlet weak var servingStepper: UIStepper!
    @IBOutlet weak var servingNumberLabel: UILabel!
    @IBOutlet weak var foodweightView: UIView!
    @IBOutlet weak var FoodWeightLabel: UILabel!
    @IBOutlet weak var horizontalStackView: UIStackView!
    
    @IBOutlet weak var tableView: UITableView!
    
    // Header view
        private var headerView: FoodLogIngredientHeader!
        let defaultIngredient = FoodLogDataStore.ingredient
        // Food data
        var food: Food!
        private var servingMultiplier: Double = 1.0
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            print("DEBUG: viewDidLoad started")
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(FoodIngredientListTableViewCell.nib(), forCellReuseIdentifier: FoodIngredientListTableViewCell.identifier)

            // Validate food data exists
            guard food != nil else {
                print("Error: No food data provided")
                navigationController?.popViewController(animated: true)
                return
            }
            
            print("DEBUG: Food data exists - \(food.name)")
            
            // Set navigation title
            title = food?.name ?? "Food Details"
            
            // Disable large title to prevent it from pushing content down
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.largeTitleDisplayMode = .never
            
            // Setup all UI elements
            setupHeader()
            setupStepper()
            setupServingLabel()
            setupWeightLabel()
            updateServingDisplay()
            
            print("DEBUG: viewDidLoad completed successfully")
        }
        
        //Header setuo
        private func setupHeader() {

            
            guard let food = food else {
                print("No food data available")
                return
            }
            
            guard let containerView = foodweightView else {
                return
            }
            
            // Clear container
            containerView.subviews.forEach { $0.removeFromSuperview() }
            
            // Set container background
            containerView.backgroundColor = .clear
            containerView.layer.cornerRadius = 16
            containerView.clipsToBounds = true
            
            // Load header from nib
            headerView = FoodLogIngredientHeader.loadFromNib()
            
            // Add header view to container
            containerView.addSubview(headerView)
            
            // Setup constraints
            headerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
                headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                headerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            
            // Configure with food data
            headerView.configure(with: food)
            
            print("DEBUG: setupHeader - Complete")
        }
        
        // MARK: - Setup Stepper
        private func setupStepper() {
            guard let stepper = servingStepper else {
                print("Error: servingStepper outlet is not connected!")
                return
            }
            
            stepper.minimumValue = 0.5
            stepper.maximumValue = 10.0
            stepper.stepValue = 0.5
            stepper.value = 1.0
            servingMultiplier = 1.0
            
            // Style the stepper to match design
            stepper.tintColor = .label
//            stepper.backgroundColor = .systemGray5
            stepper.layer.cornerRadius = 10
            stepper.clipsToBounds = true
        }
        
        // MARK: - Setup Serving Label
        private func setupServingLabel() {
            guard let label = servingNumberLabel else { return }
            
            label.font = .systemFont(ofSize: 18, weight: .medium)
            label.textColor = .label
        }
        
        // MARK: - Setup Weight Label
        private func setupWeightLabel() {
            guard let label = FoodWeightLabel else {
                print("Error: FoodWeightLabel outlet is not connected!")
                return
            }
            
            label.backgroundColor = .systemGray5
            label.layer.cornerRadius = 10
            label.clipsToBounds = true
            label.textAlignment = .center
            label.numberOfLines = 2
            label.font = .systemFont(ofSize: 13, weight: .medium)
            label.textColor = .label
            
            // Debug - make it visible with border (remove in production)
            label.layer.borderWidth = 1
            label.layer.borderColor = UIColor.systemGray3.cgColor
            
            print("DEBUG: FoodWeightLabel configured")
        }
        
        // MARK: - Actions
        @IBAction func servingStepperChanged(_ sender: UIStepper) {
            servingMultiplier = sender.value
            updateServingDisplay()
            updateMacros()
            print(servingMultiplier)
        }
        
    @IBAction func saveButton(_ sender: Any) {
        guard var updatedFood = food else { return }
                    
        // Apply the serving multiplier to all values
        updatedFood.proteinContent = food.proteinContent * servingMultiplier
        updatedFood.carbsContent = food.carbsContent * servingMultiplier
        updatedFood.fatsContent = food.fatsContent * servingMultiplier
        updatedFood.servingSize = food.servingSize * servingMultiplier
                    
        if let weight = food.weight {
                updatedFood.weight = weight * servingMultiplier
            }
        if let customCalories = food.customCalories {
                updatedFood.customCalories = customCalories * servingMultiplier
            }
        if let ingredients = food.ingredients {
                updatedFood.ingredients = ingredients.map { ingredient in
                var newIngredient = ingredient
                newIngredient.quantity = ingredient.quantity * servingMultiplier
                return newIngredient
                }
            }
                    // Save to Core Data
        FoodLogDataStore.updateFood(updatedFood)
        navigationController?.popViewController(animated: true)
    }
    // MARK: - Update Display
        private func updateServingDisplay() {
            // Update serving label
            let servingText: String
            if servingMultiplier == 1.0 {
                servingText = "1 serving"
            } else if servingMultiplier.truncatingRemainder(dividingBy: 1) == 0 {
                // Whole number
                servingText = "\(Int(servingMultiplier)) servings"
            } else {
                // Decimal
                servingText = String(format: "%.1f servings", servingMultiplier)
            }
            
            servingNumberLabel?.text = servingText
            
            // Update weight label - check weight property, fallback to quantity
            guard let food = food else { return }
            
            // Priority: weight > quantity
            let weightText: String
            if let baseWeight = food.weight {
                // Use weight if available
                let totalWeight = Int(baseWeight * servingMultiplier)
                weightText = "Weight total\n\(totalWeight) g"
            } else if food.servingSize > 0 {
                // Fallback to quantity
                let totalWeight = Int(food.servingSize * servingMultiplier)
                weightText = "Weight total\n\(totalWeight) g"
            } else {
                // No data available
                weightText = "Weight total\nNo data"
            }
            
            // Create attributed string for better formatting
            let attributedString = NSMutableAttributedString(string: weightText)
            
            // Style "Weight total" (smaller, secondary)
            if let range = weightText.range(of: "Weight total") {
                let nsRange = NSRange(range, in: weightText)
                attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 11, weight: .regular), range: nsRange)
                attributedString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: nsRange)
            }
            
            // Style weight value (larger, bold) - only if not "No data"
            if !weightText.contains("No data") {
                // Extract the number and "g" from the string
                let components = weightText.components(separatedBy: "\n")
                if components.count > 1 {
                    let valueText = components[1]
                    if let range = weightText.range(of: valueText) {
                        let nsRange = NSRange(range, in: weightText)
                        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: nsRange)
                        attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: nsRange)
                    }
                }
            } else {
                // Style "No data" in red
                if let range = weightText.range(of: "No data") {
                    let nsRange = NSRange(range, in: weightText)
                    attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 13, weight: .medium), range: nsRange)
                    attributedString.addAttribute(.foregroundColor, value: UIColor.systemRed, range: nsRange)
                }
            }
            
            FoodWeightLabel?.attributedText = attributedString
            
            print("DEBUG: Weight label updated with text: \(weightText)")
        }
        
        private func updateMacros() {
            guard let food = food else { return }
            
            // Create a temporary food object with multiplied values
            var multipliedFood = food
            multipliedFood.proteinContent = food.proteinContent * servingMultiplier
            multipliedFood.carbsContent = food.carbsContent * servingMultiplier
            multipliedFood.fatsContent = food.fatsContent * servingMultiplier
            
            // Update quantity
            multipliedFood.servingSize = food.servingSize * servingMultiplier
            
            // Update weight if available
            if let weight = food.weight {
                multipliedFood.weight = weight * servingMultiplier
            }
            
            // Update custom calories if set, otherwise it will auto-calculate
            if let customCalories = food.customCalories {
                multipliedFood.customCalories = customCalories * servingMultiplier
            }
            
            // Update ingredients if available
            if let ingredients = food.ingredients {
                multipliedFood.ingredients = ingredients.map { ingredient in
                    var newIngredient = ingredient
                    newIngredient.quantity = ingredient.quantity * servingMultiplier
                    return newIngredient
                }
            }
            
            headerView.configure(with: multipliedFood)
        }
        
        // MARK: - Static Presentation
        static func present(from viewController: UIViewController, with food: Food) {
            guard let storyboard = viewController.storyboard ?? UIStoryboard(name: "Main", bundle: nil) as UIStoryboard? else {
                print("Error: Could not load storyboard")
                return
            }
            
            guard let ingredientVC = storyboard.instantiateViewController(withIdentifier: "foodLogIngredientViewController") as? FoodLogIngredientViewController else {
                print("Error: Could not instantiate foodLogIngredientViewController")
                return
            }
            
            ingredientVC.food = food
            
            if let navController = viewController.navigationController {
                navController.pushViewController(ingredientVC, animated: true)
            } else {
                print("Error: No navigation controller found")
            }
        }
    }

extension FoodLogIngredientViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return food.ingredients?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if food.ingredients?.isEmpty == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: FoodIngredientListTableViewCell.identifier, for: indexPath) as! FoodIngredientListTableViewCell
            cell.IngredientNameLabel.text = food.name
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: FoodIngredientListTableViewCell.identifier, for: indexPath) as! FoodIngredientListTableViewCell
            
            let ingredient = food.ingredients?[indexPath.row] ?? defaultIngredient
            cell.configureCell(with: ingredient)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Ingredients"
    }
    
    
}
