//
//  AddConfirmViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 10/01/26.
//

import UIKit
import FoundationModels

protocol AddDescribedMealDelegate: AnyObject {
    func didConfirmMeal(_ food: Food)
}

class AddDescribedMealViewController: UIViewController {
    
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var FoodWeightLabel: UILabel!
    @IBOutlet weak var servingNumberLabel: UILabel!
    @IBOutlet weak var servingStepper: UIStepper!
    @IBOutlet weak var foodWeightView: UIView!
    
    @IBOutlet weak var recommendationLabel: UILabel!
    @IBOutlet weak var recommendationView: UIView!
    var foodItem: FoodItem!
    var food: Food?
    weak var delegate: AddDescribedMealDelegate?
    
    private var servingMultiplier: Double = 1.0
    private var headerView: FoodLogIngredientHeader!
    private var ingredients: [Ingredient] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard foodItem != nil || food != nil else {
            print("ERROR: Both foodItem and food are nil!")
            dismiss(animated: true)
            return
        }
        
        loadIngredients()
        setupUI()
        setupTableView()
        setupHeader()
        setupStepper()
        setupServingLabel()
        setupWeightLabel()
        setupRecommendationView()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Confirm Meal"
        
        // Kick off AI insight asynchronously
        Task { await fetchMealInsight() }
        
