import UIKit

class DietCalendarLogsViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var mealDates: Set<Date> = []
    private var displayedMonths: [Date] = []
    private let calendar = Calendar.current
    private var hasScrolledToCurrentMonth = false
    private var selectedDate: Date? // Track selected date
    
    // Keep reference to the modal
    private weak var mealDetailVC: DayLoggedMealViewController?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Diet Logs"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupDisplayedMonths()
        setupCollectionView()
        setupUI()
        loadMealDates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        loadMealDates()
        collectionView.reloadData()
    }

    private func setupDisplayedMonths() {
        let today = Date()
        for i in -6...6 {
            if let month = calendar.date(byAdding: .month, value: i, to: today) {
                displayedMonths.append(month)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !hasScrolledToCurrentMonth && displayedMonths.count > 6 {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.scrollToItem(at: IndexPath(item: 0, section: 6), at: .top, animated: false)
                self?.hasScrolledToCurrentMonth = true
            }
        }
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 20, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = true
        
        collectionView.register(MealCalendarDayCell.self, forCellWithReuseIdentifier: "DayCell")
        collectionView.register(MealCalendarMonthHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MonthHeader")
        
        view.addSubview(collectionView)
    }
    
    private func setupUI() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Data Loading
    private func loadMealDates() {
        mealDates = FoodLogDataStore.allMealDates()
        print("DEBUG: Loaded \(mealDates.count) dates with meals from Core Data")
    }
    
    // MARK: - Helper Methods
    private func getDaysInMonth(for date: Date) -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        var currentDate = monthFirstWeek.start
        
        while days.count < 42 {
            if calendar.isDate(currentDate, equalTo: date, toGranularity: .month) {
                days.append(currentDate)
            } else if currentDate < monthInterval.start {
                days.append(nil)
            } else if currentDate >= monthInterval.end {
                days.append(nil)
            }
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
            
            if currentDate >= monthInterval.end && days.count >= 35 {
                break
            }
        }
        
        return days
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    private func hasMeals(_ date: Date) -> Bool {
        mealDates.contains(calendar.startOfDay(for: date))
    }
    
    private func showMealDetail(for date: Date) {
        // If modal is already presented, dismiss it first
        if presentedViewController != nil {
            dismiss(animated: false) { [weak self] in
                self?.presentMealDetailModal(for: date)
            }
        } else {
            presentMealDetailModal(for: date)
        }
    }
    
    private func presentMealDetailModal(for date: Date) {
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "MealDetailVC") as? DayLoggedMealViewController {
            detailVC.selectedDate = date
            detailVC.modalPresentationStyle = .pageSheet
            
            if let sheet = detailVC.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersGrabberVisible = true
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheet.largestUndimmedDetentIdentifier = .medium
                }
            }
            
            mealDetailVC = detailVC
            present(detailVC, animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension DietCalendarLogsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return displayedMonths.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let monthDate = displayedMonths[section]
        return getDaysInMonth(for: monthDate).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! MealCalendarDayCell
        
        let monthDate = displayedMonths[indexPath.section]
        let days = getDaysInMonth(for: monthDate)
        
        if let date = days[indexPath.item] {
            let isSelected = selectedDate != nil && calendar.isDate(date, inSameDayAs: selectedDate!)
            cell.configure(
                with: date,
                isToday: isToday(date),
                isSelected: isSelected,
                hasMeals: hasMeals(date)
            )
        } else {
            cell.configure(with: nil, isToday: false, isSelected: false, hasMeals: false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let monthHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MonthHeader", for: indexPath) as! MealCalendarMonthHeader
        let monthDate = displayedMonths[indexPath.section]
        
        monthHeader.configure(with: monthDate)
        
        return monthHeader
    }
}

// MARK: - UICollectionViewDelegate
extension DietCalendarLogsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let monthDate = displayedMonths[indexPath.section]
        let days = getDaysInMonth(for: monthDate)
        
        guard let selectedDate = days[indexPath.item] else { return }
        
        // Update selected date and reload to show selection
        self.selectedDate = selectedDate
        collectionView.reloadData()
        
        print("DEBUG: Selected date: \(selectedDate)")
        showMealDetail(for: selectedDate)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DietCalendarLogsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 32) / 7
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 90)
    }
}

// MARK: - MealCalendarDayCell
class MealCalendarDayCell: UICollectionViewCell {

    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let backgroundCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private let mealDot: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0)
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(backgroundCircle)
        contentView.addSubview(dayLabel)
        contentView.addSubview(mealDot)
        
        NSLayoutConstraint.activate([
            backgroundCircle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backgroundCircle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            backgroundCircle.widthAnchor.constraint(equalToConstant: 44),
            backgroundCircle.heightAnchor.constraint(equalToConstant: 44),
            
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            mealDot.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            mealDot.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 2),
            mealDot.widthAnchor.constraint(equalToConstant: 6),
            mealDot.heightAnchor.constraint(equalToConstant: 6)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundCircle.layer.cornerRadius = 22 // Half of 44
    }
    
    func configure(with date: Date?, isToday: Bool, isSelected: Bool, hasMeals: Bool) {
        guard let date = date else {
            dayLabel.text = ""
            backgroundCircle.isHidden = true
            mealDot.isHidden = true
            return
        }
        
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        dayLabel.text = "\(day)"
        
        // Reset border
        backgroundCircle.layer.borderWidth = 0
        backgroundCircle.layer.borderColor = nil
        
        if isSelected {
            // Selected date: Pink filled circle with white text
            backgroundCircle.isHidden = false
            backgroundCircle.backgroundColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0)
            dayLabel.textColor = .white
            dayLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        } else if isToday {
            // Today (not selected): Pink outline circle
            backgroundCircle.isHidden = false
            backgroundCircle.backgroundColor = .clear
            backgroundCircle.layer.borderWidth = 2
            backgroundCircle.layer.borderColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0).cgColor
            dayLabel.textColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0)
            dayLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        } else {
            // Regular day
            backgroundCircle.isHidden = true
            dayLabel.textColor = .black
            dayLabel.font = .systemFont(ofSize: 16)
        }
        
        // Show meal dot if meals are logged
        mealDot.isHidden = !hasMeals
    }
}

// MARK: - MealCalendarMonthHeader
class MealCalendarMonthHeader: UICollectionReusableView {
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let weekdayStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(monthLabel)
        addSubview(weekdayStackView)
        
        NSLayoutConstraint.activate([
            monthLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            monthLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            
            weekdayStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            weekdayStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            weekdayStackView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 15),
            weekdayStackView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
        for weekday in weekdays {
            let label = UILabel()
            label.text = weekday
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = .gray
            weekdayStackView.addArrangedSubview(label)
        }
    }
    
    func configure(with date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: date)
    }
}
