//
//  AddMealViewController.swift
//  PCOS_App
//

import UIKit

protocol AddMealDelegate: AnyObject {
    func didAddMeal(_ food: Food)
}

class AddMealViewController: UIViewController {
    
    @IBOutlet weak var foodTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchTextField: UISearchBar!
    @IBOutlet weak var optionsStackView: UIStackView!
    
    weak var delegate: AddMealDelegate?
       weak var dietDelegate: AddDescribedMealDelegate?
       
       private var foodItems: [FoodItem] = []
       private var filteredFoodItems: [FoodItem] = []
       private var recentMeals: [Food] = []
       private var filteredRecentMeals: [Food] = []
       private var isShowingRecent: Bool = true
       
    private let scanBarcodeButton: UIButton = {
           let button = createOptionButton(
               imageName: "barcode.viewfinder",
               title: "Scan Barcode"
           )
           button.tag = 1
           return button
       }()
       
       private let scanWithAIButton: UIButton = {
           let button = createOptionButton(
               imageName: "camera",
               title: "Scan Image"
           )
           button.tag = 2
           return button
       }()
       
       private let describeMealButton: UIButton = {
           let button = createOptionButton(
               imageName: "text.bubble",
               title: "Describe"
           )
           button.tag = 3
           return button
       }()
       