        print("DEBUG: Loaded with \(ingredients.count) ingredients")
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        foodName.font = .systemFont(ofSize: 22, weight: .bold)
        foodName.numberOfLines = 0
    }
    
    // MARK: - Recommendation View
    
    private func setupRecommendationView() {
        guard let card = recommendationView, let label = recommendationLabel else { return }
        
        card.layer.cornerRadius = 12
        card.clipsToBounds = true
        
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.35, green: 0.25, blue: 0.05, alpha: 1)
        label.numberOfLines = 0
        label.text = "Analysing your meal…"
        label.textColor = .secondaryLabel
    }
    
    private func fetchMealInsight() async {
        // Check availability — SystemLanguageModel.default.availability can return .available
        // on simulators or devices where the model isn't downloaded, so we also do a quick
        // trial probe to catch ModelManagerError Code=1026 before doing the real ca"
        guard case .available = SystemLanguageModel.default.availability else {
            await MainActor.run { showFallbackInsight() }
            return
        }
        
        // Compute macros
        var totalProtein = 0.0, totalCarbs = 0.0, totalFat = 0.0, totalFibre = 0.0
        for ingredient in ingredients {
            let factor = ingredient.quantity / 100.0
            totalProtein += ingredient.protein * factor
            totalCarbs   += ingredient.carbs   * factor
            totalFat     += ingredient.fats    * factor
            totalFibre   += ingredient.fibre   * factor
        }
        totalProtein *= servingMultiplier
        totalCarbs   *= servingMultiplier
        totalFat     *= servingMultiplier
        totalFibre   *= servingMultiplier
        let calories = Int((totalProtein * 4) + (totalCarbs * 4) + (totalFat * 9))
        
        let mealName = foodItem?.name ?? food?.name ?? "this meal"
        let ingredientNames = ingredients.prefix(4).map { $0.name }.joined(separator: ", ")
        
        // Collect verified impact tags from all ingredients
        let allTags = Set(ingredients.flatMap { $0.tags }).filter { $0 != .none }
        let tagDescriptions: [String: String] = [
            "pcosFriendly": "PCOS-friendly",
            "pcosTrigger": "PCOS trigger",
            "highProtein": "high protein",
            "lowProtein": "low protein",
            "highFibre": "high fibre",
            "lowFibre": "low fibre",
            "healthyFats": "contains healthy fats",
            "unhealthyFats": "contains unhealthy fats",
            "highGlycemic": "high glycaemic index",
            "mediumGlycemic": "medium glycaemic index",
            "lowGlycemic": "low glycaemic index",
            "insulinSpiking": "insulin spiking",
            "insulinBalancing": "insulin balancing",
            "highInsulinLoad": "high insulin load",
            "lowInsulinLoad": "low insulin load",
            "antiInflammatory": "anti-inflammatory",
            "proInflammatory": "pro-inflammatory",
            "highCarb": "high carb",
            "lowCarb": "low carb",
            "bloatingTrigger": "may cause bloating",
            "bloatingReducer": "reduces bloating",
            "gutFriendly": "gut-friendly",
            "gasForming": "gas-forming",
            "moodBoost": "supports mood",
            "energyBoost": "boosts energy",
            "ultraProcessed": "ultra-processed",
            "processed": "processed",
            "wholeFood": "whole food",
            "estrogenBoosting": "estrogen boosting",
            "androgenBoosting": "androgen boosting",
            "androgenLowering": "androgen lowering",
            "sugary": "sugary",
            "noAddedSugar": "no added sugar",
            "crampTrigger": "may trigger cramps",
            "crampReducer": "reduces cramps"
        ]
        let tagLabels = allTags
            .compactMap { tagDescriptions[$0.rawValue] }
            .sorted()
            .joined(separator: ", ")
        let tagLine = tagLabels.isEmpty ? "No specific health tags available." : "Verified tags: \(tagLabels)."
        
        // Use a fresh dedicated session — never reuse the shared chat session
        let instructions = """
        You are a nutrition assistant. Reply in exactly 1-2 short sentences — no lists, no headings. \
        Base your assessment ONLY on the verified tags provided. \
        Do not use your own knowledge about the food name and output shouldn't have based on impact tags wording as we are not showing any impact tag in UI. \
        Be warm and direct. Stop after 2 sentences.
        """
        
        let prompt = """
        Meal: \(mealName) (\(calories) kcal) — Protein \(Int(totalProtein))g, Carbs \(Int(totalCarbs))g, Fat \(Int(totalFat))g
        Ingredients: \(ingredientNames)
        \(tagLine)
        
        Based only on the verified tags above, give 1-2 sentences of feedback. Suggest one improvement if the tags indicate an issue.
        """

        
        do {
            let session = LanguageModelSession(instructions: instructions)
            let response = try await session.respond(to: prompt)
            let insight = response.content
            
            await MainActor.run {
                guard let label = recommendationLabel, let card = recommendationView else { return }
                label.text = insight
                label.textColor = UIColor(red: 0.35, green: 0.25, blue: 0.05, alpha: 1)
                card.alpha = 0
                UIView.animate(withDuration: 0.35) { card.alpha = 1 }
            }
        } catch {
            print("DEBUG: AI meal insight failed — \(error)")
            await MainActor.run { showFallbackInsight() }
        }
    }

    
    /// Builds a 1-2 sentence insight purely from macros and ingredient tags — no AI call.
    private func showFallbackInsight() {
        guard let label = recommendationLabel, let card = recommendationView else { return }
        
        // Aggregate tags across all ingredients
        let allTags = Set(ingredients.flatMap { $0.tags })
        
        // Compute macros
        var totalProtein = 0.0, totalCarbs = 0.0, totalFat = 0.0, totalFibre = 0.0
        for ingredient in ingredients {
            let factor = ingredient.quantity / 100.0
            totalProtein += ingredient.protein * factor
            totalCarbs   += ingredient.carbs   * factor
            totalFat     += ingredient.fats    * factor
            totalFibre   += ingredient.fibre   * factor
        }
        totalProtein *= servingMultiplier
        totalCarbs   *= servingMultiplier
        totalFat     *= servingMultiplier
        totalFibre   *= servingMultiplier
        
        var lines: [String] = []
        
        // Positive tags — mention what's good first
        if allTags.contains(.pcosFriendly) {
            lines.append("This meal has PCOS-friendly ingredients.")
        }
        if allTags.contains(.highProtein) || totalProtein >= 15 {
            lines.append("Good protein content (\(Int(totalProtein))g) — supports hormone balance.")
        }
        if allTags.contains(.antiInflammatory) {
            lines.append("Contains anti-inflammatory ingredients — great for PCOS.")
        }
        if allTags.contains(.lowGlycemic) || allTags.contains(.insulinBalancing) {
            lines.append("Low-GI choice — helps keep insulin stable.")
        }
        if allTags.contains(.highFibre) || totalFibre >= 5 {
            lines.append("High fibre — supports gut health and steady energy.")
        }
        
        // Caution tags
        if allTags.contains(.highGlycemic) || allTags.contains(.insulinSpiking) {
            lines.append("This meal may spike insulin — pair it with protein or a handful of nuts to slow absorption.")
        }
        if allTags.contains(.pcosTrigger) {
            lines.append("Some ingredients here may trigger PCOS symptoms — enjoy in moderation.")
        }
        if allTags.contains(.ultraProcessed) {
            lines.append("This is heavily processed — a whole-food swap would be a great upgrade when possible.")
        }
        if allTags.contains(.proInflammatory) {
            lines.append("Contains pro-inflammatory ingredients — balancing it with leafy greens helps.")
        }
        if allTags.contains(.bloatingTrigger) {
            lines.append("May cause bloating — a small serving of dahi (yogurt) alongside can help.")
        }
        
        // Pure macro fallback if no tags triggered anything
        if lines.isEmpty {
            if totalProtein < 10 {
                lines.append("This meal is low in protein — consider adding dal, paneer, or eggs to support hormone balance.")
            } else if totalCarbs > 60 {
                lines.append("High in carbs — pairing with a protein source like dahi or sprouts will keep your insulin steadier.")
            } else {
                lines.append("This meal looks balanced overall — enjoy it mindfully as part of your day!")
            }
        }
        
        label.text = lines.prefix(2).joined(separator: " ")
        label.textColor = UIColor(red: 0.35, green: 0.25, blue: 0.05, alpha: 1)
        card.isHidden = false
        card.alpha = 0
        UIView.animate(withDuration: 0.35) { card.alpha = 1 }
    }

    
    private func loadIngredients() {
        if let food = food {
            ingredients = food.ingredients ?? []
            foodName.text = food.name
        } else if let foodItem = foodItem {
            ingredients = foodItem.ingredients
            foodName.text = foodItem.name
        }
        print("DEBUG: Loaded \(ingredients.count) ingredients")
    }
    
    private func setupHeader() {
        guard let containerView = foodWeightView else {
            print("ERROR: foodWeightView is nil!")
            return
        }
        
        containerView.subviews.forEach { $0.removeFromSuperview() }
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        
        headerView = FoodLogIngredientHeader.loadFromNib()
        containerView.addSubview(headerView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        updateHeaderWithCurrentIngredients()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        // Removed default cell registration to allow manual .value1 style instantiation
        tableView.layer.cornerRadius = 12
        tableView.clipsToBounds = true
    }
    
    private func setupStepper() {
        guard let stepper = servingStepper else {
            print("Error: servingStepper outlet is not connected!")
            return
        }
        
        stepper.minimumValue = 0.5
        stepper.maximumValue = 10.0
        stepper.stepValue = 0.5
        
        // Initialize from existing data if available
        stepper.value = 1.0
        servingMultiplier = 1.0
        
        stepper.tintColor = .label
        stepper.layer.cornerRadius = 10
        stepper.clipsToBounds = true
        
        stepper.addTarget(self, action: #selector(servingStepperChanged(_:)), for: .valueChanged)
    }
    
    @objc private func servingStepperChanged(_ sender: UIStepper) {
        servingMultiplier = sender.value
        updateServingLabel()
        updateWeightLabel()
        updateHeaderWithCurrentIngredients()
    }
    
    private func updateServingLabel() {
        guard let label = servingNumberLabel else { return }
        if servingMultiplier == 1.0 {
            label.text = "1 serving"
        } else {
            label.text = servingMultiplier.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f servings", servingMultiplier) : String(format: "%.1f servings", servingMultiplier)
        }
    }
    
    private func setupServingLabel() {
        guard let label = servingNumberLabel else { return }
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        updateServingLabel()
    }
    
    private func setupWeightLabel() {
        guard let label = FoodWeightLabel else {
            print("Error: FoodWeightLabel outlet is not connected!")
            return
        }
        
        label.backgroundColor = .systemGray5
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .label
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.systemGray3.cgColor
        
        updateWeightLabel()
    }
    
    private func updateWeightLabel() {
        guard let label = FoodWeightLabel else { return }
        
        var totalWeight: Double = 0
        if let originalWeight = food?.weight, originalWeight > 0 {
            totalWeight = originalWeight * servingMultiplier
        } else {
            totalWeight = ingredients.reduce(0.0) { $0 + $1.quantity } * servingMultiplier
        }
        
        label.text = String(format: "  Weight Total  %.0f g  ", totalWeight)
    }
    
    // MARK: - Update Header
    
    private func updateHeaderWithCurrentIngredients() {
        guard !ingredients.isEmpty else {
            print("DEBUG: No ingredients to calculate macros")
            return
        }
        
        var totalProtein: Double = 0
        var totalCarbs: Double = 0
        var totalFat: Double = 0
        
        for ingredient in ingredients {
            let factor = ingredient.quantity / 100.0
            totalProtein += ingredient.protein * factor
            totalCarbs += ingredient.carbs * factor
            totalFat += ingredient.fats * factor
        }
        
        totalProtein *= servingMultiplier
        totalCarbs *= servingMultiplier
        totalFat *= servingMultiplier
        
        print("DEBUG: Calculated macros - P: \(totalProtein), C: \(totalCarbs), F: \(totalFat)")
        
        let tempFoodItem = FoodItem(
            id: foodItem?.id ?? 0,
            name: foodItem?.name ?? food?.name ?? "Described Meal",
            calories: Int((totalProtein * 4) + (totalCarbs * 4) + (totalFat * 9)),
            image: (foodItem?.image ?? food?.image) ?? "dietPlaceholder",
            servingSize: foodItem?.servingSize ?? food?.servingSize ?? 1,
            protein: totalProtein,
            carbs: totalCarbs,
            fat: totalFat,
            isSelected: false,
            desc: foodItem?.desc ?? food?.desc ?? "",
            ingredients: ingredients
        )
        
        headerView.configure(with: tempFoodItem)
        print("DEBUG: Header updated with calculated macros")
    }
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
            guard let finalFood = createFinalFoodObject() else {
                print("ERROR: Could not create final food object")
                showAlert(message: "Failed to create meal. Please try again.")
                return
            }
            
            print("DEBUG: Final food created: \(finalFood.name)")
            print("DEBUG: Protein: \(finalFood.proteinContent)g, Carbs: \(finalFood.carbsContent)g, Fats: \(finalFood.fatsContent)g")
            print("DEBUG: Delegate is: \(delegate != nil ? "set" : "nil")")
            
            // Call delegate to save the food
            delegate?.didConfirmMeal(finalFood)
            print("DEBUG: Delegate called - meal should be saved now")
            
            // Dismiss logic - handle both navigation and presentation cases
            if let nav = navigationController {
                // We're in a navigation stack
                if let presentingVC = nav.presentingViewController {
                    // The nav controller is presented as a sheet - dismiss it
                    presentingVC.dismiss(animated: true) {
                        print("DEBUG: Navigation controller dismissed")
                    }
                } else {
                    // We're pushed - pop to root
                    nav.popToRootViewController(animated: true)
                    print("DEBUG: Popped to root")
                }
            } else if presentingViewController != nil {
                // We're directly presented - dismiss
                dismiss(animated: true) {
                    print("DEBUG: View controller dismissed")
                }
            }
            
            print("DEBUG: Save button completed")
        }
    private func createFinalFoodObject() -> Food? {
        var totalProtein: Double = 0
        var totalCarbs: Double = 0
        var totalFat: Double = 0
        
        for ingredient in ingredients {
            let factor = ingredient.quantity / 100.0
            totalProtein += ingredient.protein * factor
            totalCarbs += ingredient.carbs * factor
            totalFat += ingredient.fats * factor
        }
        
        totalProtein *= servingMultiplier
        totalCarbs *= servingMultiplier
        totalFat *= servingMultiplier
        
        // Compute calories explicitly so Food.calories uses customCalories branch
        // (avoids the ingredient-based branch which previously used 100g macros without quantity scaling)
        let totalCalories = (totalProtein * 4) + (totalCarbs * 4) + (totalFat * 9)
        
        if let food = food {
            return Food(
                id: UUID(),
                name: food.name,
                image: food.image,
                timeStamp: Date(),
                servingSize: food.servingSize * servingMultiplier,
                weight: food.weight != nil ? food.weight! * servingMultiplier : nil,
                desc: food.desc,
                proteinContent: totalProtein,
                carbsContent: totalCarbs,
                fatsContent: totalFat,
                customCalories: totalCalories,
                tags: food.tags,
                ingredients: ingredients
            )
        } else if let foodItem = foodItem {
            let totalWeight = ingredients.reduce(0.0) { $0 + $1.quantity } * servingMultiplier
            return Food(
                id: UUID(),
                name: foodItem.name,
                image: foodItem.image,
                timeStamp: Date(),
                servingSize: foodItem.servingSize * servingMultiplier,
                weight: totalWeight,
                desc: foodItem.desc,
                proteinContent: totalProtein,
                carbsContent: totalCarbs,
                fatsContent: totalFat,
                customCalories: totalCalories,
                tags: [],
                ingredients: ingredients
            )
        }
        
        return nil
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Notice",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AddDescribedMealViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(ingredients.count, 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        }
        let activeCell = cell!
        
        if ingredients.isEmpty {
            activeCell.textLabel?.text = "No ingredients available"
            activeCell.textLabel?.textColor = .secondaryLabel
            activeCell.detailTextLabel?.text = nil
            activeCell.selectionStyle = .none
        } else {
            let ingredient = ingredients[indexPath.row]
            activeCell.textLabel?.text = ingredient.name
            activeCell.textLabel?.textColor = .label
            activeCell.detailTextLabel?.text = nil
            activeCell.selectionStyle = .default
        }
        
        return activeCell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Edit Ingredients"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !ingredients.isEmpty {
            let ingredient = ingredients[indexPath.row]
            showEditIngredient(ingredient, at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !ingredients.isEmpty
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            guard ingredients.count > 1 else {
                showAlert(message: "Cannot delete the only ingredient in this meal.")
                return
            }
            let ingredient = ingredients[indexPath.row]
            showDeleteConfirmation(for: ingredient, at: indexPath)
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard !ingredients.isEmpty else { return nil }
        
        // Don't allow swipe-delete if only one ingredient remains
        guard ingredients.count > 1 else {
            let infoAction = UIContextualAction(
                style: .normal,
                title: "Can't Delete"
            ) { [weak self] (_, _, completionHandler) in
                self?.showAlert(message: "Cannot delete the only ingredient in this meal.")
                completionHandler(true)
            }
            infoAction.backgroundColor = .systemGray
            let config = UISwipeActionsConfiguration(actions: [infoAction])
            config.performsFirstActionWithFullSwipe = false
            return config
        }
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { [weak self] (_, _, completionHandler) in
            guard let self = self else {
                completionHandler(false)
                return
            }
            let ingredient = self.ingredients[indexPath.row]
            self.showDeleteConfirmation(for: ingredient, at: indexPath)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    // MARK: - Delete Ingredient
    
    private func showDeleteConfirmation(for ingredient: Ingredient, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Delete Ingredient",
            message: "Remove '\(ingredient.name)' from this meal?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteIngredient(at: indexPath)
        })
        
        present(alert, animated: true)
    }
    
    private func deleteIngredient(at indexPath: IndexPath) {
        let ingredient = ingredients[indexPath.row]
        print("DEBUG: Deleting ingredient: \(ingredient.name)")
        
        ingredients.remove(at: indexPath.row)
        
        if ingredients.isEmpty {
            tableView.reloadData()
        } else {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        updateHeaderWithCurrentIngredients()
        updateWeightLabel()
        
        print("DEBUG: \(ingredients.count) ingredients remaining")
    }
    
    // MARK: - Edit Ingredient
    
    private func showEditIngredient(_ ingredient: Ingredient, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Edit Ingredient",
            message: "Edit quantity for \(ingredient.name)",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Quantity (grams)"
            textField.keyboardType = .decimalPad
            textField.text = "\(Int(ingredient.quantity))"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Unit"
            textField.text = ingredient.unit
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let quantityText = alert.textFields?[0].text ?? "100"
            let unitText = alert.textFields?[1].text ?? "g"
            
            var updatedIngredient = ingredient
            updatedIngredient.quantity = Double(quantityText) ?? 100
            updatedIngredient.unit = unitText.isEmpty ? "g" : unitText
            
            self.ingredients[indexPath.row] = updatedIngredient
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            
            self.updateHeaderWithCurrentIngredients()
            self.updateWeightLabel()
            
            print("DEBUG: Updated ingredient: \(updatedIngredient.name) - \(updatedIngredient.quantity)\(updatedIngredient.unit)")
        })
        
        present(alert, animated: true)
    }
}
