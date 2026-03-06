//
//  OnboardingPeriodLogViewController.swift
//  PCOS_App
//
//  Created by Abhinaya Rajarajan on 06/03/26.
//

import UIKit

class OnboardingPeriodLogViewController: UIViewController {

    // MARK: - UI
    private var collectionView: UICollectionView!
    private var continueButton: UIButton!
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!

    // MARK: - State
    private var selectedDates: Set<Date> = []
    private var displayedMonths: [Date] = []
    private let calendar = Calendar.current
    private var hasScrolledToCurrentMonth = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = UIColor(hex: "#FCEEED")
        setupLabels()
        setupDisplayedMonths()
        setupCollectionView()
        setupContinueButton()
        setupConstraints()
        loadSavedDates()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !hasScrolledToCurrentMonth, displayedMonths.count > 6 {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.scrollToItem(
                    at: IndexPath(item: 0, section: 6),
                    at: .top,
                    animated: false
                )
                self?.hasScrolledToCurrentMonth = true
            }
        }
    }

    // MARK: - Setup

    private func setupLabels() {
        titleLabel = UILabel()
        titleLabel.text = "When was your last period?"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel = UILabel()
        subtitleLabel.text = "Tap a date to start — we'll auto-select 5 days.\nLog all the periods you remember."
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
    }

    private func setupDisplayedMonths() {
        let today = Date()
        for i in -6...1 {
            if let month = calendar.date(byAdding: .month, value: i, to: today) {
                displayedMonths.append(month)
            }
        }
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 20, right: 8)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.layer.cornerRadius = 20
        collectionView.layer.masksToBounds = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = true

        collectionView.register(OnboardingCalendarDayCell.self, forCellWithReuseIdentifier: "DayCell")
        collectionView.register(
            OnboardingCalendarMonthHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "MonthHeader"
        )

        view.addSubview(collectionView)
    }

    private func setupContinueButton() {
        continueButton = UIButton(type: .system)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.backgroundColor = UIColor(hex: "#FE7A96")
        continueButton.layer.cornerRadius = 28
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        view.addSubview(continueButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            collectionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -16),

            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            continueButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    // MARK: - Data

    private func loadSavedDates() {
        // Load any already-saved period dates (e.g. from a previous onboarding visit)
        if let timestamps = UserDefaults.standard.array(forKey: "SavedPeriodDates") as? [TimeInterval] {
            selectedDates = Set(timestamps.map { calendar.startOfDay(for: Date(timeIntervalSince1970: $0)) })
        }
        collectionView.reloadData()
    }

    private func savePeriodDates(_ dates: [Date]) {
        let timestamps = dates.map { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(timestamps, forKey: "SavedPeriodDates")
        UserDefaults.standard.synchronize()
    }

    // MARK: - Actions

    @objc private func continueTapped() {
        guard !selectedDates.isEmpty else {
            let alert = UIAlertController(
                title: "No Dates Selected",
                message: "Please tap at least one period date, or tap Skip to continue.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            alert.addAction(UIAlertAction(title: "Skip", style: .cancel) { [weak self] _ in
                self?.performSegue(withIdentifier: "showHeight", sender: nil)
            })
            present(alert, animated: true)
            return
        }

        let sortedDates = selectedDates.sorted()
        savePeriodDates(sortedDates)
        CycleDataStore.shared.rebuildCycles(from: sortedDates)
        performSegue(withIdentifier: "showHeight", sender: nil)
    }

    // MARK: - Calendar Helpers

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
            if currentDate >= monthInterval.end && days.count >= 35 { break }
        }

        return days
    }

    private func isSelected(_ date: Date) -> Bool {
        selectedDates.contains(calendar.startOfDay(for: date))
    }

    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    private func selectDateRange(from startDate: Date, days: Int = 5) {
        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                selectedDates.insert(calendar.startOfDay(for: date))
            }
        }
    }

    private func contiguousBlock(containing date: Date) -> [Date] {
        var block = Set<Date>([date])
        var current = date
        while let prev = calendar.date(byAdding: .day, value: -1, to: current) {
            let normalized = calendar.startOfDay(for: prev)
            guard selectedDates.contains(normalized) else { break }
            block.insert(normalized)
            current = normalized
        }
        current = date
        while let next = calendar.date(byAdding: .day, value: 1, to: current) {
            let normalized = calendar.startOfDay(for: next)
            guard selectedDates.contains(normalized) else { break }
            block.insert(normalized)
            current = normalized
        }
        return block.sorted()
    }

    private func isNextDayAfterAnyBlock(_ date: Date) -> Bool {
        guard let previousDay = calendar.date(byAdding: .day, value: -1, to: date) else { return false }
        let normalizedPrev = calendar.startOfDay(for: previousDay)
        guard selectedDates.contains(normalizedPrev) else { return false }
        return contiguousBlock(containing: normalizedPrev).last == normalizedPrev
    }
}

// MARK: - UICollectionViewDataSource

