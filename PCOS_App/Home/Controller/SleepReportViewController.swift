//
//  SleepReportViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 12/02/26.
//
import SwiftUI
import UIKit

class SleepReportViewController: UIViewController {

// MARK: - Properties
    @IBOutlet weak var observationCard: UIView!
    @IBOutlet weak var suggestionCard: UIView!
    @IBOutlet weak var chartContainerView: UIView!
    
    @IBOutlet weak var sleepInfoCard: UIView!
    
    
    @IBOutlet weak var logSleepButton: UIButton!
    
    private var dataPoints: [SleepChartDataModel] = [] {
        didSet { updateChart() }
    }
    
    private var currentTimeRange: SleepChartTimeRange = .week {
        didSet { updateChart() }
    }
    
    // UI Components for Programmatic conversion
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let segmentedControl = UISegmentedControl(items: ["Week", "Month", "Year"])
    private var nativeChartHostingController: UIHostingController<SleepChartView>?
    
    private let observedLabel = UILabel()
    private let observationLoadingIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation bar to use our custom top bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Remove all original storyboard ui elements entirely to prevent layout overlaps
        view.subviews.forEach { $0.removeFromSuperview() }
        
        setupProgrammaticUI()
        loadData(for: .week)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Only restore nav bar when popping, NOT when pushing/presenting
        if isMovingFromParent {
            navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }

    private func setupProgrammaticUI() {
        view.backgroundColor = UIColor(hex: "#FCEEED")
        
        // 1. Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        // 2. Navigation Header
        let navBar = setupNavigationBar()
        contentView.addSubview(navBar)
        
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            navBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            navBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            navBar.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // 2.5 Segmented Control
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
        let segContainer = UIView()
        segContainer.translatesAutoresizingMaskIntoConstraints = false
        segContainer.backgroundColor = UIColor(white: 0.9, alpha: 1) // basic pill background
        segContainer.layer.cornerRadius = 20
        segContainer.addSubview(segmentedControl)
        contentView.addSubview(segContainer)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: segContainer.topAnchor, constant: 2),
            segmentedControl.bottomAnchor.constraint(equalTo: segContainer.bottomAnchor, constant: -2),
            segmentedControl.leadingAnchor.constraint(equalTo: segContainer.leadingAnchor, constant: 2),
            segmentedControl.trailingAnchor.constraint(equalTo: segContainer.trailingAnchor, constant: -2),
            
