//
//  DescribeFoodViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 02/12/25.
//

import UIKit
import FoundationModels

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
        Task {
            await analyzeMealWithFoundationModel(description: text)
        }
    }

    // MARK: - Foundation Model Analysis
    private func analyzeMealWithFoundationModel(description: String) async {
        let instructions = """
            You are a professional nutritionist specializing in Indian and international foods.
            When given a meal description, return ONLY a valid JSON object with NO extra text,
            NO markdown, NO code blocks, NO explanation — just raw JSON.

            The JSON must follow this exact structure:
            {
              "name": "meal name based on user input",
              "calories": 500,
              "servingSize": 1.0,
              "unit": "serving",
              "protein": 20.5,
              "carbs": 60.0,
              "fat": 15.0,
              "desc": "brief description",
              "ingredients": [
                {
                  "name": "ingredient name",
                  "quantity": 100.0,
                  "unit": "g",
                  "protein": 5.0,
                  "carbs": 20.0,
                  "fats": 3.0,
                  "fibre": 1.0
                }
              ]
            }

            Rules:
            - All numeric values must be doubles or integers (no strings for numbers)
            - ingredients array must have at least one item
            - quantity is always in grams
            - Return ONLY the JSON, nothing else
            """

        let session = LanguageModelSession(instructions: instructions)

        do {
            let result = try await session.respond(to: description)
            let responseText = result.content

            print("DEBUG: Foundation Model response:\n\(responseText)")

            await MainActor.run {
                self.hideLoadingIndicator()
                self.parseAndNavigate(json: responseText, originalInput: description)
            }

        } catch {
            print("ERROR: Foundation Model failed: \(error)")
            await MainActor.run {
                self.hideLoadingIndicator()
                self.showAlert(message: "AI analysis failed. Please try again.\n\nError: \(error.localizedDescription)")
            }
        }
    }

    private func parseAndNavigate(json: String, originalInput: String) {
        var cleaned = json.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("```json") {
            cleaned = String(cleaned.dropFirst(7))
        } else if cleaned.hasPrefix("```") {
            cleaned = String(cleaned.dropFirst(3))
        }
        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8) else {
            showAlert(message: "Could not process AI response. Please try again.")
            return
        }

        do {
            // ← This line was missing
            let decoded = try JSONDecoder().decode(AIFoodResponse.self, from: data)

            let ingredients: [Ingredient] = decoded.ingredients.map { (raw: AIIngredient) -> Ingredient in
                Ingredient(
                    id: UUID(),
                    name: raw.name,
                    quantity: raw.quantity,
                    weight: raw.quantity,
                    unit: raw.unit,
                    protein: raw.protein,
                    carbs: raw.carbs,
                    fats: raw.fats,
                    fibre: raw.fibre,
                    tags: [.none]
                )
            }

            guard !ingredients.isEmpty else {
                showAlert(message: "No ingredients found in AI response. Please try again.")
                return
            }

            let foodItem = FoodItem(
                id: Int.random(in: 100000...999999),
                name: decoded.name,
                calories: decoded.calories,
                image: "dietPlaceholder",
                servingSize: decoded.servingSize,
                unit: decoded.unit,
                protein: decoded.protein,
                carbs: decoded.carbs,
                fat: decoded.fat,
                isSelected: false,
                desc: decoded.desc,
                ingredients: ingredients
            )

            print("DEBUG: Parsed FoodItem - \(foodItem.name), \(ingredients.count) ingredients")
            navigateToAdd(foodItem)

        } catch {
            print("ERROR: JSON parsing failed: \(error)")
            print("DEBUG: Raw cleaned JSON:\n\(cleaned)")
            showAlert(message: "Could not parse AI response. Please try again with a clearer description.")
        }
    }
    

    // MARK: - Navigation
    private func navigateToAdd(_ foodItem: FoodItem) {
        let storyboard = self.storyboard ?? UIStoryboard(name: "Diet", bundle: nil)

        if let vc = storyboard.instantiateViewController(
            withIdentifier: "AddDescribedMealViewController"
        ) as? AddDescribedMealViewController {
            vc.foodItem = foodItem
            vc.delegate = dietDelegate
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            if let sheet = nav.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersGrabberVisible = true
                    sheet.selectedDetentIdentifier = .large
                }
            }
            present(nav, animated: true)
        } else {
            showAlert(message: "Could not load meal confirmation screen.")
        }
    }

    // MARK: - UI
    private func setupUI() {
        describeYourMealText.placeholder = "e.g., 2 roti with dal and curd"
        describeYourMealText.autocapitalizationType = .none
        describeYourMealText.autocorrectionType = .no

        dietInfoLabel.text = "Nutrition values are AI estimates. Results may vary."
        dietInfoLabel.numberOfLines = 0
        dietInfoLabel.layer.cornerRadius = 20
        dietInfoLabel.clipsToBounds = true
        dietInfoLabel.font = .systemFont(ofSize: 14)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Notice", message: message, preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Loading Indicator
    private func showLoadingIndicator() {
        let loadingView = UIView(frame: view.bounds)
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        loadingView.tag = 999

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = loadingView.center
        activityIndicator.color = .white
        activityIndicator.startAnimating()

        let label = UILabel()
        label.text = "AI is analyzing your meal..."
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.frame = CGRect(
            x: 0,
            y: activityIndicator.frame.maxY + 20,
            width: view.bounds.width,
            height: 30
        )

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
        view.viewWithTag(999)?.removeFromSuperview()

        doneButton.isEnabled = true
        describeYourMealText.isEnabled = true
        view.isUserInteractionEnabled = true
    }
}
