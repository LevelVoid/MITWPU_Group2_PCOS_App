//
//  SleepDataModels.swift
//  PCOS_App
//
//  Created by SDC-USER on 12/02/26.
//

import Foundation

// MARK: - Sleep Data Point
struct SleepChartDataModel: Identifiable {
    let id = UUID()
    let date: Date
    let hours: Double  // Sleep duration in hours
    let label: String  // Display label (e.g., "Mon", "W1", "Jan")
}

// MARK: - Sleep Time Range
enum SleepChartTimeRange: Int, CaseIterable {
    case week = 0
    case month = 1
    case year = 2
    
    var title: String {
        switch self {
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }
}

// MARK: - Sleep Entry
struct SleepEntry {
    let date: Date
    let sleepHours: Double
    let quality: SleepQuality
    
    enum SleepQuality: String {
        case poor = "Poor"
        case fair = "Fair"
        case good = "Good"
        case excellent = "Excellent"
    }
}

// MARK: - Dummy Data Source
class SleepDataSource {
    static var sleepEntries: [SleepEntry] = generateDummyData()
    
    private static func generateDummyData() -> [SleepEntry] {
        var entries: [SleepEntry] = []
        let calendar = Calendar.current
        let now = Date()
        
        // Generate last 365 days of sleep data
        for dayOffset in 0..<365 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) {
                // Random sleep hours between 4.5-9 hours
                let sleepHours = Double.random(in: 4.5...9.0)
                
                // Determine quality based on hours
                let quality: SleepEntry.SleepQuality
                switch sleepHours {
                case 7.5...10:
                    quality = .excellent
                case 7.0..<7.5:
                    quality = .good
                case 6.0..<7.0:
                    quality = .fair
                default:
                    quality = .poor
                }
                
                entries.append(SleepEntry(
                    date: date,
                    sleepHours: sleepHours,
                    quality: quality
                ))
            }
        }
        
        return entries.sorted { $0.date < $1.date }
    }
    
    // Helper to get today's sleep
    static func getTodaysSleep() -> SleepEntry? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sleepEntries.first { calendar.isDate($0.date, inSameDayAs: today) }
    }
}
