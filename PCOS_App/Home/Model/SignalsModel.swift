//
//  SignalsModel.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 17/02/26.
//
import Foundation

struct PCOSSignal: Codable {
    let symptomName: String
    let signalTitle: String
    let signalIllustration: String

    // Screen 1
    let infoHeading: String
    let scientificReasons: [String]//there is no ramdom function here .Taking an array input for separate paragraphs 
    

    // Screen 2
    let appearanceHeading: String
    let appearanceDescriptions: [String]
    let doctorDisclaimer: String

    // Screen 3
    let supportHeading: String
    let supportActions: [SupportAction]
}

struct SupportAction: Codable {
    let category: SupportCategory
    let text: String
}
enum SupportCategory: String, Codable {
    case dietNutrition
    case physicalCare     // skincare + exercise
    case miscellaneous
}
struct SupportCategoryAssets {
    static let dietNutritionImage = "diet_nutrition_illustration"
    static let physicalCareImage = "skincare_exercise_illustration"
    static let miscellaneousImage = "sleep_misc_illustration"
}

//NOTE:CHANGES TO BE MADE IN MODEL->need to add for multiple values for support your body today->less repetition of data
//struct PhaseSignal {
//    let phaseName: String
//    let title: String
//    let illustration: String
//}

//struct PhaseSignalStore {
//
//    static func signals(for phase: CyclePhase) -> [PhaseSignal] {
//        switch phase {
//        case .follicular:
//            return follicularSignals
//        case .ovulation:
//            return ovulationSignals
//        case .luteal:
//            return lutealSignals
//        case .menstrual:
//            return menstrualSignals
//        }
//    }
//}


enum DisplaySignal {
    case symptom(PCOSSignal)
    case phase(PhaseSignal, PhaseCardType)
}