       override func viewDidLoad() {
           super.viewDidLoad()
           navigationController?.navigationBar.prefersLargeTitles = false
           title = "Add Meal"
           
           setupOptionsStackView()
           setupSearchBar()
           setupSegmentedControl()
           setupActions()
           setupTableView()
           loadInitialData()
       }
       
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           loadInitialData()
       }
       
       // MARK: - Setup Methods
       
       private func setupOptionsStackView() {
           optionsStackView.addArrangedSubview(scanBarcodeButton)
           optionsStackView.addArrangedSubview(scanWithAIButton)
           optionsStackView.addArrangedSubview(describeMealButton)
           optionsStackView.axis = .horizontal
           optionsStackView.distribution = .fillEqually
           optionsStackView.spacing = 12
           optionsStackView.translatesAutoresizingMaskIntoConstraints = false
       }
       
       private func setupSearchBar() {
           searchTextField.placeholder = "Search for a meal"
           searchTextField.delegate = self
           
           // Remove the default background
           searchTextField.backgroundImage = UIImage()
           searchTextField.backgroundColor = .clear
           
           // Style the inner text field as capsule
           if let searchField = searchTextField.value(forKey: "searchField") as? UITextField {
               searchField.backgroundColor = .white
               searchField.layer.cornerRadius = 18
               searchField.layer.masksToBounds = true
               searchField.layer.borderWidth = 1
               searchField.layer.borderColor = UIColor.systemGray5.cgColor
           }
       }
       
       private func setupSegmentedControl() {
           segmentedControl.selectedSegmentIndex = 0
           segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
       }
       
       private func setupActions() {
           scanBarcodeButton.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
           scanWithAIButton.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
           describeMealButton.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
       }
       
       private func setupTableView() {
           guard let tableView = foodTableView else {
               assertionFailure("foodTableView outlet is not connected.")
               return
           }
           tableView.delegate = self
           tableView.dataSource = self
           tableView.rowHeight = 60
           tableView.sectionHeaderTopPadding = 0
           tableView.sectionHeaderHeight = 0
           tableView.sectionFooterHeight = 0
           tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FoodItemCell")
       }
       
       // MARK: - Data Loading
       
       private func loadInitialData() {
           foodItems = FoodListdataStore.shared.loadFoodItems()
           loadRecentMeals()
           updateDisplayedData()
       }
       
       private func loadRecentMeals() {
           let allMeals = FoodLogDataStore.sampleFoods
           recentMeals = Array(allMeals
               .sorted { $0.timeStamp > $1.timeStamp }
               .prefix(5))
           filteredRecentMeals = recentMeals
           print("DEBUG: Loaded \(recentMeals.count) recent meals")
       }
       
       private func updateDisplayedData() {
           if isShowingRecent {
               filteredRecentMeals = recentMeals
               filteredFoodItems = []
           } else {
               filteredFoodItems = foodItems
               filteredRecentMeals = []
           }
           foodTableView.reloadData()
       }
       
       // MARK: - Helper Methods
       
       private static func createOptionButton(imageName: String, title: String) -> UIButton {
           let button = UIButton(type: .system)
           button.backgroundColor = .white
           button.layer.cornerRadius = 12
           button.layer.borderWidth = 1
           button.layer.borderColor = UIColor.systemGray5.cgColor
           button.translatesAutoresizingMaskIntoConstraints = false
           
           let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
           let image = UIImage(systemName: imageName, withConfiguration: config)
           
           let imageView = UIImageView(image: image)
           imageView.tintColor = .black
           imageView.contentMode = .scaleAspectFit
           imageView.translatesAutoresizingMaskIntoConstraints = false
           
           let label = UILabel()
           label.text = title
           label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
           label.textAlignment = .center
           label.numberOfLines = 2
           label.translatesAutoresizingMaskIntoConstraints = false
           
           button.addSubview(imageView)
           button.addSubview(label)
           
           NSLayoutConstraint.activate([
               imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
               imageView.topAnchor.constraint(equalTo: button.topAnchor, constant: 20),
               imageView.widthAnchor.constraint(equalToConstant: 40),
               imageView.heightAnchor.constraint(equalToConstant: 40),
               
               label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
               label.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 8),
               label.widthAnchor.constraint(equalToConstant: 10),
               label.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -8)
           ])
           
           return button
       }
       
       // MARK: - Actions
       
       @objc private func segmentChanged(_ sender: UISegmentedControl) {
           isShowingRecent = (sender.selectedSegmentIndex == 0)
           searchTextField.text = ""
           updateDisplayedData()
           print("DEBUG: Switched to \(isShowingRecent ? "Recent" : "All meals")")
       }
       
       @objc private func optionButtonTapped(_ sender: UIButton) {
           switch sender.tag {
           case 1:
               print("Scan Barcode tapped")
               openBarcodeScanner()
           case 2:
               print("Scan with AI tapped")
               openFoodScanner()
           case 3:
               print("Describe Meal tapped")
               describeMealTapped()
           default:
               break
           }
       }
       
       // MARK: - Barcode Scanner
       
       private func openBarcodeScanner() {
           let vc = BarcodeScannerViewController()
           vc.delegate = self
           vc.modalPresentationStyle = .fullScreen
           present(vc, animated: true)
       }
       
       // MARK: - Food Scanner (AI)
       
       private func openFoodScanner() {
           let vc = FoodScannerViewController()
           vc.dietDelegate = self.dietDelegate
           vc.modalPresentationStyle = .fullScreen
           present(vc, animated: true)
       }
       
       // MARK: - Describe Meal Navigation
       
       private func describeMealTapped() {
           let storyboard = UIStoryboard(name: "Diet", bundle: nil)
           guard let vc = storyboard.instantiateViewController(
               withIdentifier: "DescribeFoodViewController"
           ) as? DescribeFoodViewController else {
               print("Error: Could not instantiate DescribeFoodViewController")
               return
           }
           
           vc.dietDelegate = self.dietDelegate
           
           let navController = UINavigationController(rootViewController: vc)
           navController.modalPresentationStyle = .pageSheet
           
           if let sheet = navController.sheetPresentationController {
               if #available(iOS 16.0, *) {
                   sheet.detents = [.large()]
                   sheet.prefersGrabberVisible = true
                   sheet.selectedDetentIdentifier = .medium
               }
           }
           
           present(navController, animated: true)
       }
       
       // MARK: - Navigation to AddDescribedMealVC
       
       private func navigateToAddDescribedMeal(with food: Food) {
           let storyboard = UIStoryboard(name: "Diet", bundle: nil)
           guard let confirmVC = storyboard.instantiateViewController(
               withIdentifier: "AddDescribedMealViewController"
           ) as? AddDescribedMealViewController else {
               print("Error: Could not instantiate AddDescribedMealViewController")
               return
           }
           
           confirmVC.food = food
           confirmVC.delegate = dietDelegate
           
           let navController = UINavigationController(rootViewController: confirmVC)
           navController.modalPresentationStyle = .pageSheet
           
           if let sheet = navController.sheetPresentationController {
               if #available(iOS 16.0, *) {
                   sheet.detents = [.large()]
                   sheet.prefersGrabberVisible = true
                   sheet.selectedDetentIdentifier = .large
               }
           }
           
           present(navController, animated: true)
       }
    
    private func navigateToAddDescribedMeal(with foodItem: FoodItem) {
        let storyboard = UIStoryboard(name: "Diet", bundle: nil)
        guard let confirmVC = storyboard.instantiateViewController(
            withIdentifier: "AddDescribedMealViewController"
        ) as? AddDescribedMealViewController else {
            print("Error: Could not instantiate AddDescribedMealViewController")
            return
        }
        
        confirmVC.foodItem = foodItem
        // ← KEY FIX: pass dietDelegate so DietVC gets the callback
        confirmVC.delegate = dietDelegate
        
        let navController = UINavigationController(rootViewController: confirmVC)
        navController.modalPresentationStyle = .pageSheet
        
        if let sheet = navController.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.selectedDetentIdentifier = .large
            }
        }
        
        present(navController, animated: true)
    }
}

