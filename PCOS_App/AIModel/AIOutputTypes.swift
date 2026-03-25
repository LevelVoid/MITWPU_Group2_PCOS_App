//
//  AIOutputTypes.swift
//  PCOS_App
//
//  Created by SDC-USER on 23/03/26.
//

import Foundation
import FoundationModels

@Generable
struct MealRecommendationOutput {
    @Guide(description: "One factual sentence with specific numbers, explaining why these foods were chosen based on recent logs.")
    var observationLine: String

    @Guide(description: "A short 2-4 word focus tag for the UI element, e.g. 'Low on protein', 'Cramp recovery'.")
    var focusTag: String

    @Guide(description: "Exactly 3 Indian food suggestions.")
    var foods: [FoodCard]
}

@Generable
struct FoodCard {
    @Guide(description: "Specific name of the dish, including Hindi name if applicable, e.g., 'Dahi with ground flaxseed (Alsi)'.")
    var name: String

    @Guide(description: "The most relevant macro or health metric, e.g., '22g protein', 'Low-GI (GI 38)'.")
    var primaryMacro: String

    @Guide(description: "Exactly 2 impact tags from the fixed PCOS list.")
    var impactTags: [String]

    @Guide(description: "One word hint for the UI color: pink, green, or amber.")
    var colorHint: String
}

@Generable
struct DailyGoalsOutput {
    @Guide(description: """
    Exactly 2 goals. Priority order — pick the top 2 that apply:
    1. Diet + symptom connection (e.g. anti-inflammatory food for active cramps/bloating)
    2. Diet + workout connection (e.g. protein gap after a workout session)
    3. Nutrition gap (e.g. protein or fibre deficit from today's logs)
    4. Workout gap (e.g. no strength training this week)
    Never include sleep. Never include more than 2 goals.
    
    Generate exactly 2 personalized daily health goals for a woman with PCOS.

    FIRST: Read the context carefully and extract:
    - Symptoms today: [list from context — if none, note that]
    - Protein logged vs target: [exact numbers from context]
    - Workout logged today: [yes/no from context]
    - Strength sessions this week: [number from context]

    THEN generate goals only from what you extracted above. Do not use any other data.
    """)
    var goals: [GoalCard]
}

@Generable
struct GoalCard {
    @Guide(description: "1-3 word title. Sharp and direct. If larger words then only 2 or 1 word title will be shown. E.g. 'Boost protein now', 'Ease cramps', 'Strength training'.")
    var title: String

    @Guide(description: """
    One action sentence, max 12 words. Include one real number from their logs.
    Be warm and encouraging — frame it as an opportunity, not a deficit.
    E.g. 'Only 20g protein logged — add moong dal or dahi.'
    E.g. 'Bloating today — swap rice with fruit salad to reduce bloating'
    E.g. 'Cramps today — swap rice for ragi to reduce inflammation.'
    E.g. 'No strength training in 7 days — add a 20-min session.'
    """)
    var sentence: String
    
    @Guide(description: "One word only: nutrition | exercise | symptoms")
    var category: String
}
