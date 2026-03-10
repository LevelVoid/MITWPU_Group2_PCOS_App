//
//  DayLoggedMealViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 17/01/26.
//

import UIKit

class DayLoggedMealViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mealDayLabel: UILabel!
    @IBOutlet weak var noMealsLabel: UILabel!
    @IBOutlet weak var daysMeal: UITableView!
    
    var selectedDate: Date!
        private var meals: [Food] = []
        private let calendar = Calendar.current
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupTableView()
            loadAndDisplay()
        }
        
        private func setupUI() {
            // Initially hide no meals label
            noMealsLabel.isHidden = true
            noMealsLabel.text = "No meals logged for this day"
            noMealsLabel.textColor = .systemGray
            noMealsLabel.font = .systemFont(ofSize: 16)
            noMealsLabel.textAlignment = .center
            
            // Setup meal day label (total calories)
            mealDayLabel.font = .systemFont(ofSize: 16, weight: .medium)
            mealDayLabel.textAlignment = .center
            mealDayLabel.textColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0)
        }
        
        private func setupTableView() {
            daysMeal.backgroundColor = .clear
            daysMeal.delegate = self
            daysMeal.dataSource = self
            daysMeal.separatorStyle = .none
            daysMeal.estimatedRowHeight = 100
            daysMeal.rowHeight = 100
            daysMeal.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
            
            // Register the same cell used in DietViewController
            daysMeal.register(LogsTableViewCell.nib(), forCellReuseIdentifier: LogsTableViewCell.identifier)
        }
        
        private func loadAndDisplay() {
            updateDateLabel()
            loadMeals()
            updateTotalCalories()
        }
        
        private func updateDateLabel() {
            guard let selectedDate = selectedDate else { return }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            dateLabel.text = formatter.string(from: selectedDate)
            dateLabel.font = .systemFont(ofSize: 18, weight: .semibold)
            dateLabel.textAlignment = .center
        }
        
        private func loadMeals() {
            guard let selectedDate = selectedDate else { return }
            
            let allMeals = FoodLogDataStore.sampleFoods
            let selectedDayStart = calendar.startOfDay(for: selectedDate)
            let selectedDayEnd = calendar.date(byAdding: .day, value: 1, to: selectedDayStart)!
            
            meals = allMeals.filter { meal in
                meal.timeStamp >= selectedDayStart && meal.timeStamp < selectedDayEnd
            }.sorted { $0.timeStamp < $1.timeStamp }

            if meals.isEmpty {
                daysMeal.isHidden = true
                noMealsLabel.isHidden = false
            } else {
                daysMeal.isHidden = false
                noMealsLabel.isHidden = true
            }
            
            daysMeal.reloadData()
            
            print("DEBUG: Loaded \(meals.count) meals for \(selectedDate)")
        }
        
        private func updateTotalCalories() {
            guard !meals.isEmpty else {
                mealDayLabel.text = "0 kcal"
                return
            }
            
            let totalCalories = meals.reduce(0) { total, meal in
                let calories = Int((meal.proteinContent * 4) + (meal.carbsContent * 4) + (meal.fatsContent * 9))
                return total + calories
            }
            
            mealDayLabel.text = "\(totalCalories) kcal total"
        }
        
        // MARK: - Public Method to Update Date
        func updateDate(_ newDate: Date) {
            selectedDate = newDate
            loadAndDisplay()
        }
    }

    // MARK: - UITableViewDataSource
    extension DayLoggedMealViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return meals.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: LogsTableViewCell.identifier, for: indexPath) as! LogsTableViewCell
            let meal = meals[indexPath.row]
            cell.outerCell.backgroundColor = .white
            cell.innerCell.layer.shadowColor = UIColor.black.cgColor
            cell.innerCell.layer.shadowOpacity = 0.05
            cell.innerCell.layer.shadowOffset = CGSize(width: 0, height: 2)
            cell.innerCell.layer.shadowRadius = 4
            cell.configure(with: meal)
            return cell
        }
    }

    // MARK: - UITableViewDelegate
    extension DayLoggedMealViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            let selectedMeal = meals[indexPath.row]
            
            print("DEBUG: Selected meal: \(selectedMeal.name)")
            
            // Navigate to FoodLogIngredientViewController
            FoodLogIngredientViewController.present(from: self, with: selectedMeal)
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 100
        }
    }
