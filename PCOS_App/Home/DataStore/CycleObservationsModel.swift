import Foundation
import FoundationModels

class CycleObservationsModel {
    
    static let shared = CycleObservationsModel()
    private init() {}
    
    private let systemInstructions = """
    You are a professional health and menstrual cycle AI coach specializing in PCOS.
    Look at the provided history of the user's cycle lengths and period lengths in days.
    Write a single, highly concise, friendly sentence observing their cycle regularity over these months.
    Mention if it appears stable or irregular, and what that might mean for someone with PCOS.
    Be encouraging and supportive. Do not ask questions or offer to find resources. Do not use markdown, lists, or extra formatting. Be very brief (max 20 words).
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
            return result.content.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("ERROR: Foundation Model failed to analyze cycle: \(error)")
            throw error
        }
    }
}