// MARK: - Static Present Helper
extension AddMealViewController {
    static func present(from viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Diet", bundle: nil)
        let addMealVC: AddMealViewController
        if let vc = storyboard.instantiateViewController(
            withIdentifier: "AddMealViewController"
        ) as? AddMealViewController {
            addMealVC = vc
        } else {
            addMealVC = AddMealViewController()
        }

        if let sheet = addMealVC.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.selectedDetentIdentifier = .medium
                sheet.largestUndimmedDetentIdentifier = nil
            }
        }
        addMealVC.isModalInPresentation = false
        viewController.present(addMealVC, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension AddMealViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isShowingRecent {
            let selectedFood = filteredRecentMeals[indexPath.row]
            print("DEBUG: Selected recent meal: \(selectedFood.name)")
            navigateToAddDescribedMeal(with: selectedFood)
        } else {
            let selectedFoodItem = filteredFoodItems[indexPath.row]
            print("DEBUG: Selected food item: \(selectedFoodItem.name)")
            navigateToAddDescribedMeal(with: selectedFoodItem)
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.contentView.backgroundColor = UIColor.systemGray6
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.contentView.backgroundColor = .clear
        }
    }
}

// MARK: - UITableViewDataSource
extension AddMealViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isShowingRecent ? filteredRecentMeals.count : filteredFoodItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = "FoodItemCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseId)
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        cell.selectionStyle = .none
        
        if isShowingRecent {
            let food = filteredRecentMeals[indexPath.row]
            cell.textLabel?.text = food.name
            let calories = Int(food.calories)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, h:mm a"
            let timeString = dateFormatter.string(from: food.timeStamp)
            cell.detailTextLabel?.text = "\(calories) kcal • \(timeString)"
        } else {
            let foodItem = filteredFoodItems[indexPath.row]
            cell.textLabel?.text = foodItem.name
            cell.detailTextLabel?.text = "\(foodItem.calories) kcal • \(foodItem.servingSize) \(foodItem.unit)"
        }
        
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension AddMealViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let query = searchText
        
        if isShowingRecent {
            if query.isEmpty {
                filteredRecentMeals = recentMeals
            } else {
                filteredRecentMeals = recentMeals.filter {
                    $0.name.lowercased().contains(query.lowercased())
                }
            }
        } else {
            if query.isEmpty {
                filteredFoodItems = foodItems
            } else {
                filteredFoodItems = foodItems.filter {
                    $0.name.lowercased().contains(query.lowercased())
                }
            }
        }
        foodTableView.reloadData()
    }
}

// MARK: - BarcodeScannerDelegate
extension AddMealViewController: BarcodeScannerDelegate {
    
    func didScanBarcode(_ code: String) {
        print("Scanned in AddMealVC:", code)
        fetchFood(byBarcode: code)
    }
    
    func fetchFood(byBarcode barcode: String) {
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcode).json"
        guard let url = URL(string: urlString) else { return }
        
        showFetchingIndicator()
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error:", error)
                DispatchQueue.main.async {
                    self.hideFetchingIndicator()
                    self.showBarcodeError("Network error. Please check your connection and try again.")
                }
                return
            }
            guard let data = data else {
                print("No data received.")
                DispatchQueue.main.async {
                    self.hideFetchingIndicator()
                    self.showBarcodeError("No response from server. Please try again.")
                }
                return
            }
            do {
                let decoded = try JSONDecoder().decode(OFFResponse.self, from: data)
                guard decoded.status == 1, let product = decoded.product else {
                    print("Product not found in API")
                    DispatchQueue.main.async {
                        self.hideFetchingIndicator()
                        self.showBarcodeError("Food not found in our database.\n\nTry using \"Describe Meal\" or \"Scan Food\" to add it manually.")
                    }
                    return
                }
                let food = product.toFood()
                DispatchQueue.main.async {
                    self.hideFetchingIndicator()
                    // ← KEY FIX: call delegate (DietVC) and pop back
                    self.delegate?.didAddMeal(food)
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } catch {
                print("JSON decode error:", error)
                print(String(data: data, encoding: .utf8) ?? "No readable data")
                DispatchQueue.main.async {
                    self.hideFetchingIndicator()
                    self.showBarcodeError("Could not read product data. Try describing the meal instead.")
                }
            }
        }.resume()
    }
    
    // MARK: - Loading Indicator
    
    private func showFetchingIndicator() {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlay.tag = 998
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = overlay.center
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        
        let label = UILabel()
        label.text = "Looking up product..."
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.frame = CGRect(
            x: 0,
            y: activityIndicator.frame.maxY + 20,
            width: view.bounds.width,
            height: 30
        )
        
        overlay.addSubview(activityIndicator)
        overlay.addSubview(label)
        view.addSubview(overlay)
    }
    
    private func hideFetchingIndicator() {
        view.viewWithTag(998)?.removeFromSuperview()
    }
    
    private func showBarcodeError(_ message: String) {
        let alert = UIAlertController(
            title: "Product Not Found",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
