//
//  WorkoutPushViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/01/26.
//

import UIKit

class WorkoutPushViewController: UIViewController {
    
    var recommendation: Recommendation?

    @IBOutlet weak var WarningLabel: UIView!
    
    @IBOutlet weak var workoutOverviewCard: UIView!
    @IBOutlet weak var WorkoutDonutChart: WorkoutPieChart!
    
    @IBOutlet weak var StrengthTrainingInfo: UIView!
    
    
//    @IBOutlet weak var barProgressView: UIView!
//    @IBOutlet weak var idealWorkoutBarChart: WorkoutProgressBarCardView!
//    @IBOutlet weak var currentWorkoutBarChart: WorkoutProgressBarCardView!
    
    @IBOutlet weak var legendView: UIView!
    
    override func viewDidLoad() {
            super.viewDidLoad()
        
        if let rec = recommendation {
            print("Workout recommendation: \(rec.title)")
            title=rec.title
        }
            
            WarningLabel.layer.cornerRadius = 20
            workoutOverviewCard.layer.cornerRadius = 20
            
            StrengthTrainingInfo.layer.cornerRadius = 20
            
            //barProgressView.layer.cornerRadius = 20

            addWorkoutPieChart()
            
            addIdealWorkoutBarChart()
            addcurrentWorkoutBarChart()
            
            // Add legend to the legendView outlet
            //setupLegend()
        }
        
        private func addWorkoutPieChart() {
            // Clear container
            WorkoutDonutChart.subviews.forEach { $0.removeFromSuperview() }
            
            // Create chart
            let chartView = WorkoutPieChartView()
            chartView.translatesAutoresizingMaskIntoConstraints = false
            WorkoutDonutChart.addSubview(chartView)
            
            // Configure
            let workoutData: [WorkoutPieChart.WorkoutData] = [
                WorkoutPieChart.WorkoutData(name: "Cardio", value: 5, color: .systemCyan),
                WorkoutPieChart.WorkoutData(name: "Strength", value: 2, color: .systemOrange),
                WorkoutPieChart.WorkoutData(name: "Yoga", value: 1, color: .systemYellow)
            ]
            
            chartView.configure(with: workoutData)
        }

        private func addIdealWorkoutBarChart() {
//            let segments: [WorkoutOverviewBarChart.SegmentData] = [
//                WorkoutOverviewBarChart.SegmentData(
//                    name: "Strength Training",
//                    value: 3,
//                    color: UIColor(hex: "FF9500")
//                ),
//                WorkoutOverviewBarChart.SegmentData(
//                    name: "Cardio",
//                    value: 3,
//                    color: UIColor(hex: "D1D1D6")
//                )
//            ]
            
            // Configure the outlet directly
            //idealWorkoutBarChart.configure(with: segments)
        }
        
        private func addcurrentWorkoutBarChart() {
//            let segmentsCurrent: [WorkoutOverviewBarChart.SegmentData] = [
//                WorkoutOverviewBarChart.SegmentData(
//                    name: "Strength Training",
//                    value: 2,
//                    color: UIColor(hex: "FF9500")
//                ),
//                WorkoutOverviewBarChart.SegmentData(
//                    name: "Cardio",
//                    value: 5,
//                    color: UIColor(hex: "D1D1D6")
//                )
//            ]
            
            // Configure the outlet directly
            //currentWorkoutBarChart.configure(with: segmentsCurrent)
        }
        
        private func setupLegend() {
            // Define segments for legend (same as bar charts)
            let segments: [WorkoutOverviewBarChart.SegmentData] = [
                WorkoutOverviewBarChart.SegmentData(
                    name: "Strength Training",
                    value: 3,
                    color: UIColor(hex: "FF9500")
                ),
                WorkoutOverviewBarChart.SegmentData(
                    name: "Cardio",
                    value: 3,
                    color: UIColor(hex: "D1D1D6")
                )
            ]
            
            // Clear any existing views
            legendView.subviews.forEach { $0.removeFromSuperview() }
            
            // Create and add legend
            let legend = createLegendView(segments: segments)
            legendView.addSubview(legend)
        }
        
        private func createLegendView(segments: [WorkoutOverviewBarChart.SegmentData]) -> UIView {
            let legendContainer = UIView()
            legendContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.alignment = .center
            stackView.spacing = 12
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            for segment in segments {
                let itemView = UIView()
                itemView.translatesAutoresizingMaskIntoConstraints = false
                
                // for color dot
                let dotView = UIView()
                dotView.backgroundColor = segment.color
                dotView.layer.cornerRadius = 5
                dotView.translatesAutoresizingMaskIntoConstraints = false
                
                // for Label
                let label = UILabel()
                label.text = segment.name
                label.font = .systemFont(ofSize: 10, weight: .regular)
                label.textColor = .label
                label.numberOfLines = 1
                label.translatesAutoresizingMaskIntoConstraints = false
                
                itemView.addSubview(dotView)
                itemView.addSubview(label)
                
                NSLayoutConstraint.activate([
                    dotView.leadingAnchor.constraint(equalTo: itemView.leadingAnchor),
                    dotView.centerYAnchor.constraint(equalTo: itemView.centerYAnchor),
                    dotView.widthAnchor.constraint(equalToConstant: 10),
                    dotView.heightAnchor.constraint(equalToConstant: 10),
                    
                    label.leadingAnchor.constraint(equalTo: dotView.trailingAnchor, constant: 8),
                    label.centerYAnchor.constraint(equalTo: itemView.centerYAnchor),
                    label.trailingAnchor.constraint(lessThanOrEqualTo: itemView.trailingAnchor)
                ])
                
                stackView.addArrangedSubview(itemView)
            }
            
            legendContainer.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: legendContainer.topAnchor, constant: 8),
                stackView.leadingAnchor.constraint(equalTo: legendContainer.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: legendContainer.trailingAnchor),
                //stackView.bottomAnchor.constraint(equalTo: legendContainer.bottomAnchor, constant: -16)
            ])
            
            return legendContainer
        }
    }

