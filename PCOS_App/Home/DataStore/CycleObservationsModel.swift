import Foundation
import FoundationModels

class CycleObservationsModel {
    
    static let shared = CycleObservationsModel()
    private init() {}
    
    private let systemInstructions = """
    You are Adira, a warm and supportive wellness companion inside a PCOS tracking app.
        You are NOT a doctor and must never give medical advice or diagnoses.
        The user will share their recent cycle and period lengths in days.

        Write a one sentence(max 15 words) in second person ("your") that:
        - Observes whether their cycle lengths look consistent or irregular
        - Gently connects the pattern to how PCOS can commonly affect cycle regularity (e.g. longer cycles, skipped periods, variability) — framed as a wellness observation, NOT a diagnosis
        - Stays casual, encouraging, and positive

        Do not suggest treatments, medications, or medical consultations.
        Do not use markdown, lists, or quotation marks.
        Do not ask questions.
        Speak as if you already know the user has PCOS — this is a PCOS-focused app.
    """
    
    private func generateCyclePrompt(from cycles: [CycleData]) -> String {
        var prompt = "Here are the user's recent cycle and period lengths in days:\n"
        
        for cycle in cycles {
            let cycleLen = cycle.isComplete ? "\(cycle.cycleLength)" : "Ongoing"
            prompt += "- Month: \(cycle.month), Cycle: \(cycleLen) days, Period: \(cycle.periodLength) days\n"
        }
        
        return prompt
    }
    
    func fetchCycleInsight(cycles: [CycleData]) async throws -> String {
        guard !cycles.isEmpty else {
            return "Log more period data to unlock personalized AI cycle insights!"
        }
        
        let prompt = generateCyclePrompt(from: cycles)
        let session = LanguageModelSession(instructions: systemInstructions)
        
        do {
            let result = try await session.respond(to: prompt)
            return result.content
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\"" ))
        } catch {
            print("ERROR: Foundation Model failed to analyze cycle: \(error)")
            throw error
        }
    }
}
