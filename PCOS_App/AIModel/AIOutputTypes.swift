//
//  AIOutputTypes.swift
//  PCOS_App
//
//  Created by SDC-USER on 23/03/26.
//

import Foundation
import FoundationModels

//MARK: meal reccomendation system
@Generable
struct MealRecommendationOutput {
    @Guide(description: """
    One sentence, max 12 words, referencing actual logged numbers from context.
    E.g. 'You have logged only 20g protein against your 60g target.'
    Use ONLY numbers present in the context — never invent values.
    Do not use colon for last meal.
    """)
    var observationLine: String

    @Guide(description: "One short sentence, max 12 words, encouraging the user. E.g. 'Add a high-protein meal to stay on track.'")
    var subObservationLine: String

    @Guide(description: """
    Exactly 3 Indian food suggestions. 
    None of these should repeat any food already logged today in the context.
    Each must directly address the focus tag gap.
    """)
    var foods: [FoodCard]
}

@Generable
struct FoodCard {
    @Guide(description: "Short Indian dish name, max 25 characters. E.g. 'Moong Dal Chilla', 'Palak Paneer', 'Ragi Roti'. Never suggest a food already logged today.")
    var name: String

    @Guide(description: "Metric based on the nutritional gap (e.g. '22g protein', '8g fibre').")
    var primaryMacro: String

    @Guide(description: "One short sentence describing the meal. E.g. 'Comforting lentil stew with spices'.")
    var description: String

    @Guide(description: "Estimated calorie count. E.g. '420 kcal'.")
    var calories: String

    @Guide(description: "Exactly 1 short, relevant PCOS tag (e.g. 'Low GI').")
    var impactTag: String

    @Guide(description: "One word only: red | green | yellow.")
    var colorHint: String
}

//MARK: daily goals output
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
