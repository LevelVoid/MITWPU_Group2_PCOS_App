import UIKit

protocol AddMealDelegate: AnyObject {
    func didAddMeal(_ food: Food)
}

class AddMealViewController: UIViewController{
    
    @IBOutlet weak var foodTableView: UITableView!
    
    weak var delegate: AddMealDelegate?
    private var foodItems: [FoodItem] = []
    private var filteredFoodItems: [FoodItem] = []
    private var selectedQuantities: [String: Int] = [:]
    
    // handlebar UI
    private let handleBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.layer.cornerRadius = 2.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //closebutton
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray
        button.backgroundColor = UIColor.systemGray5
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //lbel
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add meal"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //done button
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(UIColor(hexString: "fe7a96"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let searchContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let searchIconImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        imageView.image = UIImage(systemName: "magnifyingglass", withConfiguration: config)
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search for food"
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let micButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let image = UIImage(systemName: "mic.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["Recent", "Favorites"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.backgroundColor = UIColor.systemGray6
        control.selectedSegmentTintColor = .white
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
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
            title: "Scan with AI"
        )
        button.tag = 2
        return button
    }()
    
    private let describeMealButton: UIButton = {
        let button = createOptionButton(
            imageName: "text.bubble",
            title: "Describe Meal"
        )
        button.tag = 3
        return button
    }()
    
    private lazy var optionsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            scanBarcodeButton,
            scanWithAIButton,
            describeMealButton
        ])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupActions()
        setupTableView()
        setupSearchTextField()
        loadFoodItems()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(handleBar)
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(doneButton)
        view.addSubview(searchContainer)
        
        searchContainer.addSubview(searchIconImageView)
        searchContainer.addSubview(searchTextField)
        searchContainer.addSubview(micButton)
        
        view.addSubview(segmentedControl)
        view.addSubview(optionsStackView)
        
        handleBar.isHidden = true
        
        NSLayoutConstraint.activate([
            // Handle Bar
            handleBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            handleBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handleBar.widthAnchor.constraint(equalToConstant: 40),
            handleBar.heightAnchor.constraint(equalToConstant: 5),
            
            // Close Button
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.topAnchor.constraint(equalTo: handleBar.bottomAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 50),
            closeButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            
            // Done Button
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            
            optionsStackView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 20),
            optionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            optionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            optionsStackView.heightAnchor.constraint(equalToConstant: 110),

            searchContainer.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: 16),
            searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchContainer.heightAnchor.constraint(equalToConstant: 50),
            
            // Search Icon
            searchIconImageView.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 12),
            searchIconImageView.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            searchIconImageView.widthAnchor.constraint(equalToConstant: 20),
            searchIconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Search Text Field
            searchTextField.leadingAnchor.constraint(equalTo: searchIconImageView.trailingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: micButton.leadingAnchor, constant: -8),
            searchTextField.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            
            // Mic Button
            micButton.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -12),
            micButton.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            micButton.widthAnchor.constraint(equalToConstant: 30),
            micButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Segmented Control
            segmentedControl.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentedControl.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        scanBarcodeButton.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
        scanWithAIButton.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
        describeMealButton.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
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
            label.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -8)
        ])
        
        return button
    }
    
    // MARK: - Actions
    @objc private func dismissModal() {
        dismiss(animated: true)
    }
    
    @objc private func optionButtonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            print("Scan Barcode tapped")
            let vc = BarcodeScannerViewController()
            vc.delegate = self
            present(vc, animated: true)
        case 2:
            print("Scan with AI tapped")
            for i in FoodLogDataSource.sampleFoods.indices {
                print(FoodLogDataSource.sampleFoods[i].name)
            }
            // Implement AI scanning
        case 3:
            print("Describe Meal tapped")
            describeMealTapped()
        default:
            break
        }
    }
    
    // MARK: - Describe Meal Navigation
    private func describeMealTapped() {
        let storyboard = UIStoryboard(name: "Diet", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "DescribeFoodViewController") as? DescribeFoodViewController else {
            print("⚠️ Error: Could not instantiate DescribeFoodViewController from storyboard")
            assertionFailure("Could not instantiate DescribeFoodViewController")
            return
        }
        
        // Pass a callback to receive the described meal
        vc.onFoodAdded = { description in
            // Handle the meal description here (e.g., update UI or model)
            print("Received meal description: \(description)")
            
            // TODO: Add logic to save the meal or update your data model
            // For example:
            // self?.saveMeal(description: description)
            // self?.dismiss(animated: true) // Dismiss AddMealViewController after saving
        }
        
        // Configure presentation style for a nice modal sheet
        vc.modalPresentationStyle = .pageSheet
        
        // Optional: Configure sheet presentation if you want to customize it
        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    .medium(),
                    .large()
                ]
                sheet.prefersGrabberVisible = true
                sheet.selectedDetentIdentifier = .medium
            } else {
                // Fallback: leave default detents
            }
        }
        
        present(vc, animated: true)
    }
    
    private func setupTableView() {
        guard let tableView = foodTableView else {
            assertionFailure("foodTableView outlet is not connected. Ensure AddMealViewController is loaded from storyboard and the outlet is wired.")
            return
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGray6
        tableView.rowHeight = 60
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FoodItemCell")
        
        // Remove leading padding/margins
        if #available(iOS 11.0, *) {
            tableView.insetsContentViewsToSafeArea = false
        }
        tableView.separatorInset = .zero
        if #available(iOS 13.0, *) {
            tableView.directionalLayoutMargins = .zero
        }
        tableView.layoutMargins = .zero
        #if swift(>=5.3)
            tableView.cellLayoutMarginsFollowReadableWidth = false
        #endif
    }
    
    private func setupSearchTextField() {
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
    }
    
    // MARK: - Data Loading
    private func loadFoodItems() {
        foodItems = FoodListdataStore.shared.loadFoodItems()
        filteredFoodItems = foodItems
        foodTableView.reloadData()
    }
    
    // MARK: - Search
    @objc private func searchTextChanged() {
        let query = searchTextField.text ?? ""
        
        if query.isEmpty {
            filteredFoodItems = foodItems
        } else {
            filteredFoodItems = foodItems.filter {
                $0.name.lowercased().contains(query.lowercased())
            }
        }
        
        foodTableView.reloadData()
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // Recent
            // TODO: Load recent items
            loadFoodItems()
        case 1: // Favorites
            // TODO: Load favorite items
            loadFoodItems()
        default:
            break
        }
    }
}

