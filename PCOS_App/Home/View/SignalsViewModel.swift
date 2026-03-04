//
//  SignalsViewModel.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 17/02/26.
//
import Foundation
//UI CLASS 
final class PCOSSignalViewModel {

    private let signal: PCOSSignal

    init(signal: PCOSSignal) {
        self.signal = signal
    }

    var infoText: String {
        signal.scientificReasons.first ?? ""
    }

    var appearanceText: String {
        signal.appearanceDescriptions.first ?? ""
    }

    func supportAction(for category: SupportCategory) -> SupportAction? {
        return SupportRotationStore.shared
            .nextSupportAction(for: signal, category: category)
    }

}
//NEED TO DELETE THIS -> have to map out things a bit->temporary 
extension PhaseSignal {

    func cardTitle(for type: PhaseCardType) -> String {
        switch type {
        case .understanding:
            return understanding.heading   // "Periods in PCOS"
        case .symptoms:
            return symptoms.heading        // "Symptoms to Expect"
        case .support:
            return support.heading         // "Menstrual Relief"
        }
    }


    func cardImage(for type: PhaseCardType) -> String {
        switch (phase, type) {

        // MARK: Menstrual Phase
        case (.menstrual, .understanding):
            return "menstrual_phase_illustration"

        case (.menstrual, .symptoms):
            return "cycle"

        case (.menstrual, .support):
            return "menstrual_support_illustration"


        // MARK: Ovulation Phase
        case (.ovulation, .understanding):
            return "ovulation_phase_illustration"

        case (.ovulation, .symptoms):
            return "cycle"

        case (.ovulation, .support):
            return "ovulation_support_illustration"
            
            // MARK: Luteal Phase
            case (.luteal, .understanding):
                return "luteal_phase_illustration"

            case (.luteal, .symptoms):
                return "cycle"

            case (.luteal, .support):
                return "luteal_support_illustration"
            
            
            // MARK: Follicular Phase
            case (.follicular, .understanding):
                return "follicular_phase_illustration"

            case (.follicular, .symptoms):
                return "cycle"

            case (.follicular, .support):
                return "follicular_support_illustration"


        default:
            return illustration
        }
    }
}

