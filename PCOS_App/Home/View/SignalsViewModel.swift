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
        signal.scientificReasons.randomElement() ?? ""
    }

    var appearanceText: String {
        signal.appearanceDescriptions.randomElement() ?? ""
    }

    func supportAction(for category: SupportCategory) -> SupportAction? {
        signal.supportActions
            .filter { $0.category == category }
            .randomElement()
    }
}

