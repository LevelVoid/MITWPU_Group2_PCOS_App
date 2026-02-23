//
//  AboutPCOSDataStore.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 23/02/26.
//

import Foundation

final class AboutPCOSDataStore {

    static let shared = AboutPCOSDataStore()
    private init() {}

    func fetchSections() -> [AboutPCOSSection] {

        let dietSection = AboutPCOSSection(
            title: "PCOS and Diet",
            description: "Simple food choices that reduce inflammation and support insulin balance.",
            imageName: "pcos_diet",
            contentBlocks: [

                // Intro paragraph
                ContentBlock(
                    heading: nil,
                    body: """
Up to 50–75% of people with PCOS experience insulin resistance, which can lead to weight gain, fatigue, cravings, and higher risk of diabetes or heart disease. Food plays a major role in keeping blood sugar stable and reducing inflammation.
""",
                    imageName: nil
                ),

                // Foods that worsen symptoms
                ContentBlock(
                    heading: "Foods That Can Worsen Symptoms",
                    body: """
Highly processed foods tend to increase inflammation and blood sugar spikes, which can aggravate PCOS symptoms. Limit frequent intake of: refined sugar, fried foods, processed snacks, sugary drinks, white bread/pasta, and processed meats.
""",
                    imageName: nil
                ),

                // Support foods section
                ContentBlock(
                    heading: "Food Choices That Support PCOS Recovery",
                    body: """
Food isn’t punishment, it’s daily hormone support. Simple swaps like dal, greens, protein-rich meals, and steady carbs help avoid energy crashes and cravings.

Easy wins – dal-chawal with veggies, paneer sabzi roti, curd with nuts, roasted chana snacks. Small choices daily matter more than strict diets.
""",
                    imageName: "pcos_food_support" // add this asset
                ),

                // Conclusion
                ContentBlock(
                    heading: "Conclusion",
                    body: """
You don’t need to overhaul your entire pantry overnight. Small daily choices add up, and enjoying your favorite foods occasionally is completely okay, balance matters more than perfection.
""",
                    imageName: nil
                )
            ]
        )


        let psychologicalSection = AboutPCOSSection(
            title: "Psychosocial Aspects of PCOS",
            description: "Learn about coping with stigma, societal misconceptions, and its impact on mental health.",
            imageName: "pcos_psychology",
            contentBlocks: [

                ContentBlock(
                    heading: nil,
                    body: """
PCOS affects more than hormones. Many people experience anxiety, low mood, and body image struggles due to symptoms like acne, weight changes, or unwanted hair growth. The condition often becomes emotionally exhausting because it impacts both physical health and self-esteem at the same time.
""",
                    imageName: nil
                ),

                ContentBlock(
                    heading: "Societal Misconceptions",
                    body: """
Myth – PCOS is only a fertility problem.  
Fact – It affects metabolism, hormones, skin, mood, and long-term health.

Myth – It happens because of poor lifestyle choices.  
Fact – Genetics and insulin resistance play a central role, lifestyle is only one part of management.

Myth – Symptoms are “cosmetic.”  
Fact – PCOS is a complex endocrine condition with real mental and physical consequences.
""",
                    imageName: nil
                ),

                ContentBlock(
                    heading: "Coping and Feeling More in Control",
                    body: """
Managing PCOS also means caring for emotional wellbeing. Therapy or counseling can help with anxiety, depression, and body image distress. Stress-reduction practices like mindfulness, yoga, or journaling can improve mental resilience. Focusing on progress, not appearance, is often a healthier mindset shift.
""",
                    imageName: nil
                ),

                ContentBlock(
                    heading: "You’re Not Alone",
                    body: """
PCOS can feel isolating, but you’re not alone in this. The emotional impact is real, and it deserves the same care as physical symptoms. With the right support system and a holistic approach, managing PCOS becomes more manageable over time.
""",
                    imageName: nil
                )
            ]
        )

        return [dietSection, psychologicalSection]
    }
}
