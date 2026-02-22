//
//  DietViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

class DietViewController: UIViewController {

    var todaysFoods: [Food] = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var AddMealButton: UIButton!

    private var headerView: NutritionHeader?
    private var emptyStateView: UIView?

    // Header height — must match what we set in setupNutritionHeader()
    private let headerHeight: CGFloat = 290

    private let quotes = [
        "Nourish your body — log a wholesome meal to get started.",
        "Healthy eating begins with one mindful meal. Start today.",
        "Your body works hard for you. Feed it something good today.",
        "A balanced meal is the best thing you can do for yourself right now.",
        "Small steps lead to big change. Log your first meal today."
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Diet"
        navigationController?.navigationBar.prefersLargeTitles = true
        setupNavigation()
        setupTableView()
        setupAddButtonStyle()
        setupNutritionHeader()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        filterTodaysFoods()
    }

    // MARK: - Setup

    private func setupNavigation() {
        let calendarBtn = UIBarButtonItem(
            image: UIImage(systemName: "calendar"),
            style: .plain,
            target: self,
            action: #selector(calendarTapped)
        )
        navigationItem.rightBarButtonItem = calendarBtn
    }

    private func setupTableView() {
        tableView.register(
            LogsTableViewCell.nib(),
            forCellReuseIdentifier: LogsTableViewCell.identifier
        )
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }

    private func setupNutritionHeader() {
        guard let header = NutritionHeader.nib()
            .instantiate(withOwner: nil, options: nil)
            .first as? NutritionHeader
        else { return }

        header.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerHeight)
        header.configure()
        header.delegate = self
        tableView.tableHeaderView = header
        headerView = header
    }

    private func setupAddButtonStyle() {
        AddMealButton.backgroundColor = UIColor.systemPink
        AddMealButton.setTitle("Add", for: .normal)
        AddMealButton.setTitleColor(.white, for: .normal)
        AddMealButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        AddMealButton.layer.cornerRadius = 25
        AddMealButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
    }

    // MARK: - Empty State

    private func showEmptyState() {
        hideEmptyState()

        let quote = quotes.randomElement() ?? quotes[0]
        let tableWidth = tableView.bounds.width

        // Card — matches LogsTableViewCell visual style exactly
        let cardHeight: CGFloat = 100
        let sidePadding: CGFloat = 0
        let verticalPadding: CGFloat = 0
        let wrapperHeight = cardHeight + (verticalPadding * 2)

        // Wrapper frame: starts exactly at headerHeight (after tableHeaderView ends)
        // Y is in the tableView scroll coordinate space
        let wrapperFrame = CGRect(
            x: 0,
            y: headerHeight,       // <-- KEY FIX: place below the header, not at 0
            width: tableWidth,
            height: wrapperHeight
        )

        let wrapper = UIView(frame: wrapperFrame)
        wrapper.backgroundColor = .clear

        let cardFrame = CGRect(
            x: sidePadding,
            y: verticalPadding,
            width: tableWidth - (sidePadding * 2),
            height: cardHeight
        )

        let card = UIView(frame: cardFrame)
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.masksToBounds = false
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 6

        let labelFrame = CGRect(
            x: 16,
            y: 0,
            width: cardFrame.width - 32,
            height: cardFrame.height
        )

        let label = UILabel(frame: labelFrame)
        label.text = quote
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 0

        card.addSubview(label)
        wrapper.addSubview(card)

        // Add as subview of tableView — frame-based, no Auto Layout conflicts
        tableView.addSubview(wrapper)
        emptyStateView = wrapper
    }

    private func hideEmptyState() {
        emptyStateView?.removeFromSuperview()
        emptyStateView = nil
    }

    // MARK: - Actions

    @objc func calendarTapped() {
        if let vc = storyboard?.instantiateViewController(
            withIdentifier: "dietLogs"
        ) as? DietCalendarLogsViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Diet", bundle: nil)
        guard let addVC = sb.instantiateViewController(
            withIdentifier: "AddMealViewController"
        ) as? AddMealViewController else {
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
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!

        todaysFoods = FoodLogDataSource.sampleFoods
            .filter { $0.timeStamp >= startOfToday && $0.timeStamp < startOfTomorrow }
            .sorted { $0.timeStamp > $1.timeStamp }

        tableView.reloadData()

        if todaysFoods.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }

        print("DietVC — found \(todaysFoods.count) foods for today")
    }

    // MARK: - Delete

    private func deleteMeal(at indexPath: IndexPath) {
        let meal = todaysFoods[indexPath.row]

        let alert = UIAlertController(
            title: "Delete Meal",
            message: "Are you sure you want to delete '\(meal.name)'?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }

            self.headerView?.subtractValues(meal)
            FoodLogDataSource.removeFood(meal)
            self.todaysFoods.remove(at: indexPath.row)

            if self.todaysFoods.isEmpty {
                self.tableView.reloadData()
                self.showEmptyState()
            } else {
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        })

        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension DietViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todaysFoods.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: LogsTableViewCell.identifier,
            for: indexPath
        ) as! LogsTableViewCell
        cell.configure(with: todaysFoods[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !todaysFoods.isEmpty else { return }
        FoodLogIngredientViewController.present(from: self, with: todaysFoods[indexPath.row])
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !todaysFoods.isEmpty
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard !todaysFoods.isEmpty else { return nil }

        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            self?.deleteMeal(at: indexPath)
            done(true)
        }
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash.fill")

        let config = UISwipeActionsConfiguration(actions: [delete])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}

// MARK: - AddMealDelegate

extension DietViewController: AddMealDelegate {
    func didAddMeal(_ food: Food) {
        FoodLogDataSource.addFoodBarCode(food)
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!
        if food.timeStamp >= startOfToday && food.timeStamp < startOfTomorrow {
            headerView?.updateValues(food)
        }
        filterTodaysFoods()
    }
}

// MARK: - AddDescribedMealDelegate

extension DietViewController: AddDescribedMealDelegate {
    func didConfirmMeal(_ food: Food) {
        FoodLogDataSource.addFoodBarCode(food)
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
            headerView?.updateValues(food)
        }
    }
}

// MARK: - NutritionHeaderDelegate

extension DietViewController: NutritionHeaderDelegate {
    func didTapProteinView() {
        let sb = UIStoryboard(name: "Diet", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ChartViewController") as? ChartViewController {
            vc.macroType = .protein
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func didTapCarbsView() {
        let sb = UIStoryboard(name: "Diet", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ChartViewController") as? ChartViewController {
            vc.macroType = .carbs
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func didTapFatsView() {
        let sb = UIStoryboard(name: "Diet", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "ChartViewController") as? ChartViewController {
            vc.macroType = .fats
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
