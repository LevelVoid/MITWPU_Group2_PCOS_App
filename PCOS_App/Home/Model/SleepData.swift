//
//  SleepData.swift
//  PCOS_App
//
//  Created by PCOS_App on 06/03/26.
//


//DELETE THIS ENTIRE FILE 

import Foundation

// MARK: - Sleep Quality

enum SleepQuality {
    case poor       // < 5 h
    case fair       // 5 – 6.9 h
    case good       // 7 – 8.9 h
    case excellent  // ≥ 9 h

    init(hours: Double) {
        switch hours {
        case ..<5:   self = .poor
        case 5..<7:  self = .fair
        case 7..<9:  self = .good
        default:     self = .excellent
        }
    }

    var label: String {
        switch self {
        case .poor:      return "Poor"
        case .fair:      return "Fair"
        case .good:      return "Good"
        case .excellent: return "Excellent"
        }
    }

    /// Emoji indicator shown in the cell
    var emoji: String {
        switch self {
        case .poor:      return "😴"
        case .fair:      return "😐"
        case .good:      return "😊"
        case .excellent: return "🌟"
        }
    }
}

// MARK: - Sleep Data

struct SleepData {
    let totalHours: Double       // Total asleep time in hours
    let inBedMinutes: Int        // Minutes in bed (including light sleep)
    let asleepMinutes: Int       // Minutes actually asleep
    let quality: SleepQuality

    /// Formatted string like "7h 24m"
    var formattedDuration: String {
        let hours = Int(totalHours)
        let minutes = Int((totalHours - Double(hours)) * 60)
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
