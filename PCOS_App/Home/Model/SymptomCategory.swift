//
//  SymptomCategory.swift
//  PCOS_App
//
//  Created by SDC-USER on 13/12/25.
//
import Foundation

struct SymptomCategory {
    let title: String
    let items: [SymptomItem]
    
    // Store all categories here as static data
    static let allCategories: [SymptomCategory] = [
        SymptomCategory(title: "Spotting", items: [
            SymptomItem(name: "Red", icon: "RedSpottingIcon"),
            SymptomItem(name: "Brown", icon: "BrownSpottingIcon")
        ]),
        SymptomCategory(title: "Discharge", items: [
            SymptomItem(name: "Dry", icon: "RedSpottingIcon"),
            SymptomItem(name: "Sticky", icon: "RedSpottingIcon"),
            SymptomItem(name: "Creamy", icon: "RedSpottingIcon"),
            SymptomItem(name: "Watery", icon: "RedSpottingIcon"),
            SymptomItem(name: "Egg White", icon: "RedSpottingIcon"),
            SymptomItem(name: "Unusual", icon: "RedSpottingIcon"),
            SymptomItem(name: "Position Cervix", icon: "RedSpottingIcon"),
            SymptomItem(name: "Texture", icon: "RedSpottingIcon")
        ]),
        SymptomCategory(title: "Pain", items: [
            SymptomItem(name: "Abdominal Cramp", icon: "RedSpottingIcon"),
            SymptomItem(name: "Tender Breasts", icon: "BrownSpottingIcon"),
            SymptomItem(name: "Low Back Pain", icon: "BrownSpottingIcon"),
            SymptomItem(name: "Headache", icon: "HeadacheIcon"),
            SymptomItem(name: "Vulvar Pain", icon: "VulvarPainIcon")
        ]),
        SymptomCategory(title: "Skin and Hair", items: [
            SymptomItem(name: "Acne", icon: "AcneIcon"),
            SymptomItem(name: "Hair Loss", icon: "HairLossIcon"),
            SymptomItem(name: "Skin Darkening", icon: "SkinDarkeningIcon"),
            SymptomItem(name: "Hirutism", icon: "HirutismIcon")
        ]),
        SymptomCategory(title: "Lifestyle", items: [
            SymptomItem(name: "Fatigue", icon: "RedSpottingIcon"),
            SymptomItem(name: "Insomnia", icon: "InsomniaIcon"),
            SymptomItem(name: "Depressed", icon: "DepressedIcon"),
            SymptomItem(name: "Anxiety", icon: "AnxietyIcon")
        ]),
        SymptomCategory(title: "Gut Health", items: [
            SymptomItem(name: "Bloating", icon: "BloatingIcon"),
            SymptomItem(name: "Constipation", icon: "ConstipationIcon"),
            SymptomItem(name: "Diarrhea", icon: "DiarrheaIcon"),
            SymptomItem(name: "Gas", icon: "GasIcon")
        ]),
        SymptomCategory(title: "Breast Self Exam", items: [
            SymptomItem(name: "Everything is fine", icon: "RedSpottingIcon"),
            SymptomItem(name: "Engorgement", icon: "BrownSpottingIcon"),
            SymptomItem(name: "Lump", icon: "BrownSpottingIcon"),
            SymptomItem(name: "Dimple", icon: "BrownSpottingIcon"),
            SymptomItem(name: "Skin Redness", icon: "BrownSpottingIcon"),
            SymptomItem(name: "Cracked nipples", icon: "BrownSpottingIcon"),
            SymptomItem(name: "Pain", icon: "BrownSpottingIcon"),
            SymptomItem(name: "Nipple Discharge", icon: "BrownSpottingIcon"),

        ])
    ]
}

