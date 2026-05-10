import UIKit
import CoreData

class DietViewController: UIViewController {

    var todaysFoods: [Food] = []

    @IBOutlet weak var collectionView: UICollectionView!  // ← was tableView
    @IBOutlet weak var AddMealButton: UIButton!
    private var nutritionCell: NutritionHeaderCollectionViewCell?  // ← was headerView
  
    private var mealOutput: MealRecommendationOutput?
    private var isMealLoading = false
    private var mealError: String?
    private var lastFoodLogCount: Int = -1
 
    // Sizing prototype for dynamic height
    private lazy var sizingSuggestionCell: FoodSuggestionsCollectionViewCell = {
        let cell = FoodSuggestionsCollectionViewCell.nib().instantiate(withOwner: nil).first as! FoodSuggestionsCollectionViewCell
        return cell
    }()
 
    // MARK: - Lifecycle
 
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Diet"
        setupNavigation()
        setupCollectionView()
        setupAddButtonStyle()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        filterTodaysFoods()
        Task { await refreshMealRecommendationsIfNeeded() }
    }
 
    // MARK: - Setup
 
    private func setupNavigation() {
        let calendar = UIBarButtonItem(
            image: UIImage(systemName: "calendar"),
            style: .plain,
            target: self,
            action: #selector(calendarTapped)
        )
        navigationItem.rightBarButtonItem = calendar
    }
 
    private func setupCollectionView() {
        collectionView.register(
            NutritionHeaderCollectionViewCell.nib(),
            forCellWithReuseIdentifier: NutritionHeaderCollectionViewCell.identifier
        )
        collectionView.register(
            FoodSuggestionsCollectionViewCell.nib(),
            forCellWithReuseIdentifier: FoodSuggestionsCollectionViewCell.identifier
        )
        collectionView.register(
            MealLogsCollectionViewCell.nib(),
            forCellWithReuseIdentifier: MealLogsCollectionViewCell.identifier
        )
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.identifier
        )
        collectionView.register(
            NoFoodCollectionViewCell.nib(),
            forCellWithReuseIdentifier: NoFoodCollectionViewCell.identifier
        )
 
        collectionView.dataSource = self
        collectionView.delegate = self
 
        let bgColor = UIColor(red: 252/255, green: 238/255, blue: 237/255, alpha: 1)
        collectionView.backgroundColor = bgColor
        view.backgroundColor = bgColor
 
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
    }
 
    private func setupAddButtonStyle() {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        config.image = UIImage(systemName: "plus", withConfiguration: symbolConfig)
        config.baseBackgroundColor = UIColor(hex: "#fe7a96")
        config.baseForegroundColor = .white
        AddMealButton.configuration = config
        AddMealButton.setTitle("", for: .normal)
 
        AddMealButton.layer.shadowColor = UIColor(hex: "#fe7a96").cgColor
        AddMealButton.layer.shadowOpacity = 0.3
        AddMealButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        AddMealButton.layer.shadowRadius = 6
 
        if let superview = AddMealButton.superview {
            AddMealButton.removeFromSuperview()
            superview.addSubview(AddMealButton)
        }
 
        AddMealButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            AddMealButton.widthAnchor.constraint(equalToConstant: 44),
            AddMealButton.heightAnchor.constraint(equalToConstant: 44),
            AddMealButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            AddMealButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
 
        AddMealButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
    }
 
    // MARK: - Actions
 
    @objc func calendarTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "dietLogs")
            as? DietCalendarLogsViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
 
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Diet", bundle: nil)
        guard let addVC = storyboard.instantiateViewController(withIdentifier: "AddMealViewController")
            as? AddMealViewController else {
            let addVC = AddMealViewController()
            addVC.delegate = self
            addVC.dietDelegate = self
            navigationController?.pushViewController(addVC, animated: true)
            return
        }
        addVC.delegate = self
        addVC.dietDelegate = self
        navigationController?.pushViewController(addVC, animated: true)
    }
 
    // MARK: - Data
 
    private func filterTodaysFoods() {
        todaysFoods = FoodLogDataStore.todaysMeal.sorted { $0.timeStamp > $1.timeStamp }
        collectionView.reloadData()
        print("DietVC — found \(todaysFoods.count) foods for today")
    }
 
    // MARK: - Meal Suggestions (cached)
 
    private func refreshMealRecommendationsIfNeeded() async {
        let currentCount = fetchTodayFoodLogCount()
 
        if let _ = mealOutput, currentCount == lastFoodLogCount {
            await MainActor.run {
                self.collectionView.reloadSections(IndexSet(integer: 1))
            }
            return
        }
 
        guard !isMealLoading else { return }
        isMealLoading = true
        lastFoodLogCount = currentCount
 
        do {
            let context = await SharedContextEngine.shared.buildContext()
            print("DietVC — context built, calling AI for suggestions...")
            let output = try await AIBrain.shared.generateMealRecommendations(context: context)
            await MainActor.run {
                self.mealOutput = output
                self.mealError = nil
                self.isMealLoading = false
                self.collectionView.reloadSections(IndexSet(integer: 1))
                print("DietVC — AI suggestions received and section reloaded")
            }
        } catch {
            await MainActor.run {
                self.isMealLoading = false
                self.mealError = error.localizedDescription
                self.collectionView.reloadSections(IndexSet(integer: 1))
                print("Meal suggestions error: \(error)")
            }
        }
    }
 
    private func fetchTodayFoodLogCount() -> Int {
        return FoodLogDataStore.todaysMeal.count
    }
 
    /// Compute observation lines in Swift — guarantees correct waterfall priority
    private func computeObservationLines() -> (observation: String, subObservation: String) {
        // Use same goal computation as the macro tracker UI
        guard let user = ProfileService.shared.buildUserProfile() else {
            return ("Track your meals to get personalized suggestions.", "Start logging to see your macro gaps.")
        }
        let goals = GoalEngine.generateGoals(for: user)
        let goalP = Int(round(Double(goals.diet.startingProteinGrams) / 5.0)) * 5
        let goalC = Int(round(Double(goals.diet.startingCarbsGrams) / 5.0)) * 5
        let goalF = Int(round(Double(goals.diet.startingFatsGrams) / 5.0)) * 5
        
        let meals = FoodLogDataStore.todaysMeal
        let totalP = Int(meals.reduce(0.0) { $0 + $1.proteinContent })
        let totalC = Int(meals.reduce(0.0) { $0 + $1.carbsContent })
        let totalF = Int(meals.reduce(0.0) { $0 + $1.fatsContent })
        
        let proteinGap = max(0, goalP - totalP)
        let carbsGap   = max(0, goalC - totalC)
        let fatsGap    = max(0, goalF - totalF)
        
        // Waterfall: Protein → Carbs → Fats
        if proteinGap > 0 {
            return ("You're \(proteinGap)g short on protein today.",
                    "Add a high-protein meal to stay on track.")
        } else if carbsGap > 0 {
            return ("You're \(carbsGap)g short on carbs today.",
                    "Slow-release meals help maintain steady energy.")
        } else if fatsGap > 0 {
            return ("You're \(fatsGap)g short on fats today.",
                    "Healthy fats help support hormones and satiety.")
        } else {
            return ("You've hit all your macro goals today!",
                    "Great job keep up the balanced eating.")
        }
    }
 
    /// Returns true when all macro goals are met
    private func allGoalsMet() -> Bool {
        guard let user = ProfileService.shared.buildUserProfile() else { return false }
        let goals = GoalEngine.generateGoals(for: user)
        let goalP = Int(round(Double(goals.diet.startingProteinGrams) / 5.0)) * 5
        let goalC = Int(round(Double(goals.diet.startingCarbsGrams) / 5.0)) * 5
        let goalF = Int(round(Double(goals.diet.startingFatsGrams) / 5.0)) * 5
        
        let meals = FoodLogDataStore.todaysMeal
        let totalP = Int(meals.reduce(0.0) { $0 + $1.proteinContent })
        let totalC = Int(meals.reduce(0.0) { $0 + $1.carbsContent })
        let totalF = Int(meals.reduce(0.0) { $0 + $1.fatsContent })
        
        return totalP >= goalP && totalC >= goalC && totalF >= goalF
    }
 
    // MARK: - Delete
 
    private func deleteMeal(at foodIndex: Int) {
        guard foodIndex >= 0 && foodIndex < todaysFoods.count else { return }
        let mealToDelete = todaysFoods[foodIndex]
 
        let alert = UIAlertController(
            title: "Delete Meal",
            message: "Are you sure you want to delete '\(mealToDelete.name)'?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.nutritionCell?.subtractValues(mealToDelete)
            FoodLogDataStore.removeFood(mealToDelete)
            self.todaysFoods.remove(at: foodIndex)
            self.collectionView.reloadData()
            self.lastFoodLogCount = -1
            // Re-generate suggestions with updated macro gaps
            Task { await self.refreshMealRecommendationsIfNeeded() }
        })
        present(alert, animated: true)
    }
}
 
// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
 
extension DietViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
 
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
 
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 1
    }
 
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
 
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NutritionHeaderCollectionViewCell.identifier,
                for: indexPath
            ) as! NutritionHeaderCollectionViewCell
            cell.configure()
            cell.delegate = self
            cell.layer.cornerRadius = 20
            cell.layer.masksToBounds = true
            cell.backgroundColor = .systemBackground
            self.nutritionCell = cell
            return cell
 
        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FoodSuggestionsCollectionViewCell.identifier,
                for: indexPath
            ) as! FoodSuggestionsCollectionViewCell
            cell.layer.cornerRadius = 20
            cell.layer.masksToBounds = true
            cell.backgroundColor = .systemBackground
            if allGoalsMet() {
                let (obs, subObs) = computeObservationLines()
                cell.showGoalsMetState(observation: obs, subObservation: subObs)
            } else if let output = mealOutput {
                let (obs, subObs) = computeObservationLines()
                cell.configure(with: output,
                               observationOverride: obs,
                               subObservationOverride: subObs)
            } else if let errorMsg = mealError {
                cell.showErrorState(message: errorMsg)
            } else {
                cell.showLoadingState()
            }
            return cell
 
        case 2:
            if todaysFoods.isEmpty {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: NoFoodCollectionViewCell.identifier,
                    for: indexPath
                ) as! NoFoodCollectionViewCell
                cell.refreshQuote()
                cell.layer.cornerRadius = 20
                cell.layer.masksToBounds = true
                cell.backgroundColor = .systemBackground
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MealLogsCollectionViewCell.identifier,
                    for: indexPath
                ) as! MealLogsCollectionViewCell
                cell.configure(with: todaysFoods, quote: "")
                cell.delegate = self
                cell.layer.cornerRadius = 20
                cell.layer.masksToBounds = true
                cell.backgroundColor = .systemBackground
                return cell
            }
 
        default:
            fatalError("Unexpected section")
        }
    }
 
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width - 32
        switch indexPath.section {
        case 0: return CGSize(width: width, height: 195)
        case 1:
            if allGoalsMet() {
                return CGSize(width: width, height: 84)
            } else if let output = mealOutput {
                sizingSuggestionCell.bounds.size.width = width
                sizingSuggestionCell.contentView.bounds.size.width = width
                sizingSuggestionCell.configure(with: output)
                
                sizingSuggestionCell.setNeedsLayout()
                sizingSuggestionCell.layoutIfNeeded()

                // Calculate height based on width and Auto Layout
                let size = sizingSuggestionCell.contentView.systemLayoutSizeFitting(
                    CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
                    withHorizontalFittingPriority: .required,
                    verticalFittingPriority: .fittingSizeLevel
                )
                return CGSize(width: width, height: size.height)
            } else {
                return CGSize(width: width, height: 84) // Loading or Error state
            }
        case 2:
            if todaysFoods.isEmpty {
                return CGSize(width: width, height: 112)
            }
            return CGSize(width: width, height: CGFloat(todaysFoods.count) * 100)
        default: return CGSize(width: width, height: 0)
        }
    }
 
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.identifier,
            for: indexPath
        ) as! SectionHeaderView
 
        switch indexPath.section {
        case 1: header.configure(title: "Suggestions For Today")
        case 2: header.configure(title: "Today's Meals")
        default: break
        }
        return header
    }
 
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        switch section {
        case 1, 2: return CGSize(width: collectionView.bounds.width, height: 40)
        default:   return .zero
        }
    }
 
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        switch section {
        case 0:  return UIEdgeInsets(top: 12, left: 16, bottom: 4, right: 16)
        default: return UIEdgeInsets(top: 4, left: 16, bottom: 16, right: 16)
        }
    }
}
 
