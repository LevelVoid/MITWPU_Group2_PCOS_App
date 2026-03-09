//
//  SleepReportViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 12/02/26.
//
import SwiftUI
import UIKit

class SleepReportViewController: UIViewController {

    @IBOutlet weak var observationCard: UIView!
    @IBOutlet weak var suggestionCard: UIView!
    @IBOutlet weak var chartContainerView: UIView!
    
  
    @IBOutlet weak var sleepInfoCard: UIView!
    @IBOutlet weak var dietRec: UIView!
    @IBOutlet weak var workoutRec: UIView!
    @IBOutlet weak var miscRec: UIView!
    
    @IBOutlet weak var logSleepButton: UIButton!
    private var dataPoints: [SleepChartDataModel] = []
    private var hostingController: UIHostingController<AnyView>?
    private var currentTimeRange: SleepChartTimeRange = .week
    private var chartID = UUID()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sleep Patterns"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupStyling()
        loadData(for: .week)
        setupChart()
        setupExistingLogButton()
    }
    

    private func setupExistingLogButton() {
        // Style the existing button found in the storyboard
        logSleepButton.setTitle("Log Your Sleep", for: .normal)
        logSleepButton.setTitleColor(.white, for: .normal)
        logSleepButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        logSleepButton.backgroundColor = UIColor(hex: "#FE7A96")
        logSleepButton.layer.cornerRadius = 20
        logSleepButton.addTarget(self, action: #selector(logSleepTapped), for: .touchUpInside)
    }

    @objc private func logSleepTapped() {
        guard let loggerVC = storyboard?.instantiateViewController(withIdentifier: "SleepLoggerViewController") as? SleepLoggerViewController else { return }

        loggerVC.isNotNowMode = true          // reuse the flag so we can override labels
        loggerVC.customTitle    = "Welcome"
        loggerVC.customSubtitle = "lets log your sleep"

        loggerVC.modalPresentationStyle = .pageSheet
        if let sheet = loggerVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }

        loggerVC.onSleepSaved = { [weak self] in
            guard let self = self else { return }
            // Reload chart now that a log exists
            self.loadData(for: self.currentTimeRange)
        }

        present(loggerVC, animated: true)
    }

    private func setupStyling() {
        view.backgroundColor = UIColor(hex: "#FCEEED")
        
        sleepInfoCard.layer.cornerRadius = 20
        observationCard.layer.cornerRadius = 20
        observationCard.backgroundColor = .white
        
        suggestionCard.layer.cornerRadius = 20
        suggestionCard.backgroundColor = .white
        
        chartContainerView.layer.cornerRadius = 16
        chartContainerView.backgroundColor = .white
        chartContainerView.layer.shadowColor = UIColor.black.cgColor
        chartContainerView.layer.shadowOpacity = 0.08
        chartContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        chartContainerView.layer.shadowRadius = 8
        
        setupSuggestionCard()
    }
    
    private func setupSuggestionCard() {
        // Clear existing subviews
        suggestionCard.subviews.forEach { $0.removeFromSuperview() }
    
        
        // Stack view for recommendations
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        suggestionCard.addSubview(stackView)
        
       
        let dietRow = makeSuggestionRow(
            imageName: "🥗",
            boldText: "Try a protein-rich dinner",
            regularText: " to reduce night cravings",
            
        )
        
        
        let workoutRow = makeSuggestionRow(
            imageName: "🚶‍♀️",
            boldText: "Try a 10-min evening walk",
            regularText: " can improve sleep quality",
            
        )
        
        let miscRow = makeSuggestionRow(
            imageName: "🪔",
            boldText: "Keep lights dim",
            regularText: " 1 hour before bed",
            
        )
        
        stackView.addArrangedSubview(dietRow)
        stackView.addArrangedSubview(workoutRow)
        stackView.addArrangedSubview(miscRow)
        
        
        // Constraints
        NSLayoutConstraint.activate([
            
            stackView.topAnchor.constraint(equalTo: suggestionCard.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: suggestionCard.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: suggestionCard.trailingAnchor, constant: -12),
            
        ])
    }

    private func makeSuggestionRow(imageName: String, boldText: String, regularText: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(hex: "#FCEEED").withAlphaComponent(0.5)
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Emoji label as image
        let emojiLabel = UILabel()
        emojiLabel.text = imageName
        emojiLabel.font = UIFont.systemFont(ofSize: 32)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Emoji background circle
        let emojiContainer = UIView()
        emojiContainer.translatesAutoresizingMaskIntoConstraints = false
        emojiContainer.layer.cornerRadius = 24
        emojiContainer.backgroundColor = .white
        emojiContainer.addSubview(emojiLabel)
        
        // Attributed text label
        let textLabel = UILabel()
        textLabel.numberOfLines = 0
        let attributed = NSMutableAttributedString(
            string: boldText,
            attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                         .foregroundColor: UIColor.black]
        )
        attributed.append(NSAttributedString(
            string: regularText,
            attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .regular),
                         .foregroundColor: UIColor.darkGray]
        ))
        textLabel.attributedText = attributed
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        let rightStack = UIStackView()
        rightStack.axis = .vertical
        rightStack.spacing = 6
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        rightStack.addArrangedSubview(textLabel)
        
      
        
        
        container.addSubview(emojiContainer)
        container.addSubview(rightStack)
        
        NSLayoutConstraint.activate([
            emojiContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            emojiContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            emojiContainer.widthAnchor.constraint(equalToConstant: 48),
            emojiContainer.heightAnchor.constraint(equalToConstant: 48),
            emojiContainer.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor, constant: 10),
            emojiContainer.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -10),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainer.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainer.centerYAnchor),
            
            rightStack.leadingAnchor.constraint(equalTo: emojiContainer.trailingAnchor, constant: 10),
            rightStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            rightStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            rightStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),
        ])
        
        return container
    }

    private func makeTag(text: String) -> UIView {
        let tag = UIView()
        tag.backgroundColor = UIColor(hex: "#FCEEED")
        tag.layer.cornerRadius = 10
        tag.layer.borderWidth = 1
        tag.layer.borderColor = UIColor(hex: "#FE7A96").withAlphaComponent(0.3).cgColor
        
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        tag.addSubview(label)
        tag.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: tag.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: tag.bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: tag.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: tag.trailingAnchor, constant: -8),
        ])
        
        return tag
    }

    
    
    
    @IBAction func timeSegmentChanged(_ sender: UISegmentedControl) {
        print("Segment changed to index: \(sender.selectedSegmentIndex)")
        
        switch sender.selectedSegmentIndex {
        case 0:
            currentTimeRange = .week
        case 1:
            currentTimeRange = .month
        case 2:
            currentTimeRange = .year
        default:
            currentTimeRange = .week
        }
        
        print("Loading data for: \(currentTimeRange.title)")
        loadData(for: currentTimeRange)
    }
    
    
    private func loadData(for range: SleepChartTimeRange) {
        currentTimeRange = range
        let calendar = Calendar.current
        let now = Date()
        var newData: [SleepChartDataModel] = []
        
        print("Loading data for range: \(range.title)")
        
        switch range {
        case .week:
            // Last 7 days
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE"
            
            for dayOffset in (0..<7).reversed() {
                if let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) {
                    let hours = getDailySleep(on: date)
                    newData.append(SleepChartDataModel(
                        date: date,
                        hours: hours,
                        label: dateFormatter.string(from: date)
                    ))
                }
            }
            
        case .month:
            // Last 4 weeks average
            for weekOffset in (0..<4).reversed() {
                if let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: now) {
                    let hours = getWeeklyAverage(startingFrom: weekStart)
                    newData.append(SleepChartDataModel(
                        date: weekStart,
                        hours: hours,
                        label: "W\(4 - weekOffset)"
                    ))
                }
            }
            
        case .year:
            // Last 12 months average
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM"
            
            for monthOffset in (0..<12).reversed() {
                if let date = calendar.date(byAdding: .month, value: -monthOffset, to: now) {
                    let hours = getMonthlyAverage(in: date)
                    newData.append(SleepChartDataModel(
                        date: date,
                        hours: hours,
                        label: dateFormatter.string(from: date)
                    ))
                }
            }
        }
        
        self.dataPoints = newData.sorted { $0.date < $1.date }
        
        print("Loaded \(dataPoints.count) data points")
        updateChart()
    }
    
    // MARK: - Data Calculation Helpers
    private func getDailySleep(on date: Date) -> Double {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        if let entry = SleepDataSource.sleepEntries.first(where: {
            $0.date >= startOfDay && $0.date < endOfDay
        }) {
            return entry.sleepHours
        }
        
        return 0
    }
    
    private func getWeeklyAverage(startingFrom date: Date) -> Double {
        let calendar = Calendar.current
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: date)!
        
        let weekEntries = SleepDataSource.sleepEntries.filter {
            $0.date >= date && $0.date < endOfWeek
        }
        
        let total = weekEntries.reduce(0.0) { $0 + $1.sleepHours }
        return weekEntries.isEmpty ? 0 : total / Double(weekEntries.count)
    }
    
    private func getMonthlyAverage(in date: Date) -> Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1), to: startOfMonth) else {
            return 0
        }
        
        let monthEntries = SleepDataSource.sleepEntries.filter {
            $0.date >= startOfMonth && $0.date < endOfMonth
        }
        
        let total = monthEntries.reduce(0.0) { $0 + $1.sleepHours }
        let daysInMonth = calendar.dateComponents([.day], from: startOfMonth, to: endOfMonth).day ?? 30
        return daysInMonth > 0 ? total / Double(daysInMonth) : 0
    }
    
    private func setupChart() {
        guard let chartContainerView = chartContainerView else {
            print("chartContainerView outlet is nil!")
            return
        }
        
        let swiftUIView = SleepChartView(
            dataPoints: dataPoints,
            timeRange: currentTimeRange
        )
        .padding(.top, 56)
        
        let hosting = UIHostingController(rootView: AnyView(swiftUIView))
        
        addChild(hosting)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        hosting.view.backgroundColor = .clear
        
        chartContainerView.addSubview(hosting.view)
        
        chartContainerView.sendSubviewToBack(hosting.view)
    
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: chartContainerView.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: chartContainerView.bottomAnchor)
        ])
        
        hosting.didMove(toParent: self)
        self.hostingController = hosting
    }

    private func updateChart() {
        print("Updating chart with \(dataPoints.count) points for range: \(currentTimeRange.title)")
        
        let swiftUIView = SleepChartView(
            dataPoints: dataPoints,
            timeRange: currentTimeRange
        )
        .padding(.top, 56)
        
        hostingController?.rootView = AnyView(swiftUIView)
    }
}



