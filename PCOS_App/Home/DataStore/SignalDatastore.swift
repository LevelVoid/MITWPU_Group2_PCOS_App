//
//  SignalDatastore.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 17/02/26.
//
import Foundation

let acnePCOSSignal = PCOSSignal(
    symptomName: "Acne",
    signalTitle:"Managing PCOS Skin Concerns",
    signalIllustration: "Acne",

    // Screen 1
    infoHeading: "PCOS and Acne",
    scientificReasons: [
        "In PCOS, the ovaries produce higher levels of androgen hormones like testosterone and dehydroepiandrosterone (DHEA).",
        "These hormones stimulate sebaceous glands to produce excess oil and slow skin cell turnover, increasing the risk of clogged pores and acne."
    ],

    // Screen 2
    appearanceHeading: "What does PCOS acne look like?",
    appearanceDescriptions: [
        "Deeper acne under the skin, such as cystic acne",
        "Most common on the lower face, including the chin, jawline, and lower cheeks",
        "Red and inflamed acne papules",
        "Often persistent and slow to resolve, even with standard acne treatments",
        "May worsen around menstrual periods"
    ],

    doctorDisclaimer: "If acne is severe, painful, or not improving with basic care, consult a dermatologist or healthcare professional.",

    // Screen 3
    supportHeading: "Support your body today",
    supportActions: [

        // MARK: Diet / Nutrition
        SupportAction(
            category: .dietNutrition,
            text: "Include anti-inflammatory foods like leafy greens, berries, nuts, olive oil, and turmeric."
        ),
        SupportAction(
            category: .dietNutrition,
            text: "Focus on nutrients that support skin health, such as zinc, vitamins A and C, and omega-3 fatty acids."
        ),

        // MARK: Physical Care (Skincare / Exercise)
        SupportAction(
            category: .physicalCare,
            text: "Use gentle acne treatments like benzoyl peroxide or salicylic acid for mild breakouts."
        ),
        SupportAction(
            category: .physicalCare,
            text: "Maintain a consistent skincare routine using non-comedogenic products."
        ),

        // MARK: Miscellaneous (Sleep / Habits / Home Care)
        SupportAction(
            category: .miscellaneous,
            text: "Prioritize good sleep and manage stress, as hormonal acne can worsen with poor rest."
        ),
        SupportAction(
            category: .miscellaneous,
            text: "Avoid touching or picking acne, and remove makeup thoroughly at the end of the day."
        )
    ]
)
