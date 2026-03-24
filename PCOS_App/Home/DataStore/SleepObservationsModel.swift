//
//  AICoachService.swift
//  PCOS_App
//
//  Created by Apple AI
//

import Foundation
import FoundationModels

class SleepObservationsModel {
    
    static let shared = SleepObservationsModel()
    private init() {}
    
    // System instructions carefully worded to avoid Apple Foundation Model safety triggers
    // Avoids: medical conditions, hormone references, diagnosis language
    private let systemInstructions = """
    You are a friendly sleep pattern observer for a wellness app.

    Given the user's recent sleep durations, generate ONE short observation about their sleep consistency, trends, or suggested rest habits.

    Rules:
    - Write exactly one sentence.
    - Maximum 20 words.
    - Friendly, calm, encouraging tone.
    - Focus on sleep consistency, duration trends, or energy.
    - Do NOT mention any medical conditions, diagnoses, or hormones.
    - Do NOT give medical advice.
    - No lists, markdown, emojis, or extra formatting.
    - Do NOT wrap your response in quotation marks.

    Example outputs:
    "Your sleep has been consistent this week — nice work keeping a steady routine!"
    "A few shorter nights recently. Winding down earlier could help you feel more rested."
    "Averaging around 7 hours — a solid foundation for feeling energized."
    """
    
    /// Prepares the AI prompt string based on the current merged sleep map
    private func generateSleepPrompt(from chartData: [SleepChartDataModel], timeRange: SleepChartTimeRange) -> String {
        var prompt: String
        
        switch timeRange {
        case .week:
            prompt = "Here are the user's daily sleep durations in hours for this week:\n"
        case .month:
            prompt = "Here are the user's average weekly sleep durations in hours for the past month:\n"
        case .year:
            prompt = "Here are the user's average monthly sleep durations in hours for this year:\n"
        }
        
        for point in chartData {
            let hours = min(point.hours, 24.0)  // cap anomalies
            prompt += "- \(point.label): \(String(format: "%.1f", hours)) hours\n"
        }
        
        prompt += "\nProvide a brief, friendly observation about their sleep pattern."
        return prompt
    }
    
    /// Invokes the native iOS LanguageModelSession to evaluate the sleep records and yield an insight string
    func fetchSleepInsight(chartData: [SleepChartDataModel], timeRange: SleepChartTimeRange = .week) async throws -> String {
        guard !chartData.isEmpty else {
            return "Log more sleep data to unlock personalized insights!"
        }
        
        // Quick check: if all data points are zero, no insight to generate
        let hasData = chartData.contains { $0.hours > 0 }
        guard hasData else {
            return "Start logging your sleep to see patterns and trends here."
        }
        
        let prompt = generateSleepPrompt(from: chartData, timeRange: timeRange)
        let session = LanguageModelSession(instructions: systemInstructions)
        
        do {
            let result = try await session.respond(to: prompt)
            let insight = result.content
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\""  ))
            
            // Guard against safety refusal responses
            let lowerInsight = insight.lowercased()
            if lowerInsight.contains("i'm sorry") ||
               lowerInsight.contains("i cannot") ||
               lowerInsight.contains("i can't") ||
               lowerInsight.contains("not within my programming") {
                return fallbackInsight(from: chartData)
            }
            
            return insight
        } catch {
            print("ERROR: Foundation Model failed to analyze sleep: \(error)")
            return fallbackInsight(from: chartData)
        }
    }
    
    /// Generates a simple rule-based fallback insight when the model refuses or errors
    private func fallbackInsight(from chartData: [SleepChartDataModel]) -> String {
        let validHours = chartData.map { $0.hours }.filter { $0 > 0 }
        guard !validHours.isEmpty else {
            return "Keep logging your sleep to track your rest patterns."
        }
        let avg = validHours.reduce(0, +) / Double(validHours.count)
        
        switch avg {
        case ..<5: return "Your recent sleep has been quite short — try to rest more."
        case 5..<7: return "You're averaging under 7 hours. A bit more sleep could help."
        case 7..<9: return "Your sleep average looks solid — keep up the good routine!"
        default: return "You've been getting plenty of rest. Consistency is key!"
        }
    }
}
