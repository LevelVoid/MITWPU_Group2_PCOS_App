//
//  SleepLog.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/03/26.
//

import Foundation

// MARK: - SleepLog Model
struct SleepLog: Codable {
    let sleepTime: Date
    let wakeTime: Date
    let rating: Double

    /// Total sleep duration in seconds
    var totalDuration: TimeInterval {
        var wake = wakeTime
        // If wake time is before sleep time, it's the next day
        if wake < sleepTime {
            wake = Calendar.current.date(byAdding: .day, value: 1, to: wake) ?? wake
        }
        return wake.timeIntervalSince(sleepTime)
    }

    /// Total hours (whole number)
    var hours: Int {
        return Int(totalDuration / 3600)
    }

    /// Remaining minutes after whole hours
    var minutes: Int {
        return Int(totalDuration.truncatingRemainder(dividingBy: 3600) / 60)
    }

    /// Human-readable display string, e.g. "7h 05m"
    var displayString: String {
        return "\(hours)h \(String(format: "%02d", minutes))m"
    }
}
