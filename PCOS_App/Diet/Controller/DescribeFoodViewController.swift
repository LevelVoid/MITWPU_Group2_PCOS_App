//
//  DescribeFoodViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 02/12/25.
//

import UIKit
import NaturalLanguage

class DescribeFoodViewController: UIViewController {
    
    
    @IBOutlet weak var dietInfoLabel: UILabel!
    @IBOutlet weak var describeYourMealText: UITextField!
    
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    weak var dietDelegate: AddDescribedMealDelegate?
        
    private var loadingView: UIView?
    private var activityIndicator: UIActivityIndicatorView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add with AI"
        view.backgroundColor = .systemBackground
        setupUI()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func done(_ sender: Any) {
        guard let text = describeYourMealText.text,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert(message: "Please describe your meal")
            return
        }
        
        showLoadingIndicator()
        analyzeMeal(description: text.lowercased())
    }
    
    // MARK: - Pipeline
        private func analyzeMeal(description: String) {
            let foodTerms = extractFoodTokens(from: description)
            
            guard !foodTerms.isEmpty else {
                hideLoadingIndicator()
                showAlert(message: "Could not identify food items. Try describing specific foods like 'roti', 'rice', 'dal'.")
                return
            }
            
            print("DEBUG: Extracted food terms: \(foodTerms)")
            
            fetchNutrition(for: foodTerms) { [weak self] foodItem in
                DispatchQueue.main.async {
                    self?.hideLoadingIndicator()
                    
                    guard !foodItem.ingredients.isEmpty else {
                        self?.showAlert(message: "Could not find nutrition information. Please try again with common food names.")
                        return
                    }
                    
                    print("DEBUG: Successfully built FoodItem with \(foodItem.ingredients.count) ingredients")
                    self?.navigateToAdd(foodItem)
                }
            }
        }
        
        // MARK: - NLP
        private func extractFoodTokens(from text: String) -> [String] {
            let tagger = NLTagger(tagSchemes: [.lexicalClass])
            tagger.string = text
            
            var foods: [String] = []
            
            tagger.enumerateTags(
                in: text.startIndex..<text.endIndex,
                unit: .word,
                scheme: .lexicalClass,
                options: [.omitWhitespace, .omitPunctuation]
            ) { tag, range in
                let token = String(text[range])
                if tag == .noun && token.count > 2 {
                    foods.append(token.lowercased())
                }
                return true
            }
            
            // Remove duplicates while preserving order
            var seen = Set<String>()
            return foods.filter { seen.insert($0).inserted }
        }
        
        // MARK: - Nutrition Fetch
        private func fetchNutrition(for foods: [String], completion: @escaping (FoodItem) -> Void) {
            let group = DispatchGroup()
            var ingredients: [Ingredient] = []
            
            for food in foods {
                group.enter()
                fetchFromOpenFoodFacts(food: food) { ingredient in
                    if let ingredient = ingredient {
                        ingredients.append(ingredient)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                print("DEBUG: Total ingredients fetched: \(ingredients.count)")
                for ingredient in ingredients {
                    print("  - \(ingredient.name): \(ingredient.quantity)g, P:\(ingredient.protein)g, C:\(ingredient.carbs)g, F:\(ingredient.fats)g")
                }
                completion(self.buildFoodItem(from: ingredients))
            }
        }
        
        // MARK: - OpenFoodFacts API
        private func fetchFromOpenFoodFacts(food: String, completion: @escaping (Ingredient?) -> Void) {
            let query = food.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? food
            let urlString = "https://world.openfoodfacts.org/cgi/search.pl?search_terms=\(query)&search_simple=1&action=process&json=1"
            
            guard let url = URL(string: urlString) else {
                completion(nil)
                return
            }
            
            URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
                if let error = error {
                    print("OFF Error for '\(food)':", error)
                    completion(nil)
                    return
                }
                
                guard let data = data else {
                    completion(nil)
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(OpenFoodFactsResponse.self, from: data)
                    
                    guard let product = decoded.products.first,
                          let nutriments = product.nutriments else {
                        print("DEBUG: No product found for '\(food)'")
                        completion(nil)
                        return
                    }
                    
                    let ingredient = Ingredient(
                        id: UUID(),
                        name: product.product_name ?? food.capitalized,
                        quantity: 100, // Default 100g serving
                        weight: 100,
                        unit: "g",
                        protein: nutriments.proteins_100g ?? 0,
                        carbs: nutriments.carbohydrates_100g ?? 0,
                        fats: nutriments.fat_100g ?? 0,
                        fibre: nutriments.fiber_100g ?? 0,
                        tags: [.none]
                    )
                    
                    print("DEBUG: Found ingredient from API: \(ingredient.name)")
                    completion(ingredient)
                    
                } catch {
                    print("Decode error for '\(food)':", error)
                    completion(nil)
                }
                
            }.resume()
        }
        
        // MARK: - Aggregation
        private func buildFoodItem(from ingredients: [Ingredient]) -> FoodItem {
            var totalProtein: Double = 0
            var totalCarbs: Double = 0
            var totalFat: Double = 0
            
            for ingredient in ingredients {
                // Macros are per 100g, quantity is in grams
                let factor = ingredient.quantity / 100.0
                totalProtein += ingredient.protein * factor
                totalCarbs += ingredient.carbs * factor
                totalFat += ingredient.fats * factor
            }
            
            let totalCalories = Int((totalProtein * 4) + (totalCarbs * 4) + (totalFat * 9))
            
            // Get the user's original input text
            let userInput = describeYourMealText.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Described Meal"
            
            // Capitalize the first letter of the user's input
            let mealName = userInput.isEmpty ? "Described Meal" : (userInput.prefix(1).uppercased() + userInput.dropFirst())
            
            print("DEBUG: Built FoodItem - Name: '\(mealName)', Calories: \(totalCalories), P: \(totalProtein), C: \(totalCarbs), F: \(totalFat)")
            
            return FoodItem(
                id: 0,
                name: mealName,  // Use user's input as the meal name
                calories: totalCalories,
                image: "dietPlaceholder",
                servingSize: 1,
                unit: "serving",
                protein: totalProtein,
                carbs: totalCarbs,
                fat: totalFat,
                isSelected: false,
                desc: userInput,  // Store original input in description too
                ingredients: ingredients
            )
        }
        
        // MARK: - Navigation
        private func navigateToAdd(_ foodItem: FoodItem) {
            print("DEBUG: ========== NAVIGATION START ==========")
            print("DEBUG: FoodItem name: \(foodItem.name)")
            print("DEBUG: Ingredients count: \(foodItem.ingredients.count)")
            print("DEBUG: Delegate set: \(dietDelegate != nil)")
            
            // Try to load from storyboard
            guard let storyboard = self.storyboard ?? UIStoryboard(name: "Diet", bundle: nil) as UIStoryboard? else {
                print("ERROR: Could not load Diet storyboard")
                showAlert(message: "Could not load meal confirmation screen. Storyboard missing.")
                return
            }
            
            print("DEBUG: Storyboard loaded successfully")
            
            // Method 1: Instantiate as UINavigationController
            do {
                if let nav = storyboard.instantiateViewController(
                    withIdentifier: "AddDescribedMealViewController"
                ) as? UINavigationController {
                    print("DEBUG: Found UINavigationController")
                    
                    if let vc = nav.topViewController as? AddDescribedMealViewController {
                        print("DEBUG: Found AddDescribedMealViewController inside nav")
                        vc.foodItem = foodItem
                        vc.delegate = dietDelegate
                        present(nav, animated: true)
                        print("DEBUG: ========== NAVIGATION SUCCESS (Method 1) ==========")
                        return
                    }
                }
            } catch {
                print("ERROR Method 1: \(error)")
            }
            
            // Method 2: Instantiate directly as AddDescribedMealViewController
            do {
                if let vc = storyboard.instantiateViewController(
                    withIdentifier: "AddDescribedMealViewController"
                ) as? AddDescribedMealViewController {
                    print("DEBUG: Found AddDescribedMealViewController directly")
                    vc.foodItem = foodItem
                    vc.delegate = dietDelegate
                    
                    let nav = UINavigationController(rootViewController: vc)
                    present(nav, animated: true)
                    print("DEBUG: ========== NAVIGATION SUCCESS (Method 2) ==========")
                    return
                }
            } catch {
                print("ERROR Method 2: \(error)")
            }
            
            // If both methods fail
            print("ERROR: ========== NAVIGATION FAILED ==========")
            print("ERROR: Could not instantiate AddDescribedMealViewController")
            print("ERROR: Check Storyboard ID in Interface Builder")
            showAlert(message: "Could not load meal confirmation screen. Please check:\n\n1. Storyboard ID is set to 'AddDescribedMealViewController'\n2. Module is set correctly\n3. Class is AddDescribedMealViewController")
        }
        
        // MARK: - UI
        private func setupUI() {
            describeYourMealText.placeholder = "e.g., 2 roti with dal and curd"
            describeYourMealText.autocapitalizationType = .none
            describeYourMealText.autocorrectionType = .no
            
            dietInfoLabel.text = "Nutrition values are estimates derived from public food databases."
            dietInfoLabel.numberOfLines = 0
            dietInfoLabel.layer.cornerRadius = 20
            dietInfoLabel.clipsToBounds = true
            dietInfoLabel.font = .systemFont(ofSize: 14)
        }
        
        @objc private func dismissKeyboard() {
            view.endEditing(true)
        }
        
        private func showAlert(message: String) {
            let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        
        // MARK: - Loading Indicator
        private func showLoadingIndicator() {
            let loadingView = UIView(frame: view.bounds)
            loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            loadingView.tag = 999 // Tag for easy removal
            
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.center = loadingView.center
            activityIndicator.color = .white
            activityIndicator.startAnimating()
            
            let label = UILabel()
            label.text = "Analyzing meal..."
            label.textColor = .white
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textAlignment = .center
            label.frame = CGRect(x: 0, y: activityIndicator.frame.maxY + 20, width: view.bounds.width, height: 30)
            
            loadingView.addSubview(activityIndicator)
            loadingView.addSubview(label)
            view.addSubview(loadingView)
            
            self.loadingView = loadingView
            self.activityIndicator = activityIndicator
            
            doneButton.isEnabled = false
            describeYourMealText.isEnabled = false
            view.isUserInteractionEnabled = false
        }
        
        private func hideLoadingIndicator() {
            loadingView?.removeFromSuperview()
            loadingView = nil
            activityIndicator = nil
            
            // Remove by tag as backup
            view.viewWithTag(999)?.removeFromSuperview()
            
            doneButton.isEnabled = true
            describeYourMealText.isEnabled = true
            view.isUserInteractionEnabled = true
        }
    }
