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

