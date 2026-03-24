//
//  SymptomInsightModel.swift
//  PCOS_App
//
//  Created by AI Coach
//

import Foundation
import FoundationModels

class SymptomInsightModel {
    
    static let shared = SymptomInsightModel()
    private init() {}
    
    /// Returns a cached insight for this symptom if one exists, without invoking the model.
    func cachedInsight(for symptomName: String, cycles: [CycleData]) -> String? {
        let prompt = generateSymptomPrompt(symptomName: symptomName, cycles: cycles)
        if prompt == "The user rarely logged this symptom recently." {
            return "Keep tracking to uncover personalized patterns for this symptom."
        }
        if symptomName.lowercased() == "vulvar pain" {
            return "If you experience excess vulvar pain, please consult your doctor."
        }
        return insightCache[prompt]
    }
    
    private let systemInstructions = """
    You are a supportive AI pattern analyzer for a symptom tracking app.
    
    Observe the user's logged symptom frequency across their menstrual cycle phases based strictly on the provided data.
    Generate exactly ONE short sentence summarizing the observed pattern. Do not invent, guess, or provide any biological, hormonal, or medical explanations (e.g., do not mention hormones, progesterone, or estrogen).
    
    Rules:
    - Write exactly one sentence.
    - Maximum 20 words.
    - Friendly, literal, and purely observational tone.
    - NO medical claims, diagnosis, or hormonal explanations.
    - NO lists, markdown, emojis, or extra formatting.
    - Do NOT wrap your response in quotation marks.
    
    Example input: "Acne was logged 3 times in Luteal phase, 1 time in Menstrual phase."
    Example output: "You most frequently logged acne during your luteal phase, with occasional occurrences during menstruation."
    """
    
    /// Prepares the AI prompt string based on the logged symptoms mapped to phases
    private func generateSymptomPrompt(symptomName: String, cycles: [CycleData]) -> String {
        var phaseCounts: [Phase: Int] = [.menstrual: 0, .follicular: 0, .ovulation: 0, .luteal: 0]
        
        for cycle in cycles {
            for day in cycle.days {
                if day.symptoms.contains(where: { $0.name == symptomName }) {
                    phaseCounts[day.phase, default: 0] += 1
                }
            }
        }
        
        var prompt = "The symptom '\(symptomName)' was logged:\n"
        for (phase, count) in phaseCounts where count > 0 {
            let phaseName = phase.displayName.isEmpty ? "Unknown phase" : phase.displayName
            prompt += "- \(count) time(s) in \(phaseName)\n"
        }
        
        if phaseCounts.values.allSatisfy({ $0 == 0 }) {
            return "The user rarely logged this symptom recently."
        }
        
        return prompt
    }
    
    private let cacheKey = "SymptomInsightCache"
    
    private var insightCache: [String: String] {
        get { UserDefaults.standard.dictionary(forKey: cacheKey) as? [String: String] ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: cacheKey) }
    }

    /// Invokes the native iOS LanguageModelSession to evaluate the symptom pattern and yield an insight string
    func fetchSymptomInsight(symptomName: String, cycles: [CycleData]) async throws -> String {
        
        // Intercept highly sensitive topics that trigger Apple Foundation Model safety guards
        if symptomName.lowercased() == "vulvar pain" {
            return "If you experience excess vulvar pain, please consult your doctor."
        }
        
        let prompt = generateSymptomPrompt(symptomName: symptomName, cycles: cycles)
        
        if prompt == "The user rarely logged this symptom recently." {
            return "Keep tracking to uncover personalized patterns for this symptom."
        }
        
        // Return cached insight if the exact phase distribution hasn't changed
        if let cachedInsight = insightCache[prompt] {
            return cachedInsight
        }
        
        let session = LanguageModelSession(instructions: systemInstructions)
        
        do {
            let result = try await session.respond(to: prompt)
            let insight = result.content
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\""  ))
            
            // Save to persistent cache
            var currentCache = insightCache
            currentCache[prompt] = insight
            insightCache = currentCache
            
            return insight
        } catch {
            print("ERROR: Foundation Model failed to analyze symptom pattern: \(error)")
            throw error
        }
    }
}
