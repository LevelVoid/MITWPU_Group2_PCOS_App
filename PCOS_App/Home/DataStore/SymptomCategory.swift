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
    
    static let allCategories: [SymptomCategory] = [
        SymptomCategory(title: "Flow", items: [
            SymptomItem(name: "Light", icon: "LightFlow",category: "Flow"),
            SymptomItem(name: "Medium", icon: "MediumFlow",category: "Flow"),
            SymptomItem(name: "Heavy", icon: "HeavyFlow",category: "Flow"),
            SymptomItem(name: "Super Heavy", icon: "SuperHeavyFlow",category: "Flow")
        ]),
        SymptomCategory(title: "Spotting", items: [
            SymptomItem(name: "Red", icon: "RedSpottingIcon",category: "Spotting"),
            SymptomItem(name: "Brown", icon: "BrownSpottingIcon",category: "Spotting")
        ]),
        SymptomCategory(title: "Skin and Hair", items: [
            SymptomItem(name: "Acne", icon: "AcneIcon",category: "Skin and Hair"),
            SymptomItem(name: "Hair Loss", icon: "HairLossIcon",category: "Skin and Hair"),
            SymptomItem(name: "Skin Darkening", icon: "SkinDarkeningIcon",category: "Skin and Hair"),
            SymptomItem(name: "Hirsutism", icon: "HirsuitismIcon",category: "Skin and Hair"),
            SymptomItem(name: "Skin Tags", icon: "SkinTagsIcon",category: "Skin and Hair")
        ]),
        SymptomCategory(title: "Lifestyle", items: [
            SymptomItem(name: "Fatigue", icon: "FatigueIcon",category: "Lifestyle"),
            //SymptomItem(name: "Insomnia", icon: "InsomniaIcon",category: "Lifestyle"),
            SymptomItem(name: "Mood Swings", icon: "MoodSwingIcon",category: "Lifestyle"),
            SymptomItem(name: "Depressed", icon: "DepressedIcon",category: "Lifestyle"),
            SymptomItem(name: "Anxiety", icon: "AnxietyIcon",category: "Lifestyle")
        ]),
        SymptomCategory(title: "Pain", items: [
            SymptomItem(name: "Cramps", icon: "AbdominalCrampsIcon",category: "Pain"),
            SymptomItem(name: "Tender Breasts", icon: "ChestPainIcon",category: "Pain"),
            SymptomItem(name: "Lower Back", icon: "BackPainIcon",category: "Pain"),
            SymptomItem(name: "Headache", icon: "HeadacheIcon",category: "Pain"),
            SymptomItem(name: "Vulvar Pain", icon: "VulvarPainIcon",category: "Pain")
        ]),
        SymptomCategory(title: "Discharge", items: [
            SymptomItem(name: "Dry", icon: "DryIcon",category: "Discharge"),
            SymptomItem(name: "Sticky", icon: "StickyIcon",category: "Discharge"),
            SymptomItem(name: "Creamy", icon: "CreamyIcon",category: "Discharge"),
            SymptomItem(name: "Watery", icon: "WateryIcon",category: "Discharge"),
            SymptomItem(name: "Egg White", icon: "EggWhiteIcon",category: "Discharge"),
            SymptomItem(name: "Unusual", icon: "UnusualIcon",category: "Discharge")
//            SymptomItem(name: "Position Cervix", icon: "PositionCervixIcon",category: "Discharge"),
//            SymptomItem(name: "Texture", icon: "TextureIcon",category: "Discharge")
        ]),
        SymptomCategory(title: "Gut Health", items: [
            SymptomItem(name: "Bloating", icon: "BloatingIcon",category: "Gut Health"),
            SymptomItem(name: "Constipated", icon: "ConstipationIcon",category: "Gut Health"),
            SymptomItem(name: "Diarrhea", icon: "DiarrheaIcon",category: "Gut Health"),
            SymptomItem(name: "Gas", icon: "GasIcon",category: "Gut Health")
        ]),
        
    ]
}

