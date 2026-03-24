//
//  ChartViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 21/01/26.
//

import UIKit
import SwiftUI

class ChartViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var contentView: UIView!
    var macroType: MacroType = .protein
    private var goalValue: Double = 0.0
       private var dataPoints: [MacroChartDataPoint] = []
       private var hostingController: UIHostingController<MacroChartView>?
       private var currentTimeRange: MacroChartTimeRange = .week
       
       // MARK: - Lifecycle
       override func viewDidLoad() {
           super.viewDidLoad()
           
           print("📊 ChartViewController loaded with macroType: \(macroType.title)")
           // Compute personalized goal from GoalEngine
           if let user = ProfileService.shared.buildUserProfile() {
               let goals = GoalEngine.generateGoals(for: user)
               switch macroType {
               case .protein:
                   goalValue = Double(Int(round(Double(goals.diet.startingProteinGrams) / 5.0)) * 5)
               case .carbs:
                   goalValue = Double(Int(round(Double(goals.diet.startingCarbsGrams) / 5.0)) * 5)
               case .fats:
                   goalValue = Double(Int(round(Double(goals.diet.startingFatsGrams) / 5.0)) * 5)
               }
           } else {
               // Fallback if profile not available
               switch macroType {
               case .protein: goalValue = 90
               case .carbs:   goalValue = 180
               case .fats:    goalValue = 60
               }
           }

           title = macroType.title
           navigationController?.navigationBar.prefersLargeTitles = false
           
           segmentedControl?.selectedSegmentIndex = 1  // Week
           segmentedControl?.addTarget(self, action: #selector(timeSegmentChanged(_:)), for: .valueChanged)
           
           // Setup styling first
           setupStyling()
           
           // Load initial data
           loadData(for: .week)
           
           // Setup UI
           setupChart()
           updateInsights()
       }
       
       // MARK: - Actions
       @objc func timeSegmentChanged(_ sender: UISegmentedControl) {
           let range = MacroChartTimeRange(rawValue: sender.selectedSegmentIndex) ?? .week
           currentTimeRange = range
           loadData(for: range)
           updateInsights()
       }
       
       // MARK: - Data Loading (MODEL LOGIC)
       private func loadData(for range: MacroChartTimeRange) {
           currentTimeRange = range
           let calendar = Calendar.current
           let now = Date()
           var newData: [MacroChartDataPoint] = []
           
           switch range {
           case .day:
               // Last 7 meals in chronological order
               let meals = Array(FoodLogDataStore.todaysMeal.sorted { $0.timeStamp < $1.timeStamp }.prefix(7))
               for (index, meal) in meals.enumerated() {
                   let value = getValue(from: meal)
                   newData.append(MacroChartDataPoint(
                       date: meal.timeStamp,
                       value: value,
                       label: "M\(index + 1)"
                   ))
               }
               
           case .week:
               // Last 7 days
               let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "EEE"
               
               for dayOffset in (0..<7).reversed() {
                   if let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) {
                       let value = getDailyTotal(on: date)
                       newData.append(MacroChartDataPoint(
                           date: date,
                           value: value,
                           label: dateFormatter.string(from: date)
                       ))
                   }
               }
               
           case .month:
               // Last 4 weeks
               for weekOffset in (0..<4).reversed() {
                   if let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: now) {
                       let value = getWeeklyAverage(startingFrom: weekStart)
                       newData.append(MacroChartDataPoint(
                           date: weekStart,
                           value: value,
                           label: "W\(4 - weekOffset)"
                       ))
                   }
               }
               
           case .year:
               // Last 12 months
               let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "MMM"
               
               for monthOffset in (0..<12).reversed() {
                   if let date = calendar.date(byAdding: .month, value: -monthOffset, to: now) {
                       let value = getMonthlyAverage(in: date)
                       newData.append(MacroChartDataPoint(
                           date: date,
                           value: value,
                           label: dateFormatter.string(from: date)
                       ))
                   }
               }
           }
           
           self.dataPoints = newData.sorted { $0.date < $1.date }
           
           // Update chart
           updateChart()
       }
       
       // MARK: - Data Calculation Helpers
       private func getValue(from food: Food) -> Double {
           switch macroType {
           case .protein: return food.proteinContent
           case .carbs: return food.carbsContent
           case .fats: return food.fatsContent
           }
       }
       
       private func getDailyTotal(on date: Date) -> Double {
           let calendar = Calendar.current
           let startOfDay = calendar.startOfDay(for: date)
           let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
           
           let dayMeals = FoodLogDataStore.sampleFoods.filter {
               $0.timeStamp >= startOfDay && $0.timeStamp < endOfDay
           }
           
           return dayMeals.reduce(0.0) { total, food in
               total + getValue(from: food)
           }
       }
       
       private func getWeeklyAverage(startingFrom date: Date) -> Double {
           let calendar = Calendar.current
           let endOfWeek = calendar.date(byAdding: .day, value: 7, to: date)!
           
           let weekMeals = FoodLogDataStore.sampleFoods.filter {
               $0.timeStamp >= date && $0.timeStamp < endOfWeek
           }
           
           let total = weekMeals.reduce(0.0) { total, food in
               total + getValue(from: food)
           }
           
           return weekMeals.isEmpty ? 0 : total / 7.0
       }
       
       private func getMonthlyAverage(in date: Date) -> Double {
           let calendar = Calendar.current
           let components = calendar.dateComponents([.year, .month], from: date)
           guard let startOfMonth = calendar.date(from: components),
                 let endOfMonth = calendar.date(byAdding: DateComponents(month: 1), to: startOfMonth) else {
               return 0
           }
           
           let monthMeals = FoodLogDataStore.sampleFoods.filter {
               $0.timeStamp >= startOfMonth && $0.timeStamp < endOfMonth
           }
           
           let total = monthMeals.reduce(0.0) { total, food in
               total + getValue(from: food)
           }
           
           let daysInMonth = calendar.dateComponents([.day], from: startOfMonth, to: endOfMonth).day ?? 30
           return daysInMonth > 0 ? total / Double(daysInMonth) : 0
       }
       
       // MARK: - View Setup (VIEW LOGIC)
       private func setupChart() {
           guard let chartView = chartView else {
               print("❌ chartView outlet is nil!")
               return
           }
           
           let swiftUIView = MacroChartView(
               dataPoints: dataPoints,
               macroType: macroType,
               timeRange: currentTimeRange,
               goalValue: goalValue
           )
           let hosting = UIHostingController(rootView: swiftUIView)
           
           addChild(hosting)
           hosting.view.frame = chartView.bounds
           hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
           hosting.view.backgroundColor = .clear
           
           chartView.addSubview(hosting.view)
           hosting.didMove(toParent: self)
           
           self.hostingController = hosting
       }
       
       private func updateChart() {
           let swiftUIView = MacroChartView(
               dataPoints: dataPoints,
               macroType: macroType,
               timeRange: currentTimeRange,
               goalValue: goalValue
           )
           hostingController?.rootView = swiftUIView
       }
       
       private func setupStyling() {
           // Chart view styling
           chartView?.layer.cornerRadius = 16
           chartView?.clipsToBounds = true
           chartView?.backgroundColor = .white
           contentView.layer.cornerRadius = 16
       }
       
       private func updateInsights() {
           contentLabel?.text =  getImportanceText()
       }
       
       private func getImportanceText() -> String {
           switch macroType {
           case .protein:
               return "Protein helps regulate insulin levels, supports muscle health, and keeps you feeling full longer—essential for managing PCOS symptoms."
           case .carbs:
               return "Balanced carbohydrate intake helps maintain stable blood sugar levels, which is crucial for managing insulin resistance in PCOS."
           case .fats:
               return "Healthy fats support hormone production and help reduce inflammation, both important factors in PCOS management."
           }
       }
       
   }
