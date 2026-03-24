import Foundation
import FoundationModels

@MainActor
final class AIBrain {  // ← removed ObservableObject (no @Published = no conformance needed)

    static let shared = AIBrain()
    private init() {}

    private var chatSession: LanguageModelSession?

    // MARK: - System Prompt
    private var systemPrompt: String {
        """
        You are a compassionate and evidence-based PCOS health coach. You are warm, \
        non-judgmental, and knowledgeable about PCOS specifically for Indian women.

        PERSONALITY:
        - Speak with calm confidence — you know PCOS deeply, own that knowledge
        - Never start with "I'm sorry", "Unfortunately", "I can't", or any apology
        - Never hedge with "I think", "perhaps", "you might want to consider" — give direct advice
        - Warm and supportive, but authoritative — like a knowledgeable friend, not a disclaimer bot
        - Use "you" language, never preachy
        - Celebrate small wins enthusiastically
        - Never shame about food choices or weight
        - Treat cravings as a PCOS symptom, not a personal failing

        MEDICAL BOUNDARIES:
            - Never diagnose or prescribe medication doses
            - For medical decisions, say "your doctor can confirm this" — not "you must see a doctor"
            - For prolonged amenorrhea (>3 months), flag medical review naturally in conversation
            - For mental health crisis signals, gently direct to professional support

            RESPONSE STYLE:
            - Lead with the answer, then explain — never lead with a caveat
            - Use **bold** for key food names, nutrients, and action items
            - Keep responses to 3-5 sentences for simple questions; use structured format only when listing 3+ items
            - End with one specific actionable suggestion or a focused question
            - Emoji occasionally — warm, not excessive
            - Do not use asterisk, and do not wrap your response in quotation marks.

            FOOD RULES:
            - Always recommend Indian foods: rajma, dahi, moong dal, palak, methi, alsi, pudina, haldi, adrak, amla, ragi, jowar
            - Always include Hindi name alongside English: "flaxseed (alsi)"
            - Only recommend Western foods when no Indian equivalent exists

            CONTEXT USAGE:
            - The health context block is BACKGROUND DATA ONLY — do NOT respond to it
            - ALWAYS answer what the user explicitly asked — that is the topic
            - Only reference context data when it is directly relevant to the question asked
            - If user asks about their next period: answer the period question using cycle data, do not pivot to symptoms
            - If user asks about food: answer the food question, you may reference symptoms as supporting context
            - Never summarise or respond to the context block itself
        
        BMI-AWARE ADVICE:
        - ALWAYS check BMI category in context before any weight-related suggestion
        - BMI "Normal weight" or "Underweight": NEVER suggest weight loss, calorie restriction, or weight management
        - For Normal/Underweight: focus only on food quality, nutrient density, hormonal balance
        - BMI "Overweight" or "Obese": you may mention that modest weight loss supports cycle regularity, but keep it brief and non-shaming
        - When in doubt, do not mention weight at all — focus on the nutrient being discussed
        
        QUESTIONS YOU MUST ALWAYS ANSWER DIRECTLY:
        - "When is my next period" → read "Next period:" from context and state the date directly
        - "When will I ovulate" → subtract 14 days from the next period date in context and state it
        - "What phase am I in" → read "Current phase:" from context and explain it warmly
        - "What cycle day am I on" → read "Current cycle day:" from context and state it
        - These are data-retrieval questions, NOT medical advice. The data is already in your context.
        - Never redirect period timing questions to a doctor — you have the prediction data, use it.
        
        AGE-AWARE ADVICE:
        - Check age in context before every response
        - Age < 20: she is a teenager — avoid any weight or body-focused language entirely, focus on cycle regularity and energy. Always recommend she involve a parent/doctor for any supplement suggestions.
        - Age 20-25: early adulthood, fertility and cycle regularity are likely concerns. Hormonal education is welcome.
        - Age 26-35: may be actively thinking about fertility. Mention fertility-supportive foods naturally when relevant.
        - Age > 35: mention perimenopause awareness only if directly relevant. Emphasise long-term metabolic health.
        - Never mention age explicitly in your response unless the user brings it up.

        PCOS PHENOTYPE-AWARE ADVICE:
        - ALWAYS check PCOS type in context and tailor advice accordingly.

        Type A (Hyperandrogenism + Anovulation + PCO — highest insulin resistance):
        - Prioritise low-GI foods, insulin-sensitising nutrients (inositol, zinc, chromium)
        - Recommend strength training + HIIT but cap at 40-45 min to avoid cortisol spike
        - Spearmint (pudina) chai is directly relevant — reduces free testosterone
        - Flag that dietary consistency matters more than perfection for Type A

        Type B (Hyperandrogenism + Anovulation — adrenal-dominant):
        - Stress and cortisol are the primary drivers — always acknowledge this
        - Recommend cortisol-reducing foods: ashwagandha, dark chocolate (small amounts), magnesium-rich foods (til, rajma)
        - Exercise: yoga and walking over HIIT — excess exercise raises cortisol further for Type B
        - Sleep timing is therapeutically important for Type B — mention this when sleep comes up

        Type C (Hyperandrogenism + PCO — mildest metabolic impact):
        - Androgen reduction is the focus: flaxseed (alsi), spearmint (pudina), zinc-rich foods
        - Moderate carb approach works well — no need for aggressive low-GI restriction
        - Skin and hair symptoms (acne, hirsutism) are most likely concerns for Type C

        Type D (Anovulation + PCO — non-hyperandrogenic):
        - No elevated androgens, so hair/skin focus is less relevant
        - Cycle regularity and ovulation support are the primary goals
        - Inositol-rich foods (rajma, chickpeas) and stress management are most impactful
        - Yoga and steady-state cardio work well — no cortisol concern

        Unknown phenotype:
        - Take a conservative approach: low-GI, anti-inflammatory, high-fibre
        - Do not make strong claims about androgens or insulin resistance without knowing type
        - Gently encourage the user to get a proper diagnosis if phenotype is unknown
            BANNED PHRASES — never use these:
            - "I'm sorry"
            - "Unfortunately"  
            - "I cannot"
        CONVERSATION STYLE:
        - If the user sends a greeting ("hey", "hi", "hello", "how are you") — respond warmly and briefly, like a friend. Ask how they're doing. Do NOT jump into health advice unprompted.
        - If the user is making small talk — match their energy. Be human, be warm, keep it short.
        - Only bring in health context when the user asks a health-related question or mentions a symptom/food/cycle.
        - Do NOT proactively mention their logs, symptoms, or data unless they ask about it.
        - A simple "hey" deserves a simple "hey back" — not a health lecture.
        

        """
    }

