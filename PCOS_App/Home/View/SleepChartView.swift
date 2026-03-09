//
//  SleepChartView.swift
//  PCOS_App
//
//  Created by SDC-USER on 12/02/26.
//

import SwiftUI
import Charts

struct SleepChartView: View {
    let dataPoints: [SleepChartDataModel]
    let timeRange: SleepChartTimeRange
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Chart {
                ForEach(dataPoints) { point in
                    BarMark(
                        x: .value("Time", point.label),
                        y: .value("Hours", point.hours)
                    )
                    .foregroundStyle(barColor(for: point.hours))
                    .cornerRadius(6)
                }
                
                RuleMark(y: .value("Goal", 7.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .foregroundStyle(Color(hex: "#FE7A96").opacity(0.4))
            }
            .chartYScale(domain: 0...10)
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 2.5, 5, 7.5, 10]) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color(hex: "#FE7A96").opacity(0.1))
                    AxisValueLabel {
                        if let hours = value.as(Double.self) {
                            Text("\(Int(hours))h")
                                .font(.caption2)
                                .foregroundColor(Color(hex: "#8B8B8B"))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let label = value.as(String.self) {
                            Text(label)
                                .font(.caption)
                                .foregroundColor(Color(hex: "#8B8B8B"))
                        }
                    }
                }
            }
            .frame(height: 200)
            .id(timeRange)
        }
        .padding(.horizontal, 8)
    }
    
    private func barColor(for hours: Double) -> Color {
        switch hours {
        case 7.5...10:
            return Color(hex: "#FE7A96")
        case 7.0..<7.5:
            return Color(hex: "#FE9BAD")
        case 6.0..<7.0:
            return Color(hex: "#FFC2D1")
        default:
            return Color(hex: "#FFE0E8")
        }
    }
}