// MARK: - MealLogsCellDelegate
 
extension DietViewController: MealLogsCellDelegate {
    func didSelectMeal(_ food: Food) {
        FoodLogIngredientViewController.present(from: self, with: food)
    }
    func didRequestDeleteMeal(at index: Int) {
        deleteMeal(at: index)
    }
}
 
// MARK: - NutritionCellDelegate
 
extension DietViewController: NutritionCellDelegate {
    func didTapProteinView() {
        let storyboard = UIStoryboard(name: "Diet", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ChartViewController")
            as? ChartViewController {
            vc.macroType = .protein
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    func didTapCarbsView() {
        let storyboard = UIStoryboard(name: "Diet", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ChartViewController")
            as? ChartViewController {
            vc.macroType = .carbs
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    func didTapFatsView() {
        let storyboard = UIStoryboard(name: "Diet", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ChartViewController")
            as? ChartViewController {
            vc.macroType = .fats
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
 
// MARK: - AddMealDelegate
 
extension DietViewController: AddMealDelegate {
    func didAddMeal(_ food: Food) {
        FoodLogDataStore.addFoodBarCode(food)
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!
        if food.timeStamp >= startOfToday && food.timeStamp < startOfTomorrow {
            nutritionCell?.updateValues(food)
        }
        filterTodaysFoods()
        print("Added food: \(food.name)")
    }
}
 
// MARK: - AddDescribedMealDelegate
 
extension DietViewController: AddDescribedMealDelegate {
    func didConfirmMeal(_ food: Food) {
        print("didConfirmMeal called with: \(food.name)")
        FoodLogDataStore.addFoodBarCode(food)
        if presentedViewController != nil {
            dismiss(animated: true) { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
        filterTodaysFoods()
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!
        if food.timeStamp >= startOfToday && food.timeStamp < startOfTomorrow {
            nutritionCell?.updateValues(food)
        }
        print("Meal added successfully")
    }
}