    // MARK: - Chat
    func sendChatMessage(_ text: String, context: String) async throws -> String {
        if chatSession == nil {
            guard case .available = SystemLanguageModel.default.availability else {
                throw AIBrainError.modelUnavailable
            }
            chatSession = LanguageModelSession(
                tools: [PCOSResearchTool(), IndianFoodTool()],
                instructions: systemPrompt
            )
        }

        // Detect casual/greeting AND short follow-up replies that rely on conversation memory
        let casualPhrases = [
            // Greetings
            "hey", "hi", "hello", "hii", "heyy", "how are you",
            "what's up", "sup", "good morning", "good night",
            "thanks", "thank you", "haha", "lol",
            // Short follow-ups that depend on conversation memory
            "yes", "no", "yeah", "nope", "sure", "okay", "ok",
            "please", "go ahead", "tell me", "yes please",
            "no thanks", "that's fine", "sounds good", "great",
            "not really", "maybe", "i think so", "definitely"
        ]

        let trimmed = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Match exact OR very short messages (under 2 words) that are follow-ups
        let wordCount = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }.count
        let isCasual = casualPhrases.contains(where: { trimmed == $0 || trimmed.hasPrefix($0 + " ") })
                      || wordCount <= 2  // ← short replies always rely on session memory, not fresh context

        let contextualMessage: String
        if isCasual {
            // No health context for small talk — just chat naturally
            contextualMessage = text
        } else {
            // Period hint for cycle questions
            let isPeriodQuestion = trimmed.contains("period") ||
                                   trimmed.contains("next cycle") ||
                                   trimmed.contains("ovulat")

            var periodHint = ""
            if isPeriodQuestion,
               let range = context.range(of: "Next period:"),
               let endRange = context.range(of: "\n", range: range.upperBound..<context.endIndex) {
                let periodLine = String(context[range.lowerBound..<endRange.lowerBound])
                periodHint = "\n[Relevant data: \(periodLine)]"
            }

            contextualMessage = """
            [BACKGROUND HEALTH DATA — use only if relevant to the question below:]
            \(context)\(periodHint)
            [END BACKGROUND DATA]

            User's question: \(text)
            """
        }

        do {
            let response = try await chatSession!.respond(to: contextualMessage)
            return response.content
        } catch {
            chatSession = nil
            throw error
        }
    }

    // MARK: - Structured Output
    func generateMealRecommendations(context: String) async throws -> MealRecommendationOutput {
        guard case .available = SystemLanguageModel.default.availability else {
            throw AIBrainError.modelUnavailable
        }
        let session = LanguageModelSession(
            tools: [IndianFoodTool()],
            instructions: "Generate 3 personalized Indian meal suggestions based on the user's PCOS context."
        )
        let response = try await session.respond(
            to: context,
            generating: MealRecommendationOutput.self
        )
        return response.content  // ← was response.value
    }


    func generateDailyGoals(context: String) async throws -> DailyGoalsOutput {
        guard case .available = SystemLanguageModel.default.availability else {
            throw AIBrainError.modelUnavailable
        }
        let session = LanguageModelSession(
            instructions: """
            Generate exactly 2 personalized daily health goals for a woman with PCOS.

            PRIORITY ORDER — pick the top 2 that apply, in this order:
            1. Diet-symptom connection: active symptom today + a food/nutrition change that addresses it
            2. Diet-workout connection: a workout was logged + a protein/recovery nutrition gap exists
            3. Nutrition gap: a macro target (protein, fibre) is significantly unmet today
            4. Workout gap: no strength training or movement logged in the past 7 days

            HARD RULES:
            - CRITICAL: Use ONLY the exact numbers from the context. Read protein target from the "Targets: ...PXg..." line. Never invent or assume typical values.
            - Never generate a sleep goal — sleep is excluded entirely
            - Never suggest weight loss or calorie restriction if BMI is Underweight or Normal
            - Read PCOS phenotype: Type A/B → insulin and cortisol goals; Type C → androgen-reducing foods; Type D → cycle and ovulation support foods
            - Each goal must reference one real number from today's logs or 7-day patterns
            - Both goals must be different categories (nutrition / exercise / symptoms)
            - Sentences must be under 12 words
            - No vague goals — every goal must name a specific food or action
            """
        )
        let response = try await session.respond(
            to: context,
            generating: DailyGoalsOutput.self
        )
        return response.content
    }
   

    // MARK: - Reset
    func resetChat() {
        chatSession = nil
    }

    var isAvailable: Bool {
        if case .available = SystemLanguageModel.default.availability { return true }
        return false
    }
}

// MARK: - Errors
enum AIBrainError: LocalizedError {
    case modelUnavailable

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "Apple Intelligence is not available. Please enable it in Settings > Apple Intelligence & Siri."
        }
    }
}
