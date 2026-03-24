//
//  MacroChartView.swift
//  PCOS_App
//
//  Created by SDC-USER on 21/01/26.
//

import SwiftUI
import Charts

struct MacroChartView: View {
    let dataPoints: [MacroChartDataPoint]
    let macroType: MacroType
    let timeRange: MacroChartTimeRange
    let goalValue: Double
    private var dailyTotal: Double {
        dataPoints.map { $0.value }.reduce(0, +)
    }

    
    private var currentAverage: Double {
        guard !dataPoints.isEmpty else { return 0 }
        return dataPoints.map { $0.value }.reduce(0, +) / Double(dataPoints.count)
    }
    
    private var shouldShowGoalLine: Bool {
        return true
    }
    
    private var displayGoalValue: Double {
        return goalValue
    }
    
    private var maxChartValue: Double {
        let maxDataValue = dataPoints.map { $0.value }.max() ?? 0
        let referenceValue = shouldShowGoalLine ? displayGoalValue : maxDataValue
        let maxValue = max(maxDataValue, referenceValue)
        return maxValue * 1.2
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with current average and unit
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(timeRange == .day ? "Today's Total" : "Average")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(Int(timeRange == .day ? dailyTotal : currentAverage))")
                            .font(.system(size: 24, weight: .bold))
                        Text(macroType.unit)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Goal info
                if shouldShowGoalLine {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Goal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(Int(displayGoalValue))")
                                .font(.system(size: 16, weight: .semibold))
                            Text(macroType.unit)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // Chart
            if dataPoints.isEmpty {
                VStack(alignment: .center, spacing: 12) {
                    Spacer()
                    Image(systemName: timeRange == .day ? "fork.knife" : "chart.bar.xaxis")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary.opacity(0.4))
                    Text(timeRange == .day ? "No meals logged today" : "No data available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if timeRange == .day {
                        Text("Add a meal to see your \(macroType.title.lowercased()) breakdown")
                            .font(.caption)
                            .foregroundColor(.secondary.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity) 
                .frame(height: 220)
            } else {
                Chart {
                    ForEach(dataPoints) { dataPoint in
                        BarMark(
                            x: .value("Period", dataPoint.label),
                            y: .value("Amount", dataPoint.value),
                            width: timeRange == .day ? .fixed(28) : .automatic
                        )
                        .foregroundStyle(macroType.color.gradient)
                        .cornerRadius(6)
                    }
                    
                    // Goal line (only show for week, month, year)
                    if shouldShowGoalLine {
                        RuleMark(y: .value("Goal", displayGoalValue))
                            .foregroundStyle(.gray)
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    }
                }
                .frame(height: 220)
                .chartYScale(domain: 0...maxChartValue)
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text("\(Int(doubleValue))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.gray.opacity(0.2))
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let label = value.as(String.self) {
                                Text(label)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 16)
            }
        }
        .background(Color(.systemBackground))
    }
}
