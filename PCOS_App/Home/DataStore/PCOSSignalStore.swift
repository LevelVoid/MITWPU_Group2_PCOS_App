//
//  PCOSSignalStore.swift
//  PCOS_App
//
//  Created by Abhinaya Rajarajan on 17/02/26.
//

import Foundation

struct PCOSSignalStore {

    static let allSignals: [PCOSSignal] = [
        redSpottingPCOSSignal,
        brownSpottingPCOSSignal,
        acnePCOSSignal,
        hirsutismPCOSSignal,
        skinDarkeningPCOSSignal,
        hairLossPCOSSignal,
        crampsPCOSSignal,
        lowerBackPCOSSignal,
        tenderBreastsPCOSSignal,
        headachePCOSSignal,
        vulvarPainPCOSSignal,
        fatiguePCOSSignal,
        moodSwingsPCOSSignal,
        depressionPCOSSignal,
        anxietyPCOSSignal,
        bloatingPCOSSignal,
        constipationPCOSSignal,
        diarrheaPCOSSignal,
        gasPCOSSignal,
        skinTagsPCOSSignal,
        
        lightFlowPCOSSignal,
        mediumFlowPCOSSignal,
        heavyFlowPCOSSignal,
        superHeavyFlowPCOSSignal,
        
        dryDischargePCOSSignal,
        stickyDischargePCOSSignal,
        creamyDischargePCOSSignal,
        wateryDischargePCOSSignal,
        eggWhiteDischargePCOSSignal,
        unusualDischargePCOSSignal
    ]

    static func signal(for symptomName: String) -> PCOSSignal? {
        return allSignals.first {
            $0.symptomName.lowercased() == symptomName.lowercased()
        }
    }
}
