//
//  PhaseSignalModel.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 19/02/26.
//
import Foundation
// MARK: - PhaseSignal

struct PhaseSignal: Codable {
    let phase: Phase
    let illustration: String
    let cards: [PhaseCardType]
    let understanding: PhaseUnderstanding
    let symptoms: PhaseSymptoms
    let support: PhaseSupport
}

// MARK: - Screen 1

struct PhaseUnderstanding: Codable {
    let heading: String
    let descriptions: [String]
}

// MARK: - Screen 2 (UPDATED)

struct PhaseSymptoms: Codable {
    let heading: String
    let introText: String
    let symptomItems: [SymptomItem]
}
  
// MARK: - Screen 3

struct PhaseSupport: Codable {
    let heading: String
    let actions: [SupportAction]
}
enum PhaseCardType : String, Codable{
    case understanding
    case symptoms
    case support
}
