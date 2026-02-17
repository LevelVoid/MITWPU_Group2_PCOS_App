//
//  PCOSSignalStore.swift
//  PCOS_App
//
//  Created by Abhinaya Rajarajan on 17/02/26.
//

import Foundation

struct PCOSSignalStore {

    static let allSignals: [PCOSSignal] = [
        acnePCOSSignal,
        hairLossPCOSSignal
    ]

    static func signal(for symptomName: String) -> PCOSSignal? {
        return allSignals.first {
            $0.symptomName.lowercased() == symptomName.lowercased()
        }
    }
}
