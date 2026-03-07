//
//  AddConfirmViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 10/01/26.
//

import UIKit

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
        
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Confirm Meal"
        
        print("DEBUG: Loaded with \(ingredients.count) ingredients")
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        foodName.font = .systemFont(ofSize: 22, weight: .bold)
        foodName.numberOfLines = 0
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
        containerView.backgroundColor = .clear
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        stepper.value = 1.0
        servingMultiplier = 1.0
        
        stepper.tintColor = .label
        stepper.layer.cornerRadius = 10
        stepper.clipsToBounds = true
        
        stepper.addTarget(self, action: #selector(servingStepperChanged(_:)), for: .valueChanged)
    }
    
    @objc private func servingStepperChanged(_ sender: UIStepper) {
        servingMultiplier = sender.value
        
        let servingText: String
        if servingMultiplier == 1.0 {
            servingText = "1 serving"
        } else {
            servingText = String(format: "%.1f servings", servingMultiplier)
        }
        servingNumberLabel.text = servingText
        
        updateWeightLabel()
        updateHeaderWithCurrentIngredients()
    }
    
    private func setupServingLabel() {
        guard let label = servingNumberLabel else { return }
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .label
        label.text = "1 serving"
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
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .label
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.systemGray3.cgColor
        
        updateWeightLabel()
    }
    
    private func updateWeightLabel() {
        guard let label = FoodWeightLabel else { return }
        
        var totalWeight: Double = 0
        for ingredient in ingredients {
            totalWeight += ingredient.quantity
        }
        totalWeight *= servingMultiplier
        
        let unit = foodItem?.unit ?? "g"
        label.text = String(format: "Total\n%.0f %@", totalWeight, unit)
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
        print("DEBUG: Delegate is: \(delegate != nil ? "set" : "nil")")
        
        // ← KEY FIX: call delegate first (saves to FoodLogDataSource via DietVC)
        delegate?.didConfirmMeal(finalFood)
        
        // ← KEY FIX: correct dismiss/pop logic for both sheet-presented and pushed scenarios
        if presentingViewController != nil {
            // We're inside a presented sheet (e.g. from Describe/table row flow)
            dismiss(animated: true) { [weak self] in
                // Also dismiss the parent sheet (AddMealVC sheet or DescribeFoodVC sheet)
                self?.presentingViewController?.dismiss(animated: false)
            }
        } else {
            // We're pushed on a navigation stack — pop back to root (DietVC)
            navigationController?.popToRootViewController(animated: true)
        }
        
        print("Meal confirmed and dismissing")
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
        
        if let food = food {
            return Food(
                id: UUID(),
                name: food.name,
                image: food.image,
                timeStamp: Date(),
                servingSize: food.servingSize * servingMultiplier,
                weight: food.weight,
                isSelected: false,
                isLogged: true,
                desc: food.desc,
                proteinContent: totalProtein,
                carbsContent: totalCarbs,
                fatsContent: totalFat,
                customCalories: nil,
                tags: food.tags,
                ingredients: ingredients
            )
        } else if let foodItem = foodItem {
            return Food(
                id: UUID(),
                name: foodItem.name,
                image: foodItem.image,
                timeStamp: Date(),
                servingSize: foodItem.servingSize * servingMultiplier,
                weight: nil,
                isSelected: false,
                isLogged: true,
                desc: foodItem.desc,
                proteinContent: totalProtein,
                carbsContent: totalCarbs,
                fatsContent: totalFat,
                customCalories: nil,
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if ingredients.isEmpty {
            cell.textLabel?.text = "No ingredients available"
            cell.textLabel?.textColor = .secondaryLabel
            cell.detailTextLabel?.text = nil
            cell.selectionStyle = .none
        } else {
            let ingredient = ingredients[indexPath.row]
            cell.textLabel?.text = ingredient.name
            cell.textLabel?.textColor = .label
            cell.detailTextLabel?.text = String(
                format: "%.0f%@", ingredient.quantity, ingredient.unit
            )
            cell.detailTextLabel?.textColor = .secondaryLabel
            cell.selectionStyle = .default
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Edit Ingredients"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
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
            let ingredient = ingredients[indexPath.row]
            showDeleteConfirmation(for: ingredient, at: indexPath)
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard !ingredients.isEmpty else { return nil }
        
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