extension OnboardingPeriodLogViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        displayedMonths.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        getDaysInMonth(for: displayedMonths[section]).count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! OnboardingCalendarDayCell
        let days = getDaysInMonth(for: displayedMonths[indexPath.section])
        if let date = days[indexPath.item] {
            cell.configure(with: date, isToday: isToday(date), isSelected: isSelected(date))
        } else {
            cell.configure(with: nil, isToday: false, isSelected: false)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "MonthHeader",
            for: indexPath
        ) as! OnboardingCalendarMonthHeader
        header.configure(with: displayedMonths[indexPath.section], showWeekdays: true)
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension OnboardingPeriodLogViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let days = getDaysInMonth(for: displayedMonths[indexPath.section])
        guard let selectedDate = days[indexPath.item] else { return }

        let normalized = calendar.startOfDay(for: selectedDate)
        let today = calendar.startOfDay(for: Date())

        if selectedDates.contains(normalized) {
            let block = contiguousBlock(containing: normalized)
            for date in block where date >= normalized {
                selectedDates.remove(date)
            }
        } else if isNextDayAfterAnyBlock(normalized) {
            selectedDates.insert(normalized)
        } else {
            guard normalized <= today else { return }
            selectDateRange(from: normalized, days: 5)
        }

        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension OnboardingPeriodLogViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 32) / 7
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 90)
    }
}

// MARK: - OnboardingCalendarDayCell

class OnboardingCalendarDayCell: UICollectionViewCell {

    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let selectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 22
        view.clipsToBounds = true
        return view
    }()

    private let checkmarkImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "checkmark")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isHidden = true
        return iv
    }()

    private var needsDashedBorder = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(selectionView)
        contentView.addSubview(dayLabel)
        contentView.addSubview(checkmarkImageView)
        NSLayoutConstraint.activate([
            selectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionView.widthAnchor.constraint(equalToConstant: 44),
            selectionView.heightAnchor.constraint(equalToConstant: 44),
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.centerXAnchor.constraint(equalTo: selectionView.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: selectionView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private let pink = UIColor(red: 254/255, green: 122/255, blue: 150/255, alpha: 1)

    override func layoutSubviews() {
        super.layoutSubviews()
        let r = selectionView.bounds.width > 0 ? selectionView.bounds.width / 2 : 22
        selectionView.layer.cornerRadius = r
        if needsDashedBorder { drawDashedBorder() }
    }

    func configure(with date: Date?, isToday: Bool, isSelected: Bool) {
        guard let date = date else {
            dayLabel.text = ""
            selectionView.isHidden = true
            checkmarkImageView.isHidden = true
            return
        }

        dayLabel.text = "\(Calendar.current.component(.day, from: date))"
        selectionView.isHidden = false
        removeDashedBorder()

        if isSelected {
            if isToday {
                selectionView.backgroundColor = pink
                selectionView.layer.borderColor = UIColor.clear.cgColor
                selectionView.layer.borderWidth = 0
                dayLabel.isHidden = true
                checkmarkImageView.isHidden = false
                checkmarkImageView.tintColor = .white
            } else {
                selectionView.backgroundColor = .clear
                selectionView.layer.borderColor = pink.cgColor
                selectionView.layer.borderWidth = 2
                addDashedBorder()
                dayLabel.isHidden = true
                checkmarkImageView.isHidden = false
                checkmarkImageView.tintColor = pink
            }
        } else {
            dayLabel.isHidden = false
            checkmarkImageView.isHidden = true
            selectionView.isHidden = true
            dayLabel.textColor = isToday ? pink : .black
            dayLabel.font = isToday
                ? .systemFont(ofSize: 16, weight: .semibold)
                : .systemFont(ofSize: 16)
        }
    }

    private func addDashedBorder() {
        needsDashedBorder = true
        selectionView.layer.borderWidth = 0
        setNeedsLayout()
    }

    private func drawDashedBorder() {
        selectionView.layer.sublayers?.removeAll(where: { $0.name == "DashedBorder" })
        guard selectionView.bounds.width > 0 else { return }
        let shape = CAShapeLayer()
        shape.name = "DashedBorder"
        shape.strokeColor = pink.cgColor
        shape.lineWidth = 2
        shape.lineDashPattern = [4, 4]
        shape.fillColor = UIColor.clear.cgColor
        shape.path = UIBezierPath(ovalIn: selectionView.bounds).cgPath
        selectionView.layer.addSublayer(shape)
    }

    private func removeDashedBorder() {
        needsDashedBorder = false
        selectionView.layer.sublayers?.removeAll(where: { $0.name == "DashedBorder" })
    }
}

// MARK: - OnboardingCalendarMonthHeader

class OnboardingCalendarMonthHeader: UICollectionReusableView {

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
        for day in ["S","M","T","W","T","F","S"] {
            let label = UILabel()
            label.text = day
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = .gray
            weekdayStackView.addArrangedSubview(label)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with date: Date, showWeekdays: Bool = false) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: date)
        weekdayStackView.isHidden = !showWeekdays
    }
}
