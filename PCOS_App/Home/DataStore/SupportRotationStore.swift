//
//  SupportRotationStore.swift
//  PCOS_App
//
//  Created by Abhinaya Rajarajan on 17/02/26.
//

import Foundation

final class SupportRotationStore {

    static let shared = SupportRotationStore()

    private init() {}

    func nextSupportAction(for signal: PCOSSignal, category: SupportCategory) -> SupportAction? {

        let actions = signal.supportActions.filter { $0.category == category }

        guard !actions.isEmpty else { return nil }

        let key = "rotation_\(signal.symptomName)_\(category.rawValue)"

        let lastIndex = UserDefaults.standard.integer(forKey: key)

        let nextIndex = (lastIndex + 1) % actions.count

        UserDefaults.standard.set(nextIndex, forKey: key)

        return actions[nextIndex]
    }
}
