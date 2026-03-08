//
//  CDUser+CoreDataClass.swift
//  PCOS_App
//

import Foundation
import CoreData

@objc(CDUser)
public class CDUser: NSManagedObject {
    
    // MARK: - Computed Properties
    
    /// BMI computed dynamically — never stored, always accurate
    var calculatedBMI: Double {
        let heightInMeters = heightCm / 100
        guard heightInMeters > 0 else { return 0 }
        return weightKg / (heightInMeters * heightInMeters)
    }
    
    /// BMI category derived from BMI value
    var bmiCategory: String {
        switch calculatedBMI {
        case ..<18.5:  return "underweight"
        case 18.5..<25: return "normal"
        case 25..<30:   return "overweight"
        default:        return "obese"
        }
    }
    
    /// Age computed from date_of_birth — always current
    var age: Int {
        guard let dob = dateOfBirth else { return 0 }
        return Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 0
    }
}
