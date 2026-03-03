//
//  CyclePhaseModel.swift
//  PCOS_App
//
//  Created by Abhinaya Rajarajan on 17/02/26.
//

import Foundation
import UIKit
struct CycleData: Codable  {
    let id: UUID
    let month: String
    let startDate: Date
    let days: [CycleDay]
}

struct CycleDay : Codable {
    let dayIndex: Int
    let phase: Phase
    let symptoms: [SymptomItem]
}
enum Phase : Codable {
    case menstrual
    case follicular
    case ovulation
    case luteal
    case unknown
}
extension CycleData {

    var cycleLength: Int {
        days.count
    }

    var periodLength: Int {
        days.filter { $0.phase == .menstrual }.count
    }
}
extension Phase {

    var backgroundColor: UIColor {
            switch self {
            case .menstrual:
                return UIColor(red: 0.90, green: 0.45, blue: 0.50, alpha: 1) // Rose red
                
            case .follicular:
                return UIColor(red: 0.45, green: 0.75, blue: 0.80, alpha: 1) // Soft teal
                
            case .ovulation:
                return UIColor(red: 0.98, green: 0.80, blue: 0.30, alpha: 1) // Golden
                
            case .luteal:
                return UIColor(red: 0.75, green: 0.65, blue: 0.85, alpha: 1) // Lavender
                
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
}