// MARK: - Presentation Extension
extension AddMealViewController {
    static func present(from viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Diet", bundle: nil)
        let addMealVC: AddMealViewController
        if let vc = storyboard.instantiateViewController(withIdentifier: "AddMealViewController") as? AddMealViewController {
            addMealVC = vc
        } else {
            print("⚠️ Warning: Could not instantiate AddMealViewController from storyboard. Falling back to direct init. This may cause IBOutlets to be nil.")
            addMealVC = AddMealViewController()
        }

        if let sheet = addMealVC.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    .medium(),
                    .large()
                ]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.selectedDetentIdentifier = .medium
                sheet.largestUndimmedDetentIdentifier = nil
            } else {
                // Fallback: leave default detents
            }
        }
        addMealVC.isModalInPresentation = false

        viewController.present(addMealVC, animated: true)
    }
}

extension AddMealViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedFood = filteredFoodItems[indexPath.row]
        openFoodDetailScreen(for: selectedFood)
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func openFoodDetailScreen(for foodItem: FoodItem) {
        // TODO: Create and push to FoodDetailViewController
        let storyboard = UIStoryboard(name: "Diet", bundle: nil)
        
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "FoodDetailViewController") as? FoodDetailViewController else {
            print("⚠️ Error: Could not instantiate FoodDetailViewController")
            return
        }
        
        // Pass the food item
        detailVC.foodItem = foodItem
        detailVC.currentQuantity = selectedQuantities[foodItem.id] ?? 0
        
        // Callback to receive the selected quantity
        detailVC.onQuantitySelected = { [weak self] quantity in
            self?.selectedQuantities[foodItem.id] = quantity
            print("📝 Selected \(quantity) serving(s) of \(foodItem.name)")
        }
        
        // Push to detail screen
        if let navigationController = self.navigationController {
            navigationController.pushViewController(detailVC, animated: true)
        } else {
            // If there's no navigation controller, present modally
            detailVC.modalPresentationStyle = .pageSheet
            if let sheet = detailVC.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    sheet.detents = [
                        .medium(),
                        .large()
                    ]
                    sheet.prefersGrabberVisible = true
                } else {
                    // Fallback: leave default detents
                }
            }
            present(detailVC, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension AddMealViewController: UITableViewDataSource {
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFoodItems.count
    }
    
    @objc func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = "FoodItemCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseId)
        
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        cell.preservesSuperviewLayoutMargins = false
        cell.contentView.preservesSuperviewLayoutMargins = false
        
        let foodItem = filteredFoodItems[indexPath.row]
        cell.textLabel?.text = foodItem.name
        cell.detailTextLabel?.text = "\(foodItem.calories) kcal • \(foodItem.servingSize)"
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension AddMealViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddMealViewController: BarcodeScannerDelegate {
    
    func didScanBarcode(_ code: String) {
        print("Scanned in AddMealVC:", code)
        fetchFood(byBarcode: code)
    }
    
    func fetchFood(byBarcode barcode: String) {
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcode).json"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error:", error)
                return
            }
            
            guard let data = data else {
                print("❌ No data received.")
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(OFFResponse.self, from: data)
                
                guard decoded.status == 1, let product = decoded.product else {
                    print("❌ Product not found in API")
                    return
                }
                
                let food = product.toFood()
                
                DispatchQueue.main.async {
                    FoodLogDataSource.addFoodBarCode(food)
                    self.delegate?.didAddMeal(food)
                    self.dismiss(animated: true)
                }
                
            } catch {
                print("❌ JSON decode error:", error)
                print(String(data: data, encoding: .utf8) ?? "No readable data")
            }
            
        }.resume()
    }
}
