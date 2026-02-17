//
//  SignalData.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/02/26.
//


//NEED TO REMOVE THIS ->redundant
import UIKit

struct SignalInfo {
    let symptomName: String
    let title: String
    let imageName: String
}

// Data store for signals
let signalsDataStore: [SignalInfo] = [
    SignalInfo(
        symptomName: "Fatigue",
        title: "Why you may feel Fatigued",
        imageName: "fatigue"
    ),
    SignalInfo(
        symptomName: "Cramps",
        title: "Gentle Relief for Cramps",
        imageName: "cramps"
    ),
    SignalInfo(
        symptomName: "Bloating",
        title: "Taming your PCOS Bloating",
        imageName: "cycle" 
    ),
    // Add more signals as needed
    SignalInfo(
        symptomName: "Mood Swings",
        title: "Understanding Your Mood Changes",
        imageName: "cycle"
    ),
    SignalInfo(
        symptomName: "Acne",
        title: "Managing PCOS Skin Concerns",
        imageName: "acne_signal"
    ),
    SignalInfo(
        symptomName: "Hair Loss",
        title: "Addressing Hair Thinning",
        imageName: "hair_signal"
    ),
    SignalInfo(
        symptomName: "Weight Gain",
        title: "PCOS and Weight Management",
        imageName: "weight_signal"
    )
]

// Helper function to get signal info by symptom name
func getSignalInfo(for symptomName: String) -> SignalInfo? {
    return signalsDataStore.first { $0.symptomName.lowercased() == symptomName.lowercased() }
}

// Default signal for when no match is found
let defaultSignalInfo = SignalInfo(
    symptomName: "General",
    title: "Understanding your cycle and PCOS",
    imageName: "cycle" // Default image
)