            segContainer.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 24),
            segContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            segContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            segContainer.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // 3. Chart Card
        let chartCard = setupChartCard()
        contentView.addSubview(chartCard)
        
        NSLayoutConstraint.activate([
            chartCard.topAnchor.constraint(equalTo: segContainer.bottomAnchor, constant: 24),
            chartCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            chartCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        // 4. Observations Section
        let observationSection = setupObservationSection()
        contentView.addSubview(observationSection)
        
        NSLayoutConstraint.activate([
            observationSection.topAnchor.constraint(equalTo: chartCard.bottomAnchor, constant: 24),
            observationSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            observationSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        // 5. Importance Section
        let importanceSection = setupImportanceSection()
        contentView.addSubview(importanceSection)
        
        NSLayoutConstraint.activate([
            importanceSection.topAnchor.constraint(equalTo: observationSection.bottomAnchor, constant: 24),
            importanceSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            importanceSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            importanceSection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupNavigationBar() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let backBtn = UIButton(type: .system)
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backBtn.tintColor = .black
        backBtn.backgroundColor = .white
        backBtn.layer.cornerRadius = 22
        backBtn.layer.shadowColor = UIColor.black.cgColor
        backBtn.layer.shadowOpacity = 0.05
        backBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        backBtn.layer.shadowRadius = 5
        backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        let titleLbl = UILabel()
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.text = "Sleep Patterns"
        titleLbl.font = .systemFont(ofSize: 18, weight: .bold)
        titleLbl.textColor = .black
        titleLbl.textAlignment = .center
        
        let addBtn = UIButton(type: .system)
        addBtn.translatesAutoresizingMaskIntoConstraints = false
        addBtn.setImage(UIImage(systemName: "plus"), for: .normal)
        addBtn.tintColor = .black
        addBtn.backgroundColor = .white
        addBtn.layer.cornerRadius = 22
        addBtn.layer.shadowColor = UIColor.black.cgColor
        addBtn.layer.shadowOpacity = 0.05
        addBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        addBtn.layer.shadowRadius = 5
        addBtn.addTarget(self, action: #selector(presentSleepLogger), for: .touchUpInside)
        
        container.addSubview(backBtn)
        container.addSubview(titleLbl)
        container.addSubview(addBtn)
        
        NSLayoutConstraint.activate([
            backBtn.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            backBtn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            backBtn.widthAnchor.constraint(equalToConstant: 44),
            backBtn.heightAnchor.constraint(equalToConstant: 44),
            
            titleLbl.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLbl.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            addBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            addBtn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            addBtn.widthAnchor.constraint(equalToConstant: 44),
            addBtn.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        return container
    }
    
    private func setupChartCard() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        
        // Chart SwiftUI Host
        let chartHost = UIHostingController(rootView: SleepChartView(dataPoints: dataPoints, timeRange: currentTimeRange))
        nativeChartHostingController = chartHost
        
        addChild(chartHost)
        chartHost.view.translatesAutoresizingMaskIntoConstraints = false
        chartHost.view.backgroundColor = .clear
        card.addSubview(chartHost.view)
        chartHost.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            chartHost.view.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            chartHost.view.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            chartHost.view.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            chartHost.view.heightAnchor.constraint(equalToConstant: 300),
            chartHost.view.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        return card
    }
    
    private func setupObservationSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "What we observed"
        title.font = .systemFont(ofSize: 18, weight: .semibold)
        title.textColor = .black
        
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        
        observedLabel.translatesAutoresizingMaskIntoConstraints = false
        observedLabel.text = "Fetching daily insights..."
        observedLabel.font = .systemFont(ofSize: 15)
        observedLabel.textColor = .black
        observedLabel.numberOfLines = 0
        
        observationLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        observationLoadingIndicator.hidesWhenStopped = true
        
        card.addSubview(observedLabel)
        card.addSubview(observationLoadingIndicator)
        container.addSubview(title)
        container.addSubview(card)
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: container.topAnchor),
            title.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            title.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            
            card.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 12),
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            observedLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            observedLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            observedLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            observedLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
            
            observationLoadingIndicator.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            observationLoadingIndicator.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        
        return container
    }
    
    private func setupImportanceSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Why Sleep Is Important For PCOS"
        title.font = .systemFont(ofSize: 18, weight: .semibold)
        title.textColor = .black
        
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        
        let bodyLbl = UILabel()
        bodyLbl.translatesAutoresizingMaskIntoConstraints = false
        bodyLbl.text = "Sleep matters for hormone balance as sleep supports insulin stability. Less sleep can increase cravings and raise cortisol levels, worsening fatigue."
        bodyLbl.font = .systemFont(ofSize: 15)
        bodyLbl.textColor = .black
        bodyLbl.numberOfLines = 0
        
        let linkLbl = UILabel()
        linkLbl.translatesAutoresizingMaskIntoConstraints = false
        linkLbl.text = "National Library of Medicine"
        linkLbl.font = .systemFont(ofSize: 15)
        linkLbl.textColor = UIColor(hex: "#00A1F1")
        
        card.addSubview(bodyLbl)
        card.addSubview(linkLbl)
        
        container.addSubview(title)
        container.addSubview(card)
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: container.topAnchor),
            title.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            title.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            
            card.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 12),
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            bodyLbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            bodyLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            bodyLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            
            linkLbl.topAnchor.constraint(equalTo: bodyLbl.bottomAnchor, constant: 16),
            linkLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            linkLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            linkLbl.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        
        return container
    }
    
    private func updateChart() {
        nativeChartHostingController?.rootView = SleepChartView(dataPoints: dataPoints, timeRange: currentTimeRange)
    }

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: currentTimeRange = .week
        case 1: currentTimeRange = .month
        case 2: currentTimeRange = .year
        default: currentTimeRange = .week
        }
        loadData(for: currentTimeRange)
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func presentSleepLogger() {
        guard let loggerVC = storyboard?.instantiateViewController(withIdentifier: "SleepLoggerViewController") as? SleepLoggerViewController else { return }

        loggerVC.isNotNowMode = true
        loggerVC.modalPresentationStyle = .fullScreen

        loggerVC.onSleepSaved = { [weak self] in
            guard let self = self else { return }
            self.loadData(for: self.currentTimeRange)
        }

        present(loggerVC, animated: true)
    }
    
    private func loadData(for range: SleepChartTimeRange) {
        let newRange = range
        let calendar = Calendar.current
        let now = Date()
        
        // Define lookback period depending on range to fetch from HealthKit efficiently
        let startDate: Date
        switch range {
        case .week: startDate = calendar.date(byAdding: .day, value: -8, to: now)!
        case .month: startDate = calendar.date(byAdding: .day, value: -35, to: now)!
        case .year: startDate = calendar.date(byAdding: .month, value: -13, to: now)!
        }
        
        HealthKitManager.shared.fetchDailySleep(from: startDate, to: now) { [weak self] hkSleepByDay in
            guard let self = self else { return }
            
            var newData: [SleepChartDataModel] = []
            
            // Helper to determine single day hours: Manual inputs take priority
            let getHoursForDate: (Date) -> Double = { queryDate in
                let startOfDay = calendar.startOfDay(for: queryDate)
                
                // 1. Manual User Log (from Sleep Logger)
                if let manualLog = SleepDataStore.shared.loadSleepLog(for: queryDate) {
                    let interval = manualLog.wakeTime.timeIntervalSince(manualLog.sleepTime)
                    return max(0, interval / 3600.0) // hours
                }
                
                // 2. HealthKit Default
                return hkSleepByDay[startOfDay] ?? 0.0
            }
            
            switch range {
            case .week:
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE"
                // Find last Sunday (start of this week)
                var sundayComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
                sundayComponents.weekday = 1 // Sunday
                let sunday = calendar.date(from: sundayComponents) ?? now
                for dayOffset in 0..<7 {
                    if let date = calendar.date(byAdding: .day, value: dayOffset, to: sunday) {
                        let hours = getHoursForDate(date)
                        newData.append(SleepChartDataModel(
                            date: date,
                            hours: hours,
                            label: dateFormatter.string(from: date)
                        ))
                    }
                }
                
            case .month:
                // 4 weeks average
                for weekOffset in (0..<4).reversed() {
                    if let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: now) {
                        var totalHours = 0.0
                        var daysWithData = 0
                        
                        for i in 0..<7 {
                            if let dayDate = calendar.date(byAdding: .day, value: i, to: weekStart) {
                                let h = getHoursForDate(dayDate)
                                if h > 0 {
                                    totalHours += h
                                    daysWithData += 1
                                }
                            }
                        }
                        
                        let avg = daysWithData > 0 ? (totalHours / Double(daysWithData)) : 0
                        newData.append(SleepChartDataModel(
                            date: weekStart,
                            hours: avg,
                            label: "W\(4 - weekOffset)"
                        ))
                    }
                }
                
            case .year:
                // Always show Jan–Dec of current year for equidistant alignment
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM"
                let currentYear = calendar.component(.year, from: now)
                
                for month in 1...12 {
                    var comps = DateComponents()
                    comps.year = currentYear
                    comps.month = month
                    comps.day = 1
                    guard let startOfMonth = calendar.date(from: comps),
                          let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
                        continue
                    }
                    
                    let daysInMonth = calendar.dateComponents([.day], from: startOfMonth, to: endOfMonth).day ?? 30
                    var totalHours = 0.0
                    var daysWithData = 0
                    
                    for i in 0..<daysInMonth {
                        if let dayDate = calendar.date(byAdding: .day, value: i, to: startOfMonth) {
                            let h = getHoursForDate(dayDate)
                            if h > 0 {
                                totalHours += h
                                daysWithData += 1
                            }
                        }
                    }
                    
                    let avg = daysWithData > 0 ? (totalHours / Double(daysWithData)) : 0
                    newData.append(SleepChartDataModel(
                        date: startOfMonth,
                        hours: avg,
                        label: dateFormatter.string(from: startOfMonth)
                    ))
                }
            }
            
            let sortedData = newData.sorted { $0.date < $1.date }
            
            // Dispatch UI updates to main thread
            DispatchQueue.main.async {
                self.currentTimeRange = newRange
                self.dataPoints = sortedData
                print("Loaded \(sortedData.count) chart points from HealthKit and CoreData.")
                self.fetchAIInsights(for: sortedData)
            }
        }
    }
    
    private func fetchAIInsights(for chartData: [SleepChartDataModel]) {
        observedLabel.text = ""
        observationLoadingIndicator.startAnimating()
        
        let range = currentTimeRange
        Task {
            let insight = try await SleepObservationsModel.shared.fetchSleepInsight(chartData: chartData, timeRange: range)
            await MainActor.run {
                self.observationLoadingIndicator.stopAnimating()
                self.observedLabel.text = insight
            }
        }
    }
}



