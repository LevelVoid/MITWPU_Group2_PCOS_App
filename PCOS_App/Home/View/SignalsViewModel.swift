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
        switch type {
        case .understanding:
            return illustration
        case .symptoms:
            return "cycle"
        case .support:
            return "menstrual_support_illustration"
        }
    }
}

