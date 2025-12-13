//
//  SymptomsModel.swift
//  PCOS_App
//
//  Created by SDC-USER on 12/12/25.
//

import Foundation

// Symptom Item
struct SymptomItem {
    let name: String
    let icon: String
    var isSelected: Bool = false
}

//LOgged Symptoms
struct LoggedSymptoms {
    let date: Date
    let name: String
    let icon: String
}

//Symptom Category
//struct SymptomCategory {
//    let title: String
//    let items: [SymptomItem]
//}
