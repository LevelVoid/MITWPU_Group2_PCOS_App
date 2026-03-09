//
//  CyclePhaseModel.swift
//  PCOS_App
//
//  Created by Abhinaya Rajarajan on 17/02/26.
//

import Foundation
import UIKit

struct CycleData: Codable {
    let id: UUID
    let month: String
    let startDate: Date

    /// Nil means this cycle is currently ongoing.
    var endDate: Date?

    /// Becomes true if BBT detects a temperature spike (HealthKit future-proofing).
    var isOvulationConfirmed: Bool = false

    var days: [CycleDay]
}

struct CycleDay: Codable {
    let dayIndex: Int

    /// `var` so we can update retroactively when ovulation is confirmed later.
    var phase: Phase

    let symptoms: [SymptomItem]

    /// Ready for HealthKit: stores the BBT reading for this specific day.
    var basalBodyTemperature: Double?
}

enum Phase: Codable {
    case menstrual
    case follicular
    case ovulation
    case luteal
    case unknown
}

// MARK: - CycleData Computed Properties

extension CycleData {

    /// Whether this cycle has ended (another period started after it).
    var isComplete: Bool {
        endDate != nil
    }

    /// For completed cycles: gap between start and end.
    /// For ongoing cycles: returns days.count (the estimated length used when building).
    var cycleLength: Int {
        if let end = endDate {
            return max(
                Calendar.current.dateComponents([.day], from: startDate, to: end).day ?? days.count,
                days.count
            )
        }
        return days.count
    }

    var periodLength: Int {
        days.filter { $0.phase == .menstrual }.count
    }
}
extension Phase {

    var backgroundColor: UIColor {
            switch self {
            case .menstrual:
                //return UIColor(red: 0.90, green: 0.45, blue: 0.50, alpha: 1) // Rose red
                return UIColor(hex: "FFB0B0")
                
            case .follicular:
               // return UIColor(red: 0.45, green: 0.75, blue: 0.80, alpha: 1) // Soft teal
                return UIColor(hex: "8CF4F2")
                
            case .ovulation:
               // return UIColor(red: 0.98, green: 0.80, blue: 0.30, alpha: 1) // Golden
                return UIColor(hex: "FFEFA2")
                
            case .luteal:
               // return UIColor(red: 0.75, green: 0.65, blue: 0.85, alpha: 1) // Lavender
                return UIColor(hex: "DDBFFF")
                
            case .unknown:
                return UIColor.systemGray4
            }
        }

    var icon: UIImage? {
        switch self {
        case .ovulation:
            return UIImage(systemName: "sparkles")
        default:
            return nil
        }
    }

    var iconTint: UIColor {
        switch self {
        case .ovulation:
            return UIColor.systemOrange
        default:
            return .clear
        }
    }

    var displayName: String {
        switch self {
        case .menstrual:  return "Menstrual Phase"
        case .follicular: return "Follicular Phase"
        case .ovulation:  return "Ovulation Phase"
        case .luteal:     return "Luteal Phase"
        case .unknown:    return "Cycle Phase"
        }
    }

    var quote: String {
        switch self {
        case .menstrual:
            return "Your body may be asking for rest and gentler movement today"
        case .follicular:
            return "Energy is building a great time to try something new"
        case .ovulation:
            return "You may feel more confident and energetic today"
        case .luteal:
            return "Be gentle with yourself your body is preparing for the next cycle"
        case .unknown:
            return "Track your cycle to get personalised insights"
        }
    }
}



