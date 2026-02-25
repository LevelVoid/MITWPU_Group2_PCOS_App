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

    // The quote card — added directly as a subview of the tableView, not a cell
    private var quoteCardView: UIView?

    private let quotes = [
        "Nourish your body — log a wholesome meal to get started.",
        "Healthy eating begins with one mindful meal. Start today.",
        "Your body works hard for you. Feed it something good today.",
        "A balanced meal is the best thing you can do for yourself right now.",
        "Small steps lead to big change. Log your first meal today."
    ]
    private var currentQuote = ""

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Diet"
        navigationController?.navigationBar.prefersLargeTitles = true
        setupNavigation()
        setupTableView()
        setupAddButtonStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        currentQuote = quotes.randomElement() ?? quotes[0]
        filterTodaysFoods()
        for i in FoodLogDataSource.todaysMeal {
            print(i.name)
        }
    }

    // viewDidLayoutSubviews ensures the quote card Y is always correct
    // even after the navigation bar / safe area finishes settling
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateQuoteCardFrame()
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

    private func setupTableView() {
        tableView.register(LogsTableViewCell.nib(), forCellReuseIdentifier: LogsTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = 100
        tableView.separatorStyle = .none
        tableView.register(NutritionHeader.nib(), forHeaderFooterViewReuseIdentifier: NutritionHeader.identifier)
    }

    private func setupAddButtonStyle() {
        AddMealButton.backgroundColor = UIColor.systemPink
        AddMealButton.setTitle("Add", for: .normal)
        AddMealButton.setTitleColor(.white, for: .normal)
        AddMealButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        AddMealButton.layer.cornerRadius = 25
        AddMealButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
    }

    // MARK: - Quote Card (custom UIView, not a cell)

    private func showQuoteCard() {
        removeQuoteCard()

        let tableWidth = tableView.bounds.width
        let sideInset: CGFloat = 12
        let verticalGap: CGFloat = 6
        let cardHeight: CGFloat = 100
        let wrapperHeight = cardHeight + (verticalGap * 2)

        // Y position: right after the section header (250pt)
        // We use the actual rendered header bottom if available, else fall back to 250
        let headerBottom: CGFloat = {
            if let hf = tableView.headerView(forSection: 0) {
                return hf.frame.maxY
            }
            return 250
        }()

        let wrapper = UIView(frame: CGRect(
            x: 0,
            y: headerBottom,
            width: tableWidth,
            height: wrapperHeight
        ))
        wrapper.backgroundColor = .clear
        wrapper.tag = 9999   // tag so we can find and remove it later

        let card = UIView(frame: CGRect(
            x: sideInset,
            y: verticalGap,
            width: tableWidth - (sideInset * 2),
            height: cardHeight
        ))
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.masksToBounds = false
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 6

        let label = UILabel(frame: CGRect(
            x: 16,
            y: 0,
            width: card.bounds.width - 32,
            height: cardHeight
        ))
        label.text = currentQuote
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 0

        card.addSubview(label)
        wrapper.addSubview(card)
        tableView.addSubview(wrapper)
        quoteCardView = wrapper
    }

    private func removeQuoteCard() {
        quoteCardView?.removeFromSuperview()
        quoteCardView = nil
        // Also remove any lingering tagged views from previous sessions
        tableView.subviews.filter { $0.tag == 9999 }.forEach { $0.removeFromSuperview() }
    }

    /// Called from viewDidLayoutSubviews to keep the card flush with the header bottom
    private func updateQuoteCardFrame() {
        guard let card = quoteCardView else { return }
        let headerBottom: CGFloat = tableView.headerView(forSection: 0)?.frame.maxY ?? 250
        if card.frame.origin.y != headerBottom {
            card.frame.origin.y = headerBottom
        }
    }

    // MARK: - Actions

    @objc func calendarTapped() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "dietLogs") as? DietCalendarLogsViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Diet", bundle: nil)
        guard let addVC = storyboard.instantiateViewController(withIdentifier: "AddMealViewController") as? AddMealViewController else {
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
        todaysFoods = FoodLogDataSource.sampleFoods.filter {
            $0.timeStamp >= startOfToday && $0.timeStamp < startOfTomorrow
        }.sorted { $0.timeStamp > $1.timeStamp }

        tableView.reloadData()

        if todaysFoods.isEmpty {
            // Small delay so the section header has been laid out before we read its frame
            DispatchQueue.main.async {
                self.showQuoteCard()
            }
        } else {
            removeQuoteCard()
        }

        print("DietVC — found \(todaysFoods.count) foods for today")
    }

    // MARK: - Delete

    private func deleteMeal(at indexPath: IndexPath) {
        let mealToDelete = todaysFoods[indexPath.row]

        let alert = UIAlertController(
            title: "Delete Meal",
            message: "Are you sure you want to delete '\(mealToDelete.name)'?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }

            self.headerView?.subtractValues(mealToDelete)
            FoodLogDataSource.removeFood(mealToDelete)
            self.todaysFoods.remove(at: indexPath.row)

            if self.todaysFoods.isEmpty {
                // ✅ Crash fix: reloadData instead of deleteRows when last item deleted
                self.tableView.reloadData()
                DispatchQueue.main.async {
                    self.showQuoteCard()
                }
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
        return todaysFoods.count   // 0 when empty — quote card is a plain UIView, not a cell
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

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: NutritionHeader.identifier
        ) as! NutritionHeader
        header.configure()
        header.delegate = self
        self.headerView = header
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 250
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !todaysFoods.isEmpty
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard !todaysFoods.isEmpty else { return nil }

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            self?.deleteMeal(at: indexPath)
            done(true)
        }
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash.fill")

        let config = UISwipeActionsConfiguration(actions: [deleteAction])
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
        print("Added food: \(food.name)")
    }
}

// MARK: - AddDescribedMealDelegate

extension DietViewController: AddDescribedMealDelegate {
    func didConfirmMeal(_ food: Food) {
        print("🎉 didConfirmMeal called with: \(food.name)")
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
        print("Meal added successfully")
    }
}

// MARK: - NutritionHeaderDelegate

extension DietViewController: NutritionHeaderDelegate {
    func didTapProteinView() {
        let storyboard = UIStoryboard(name: "Diet", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ChartViewController") as? ChartViewController {
            vc.macroType = .protein
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func didTapCarbsView() {
        let storyboard = UIStoryboard(name: "Diet", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ChartViewController") as? ChartViewController {
            vc.macroType = .carbs
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func didTapFatsView() {
        let storyboard = UIStoryboard(name: "Diet", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ChartViewController") as? ChartViewController {
            vc.macroType = .fats
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
