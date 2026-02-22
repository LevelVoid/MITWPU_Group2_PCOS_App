//
//  PhaseSignalDataStore.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 19/02/26.
//
// MARK: - PhaseSignalDataStore
import Foundation

final class PhaseSignalDataStore {

    static let shared = PhaseSignalDataStore()
    private init() {}

    func signals(for phase: Phase) -> [DisplaySignal] {
        guard let phaseSignal = signal(for: phase) else { return [] }

        return phaseSignal.cards.map { cardType in
            .phase(phaseSignal, cardType)
        }

    }

    private func signal(for phase: Phase) -> PhaseSignal? {
        switch phase {
        case .menstrual:
            return menstrualSignal
        default:
            return nil
        }
    }
}



// MARK: - Menstrual Phase Data

private let menstrualSignal = PhaseSignal(
    phase: .menstrual,
    illustration: "menstrual_phase_illustration",
    cards: [.understanding, .symptoms, .support],
    understanding: PhaseUnderstanding(
        heading: "Periods in PCOS",
        descriptions: [
            "With PCOS, progesterone can be lower.",
            "This can lead to lighter periods or heavier bleeding for some people.",
            "Feeling more tired or unmotivated during this phase is common."
        ]
    ),

    symptoms: PhaseSymptoms(
        heading: "How you may feel",
        introText: "Everyone experiences this phase differently. You may notice some of the following.",
        symptomItems: [
            SymptomItem(
                name: "Cramps",
                icon: "cramps_icon",
                category: "menstrual"
            ),
            SymptomItem(
                name: "Bloating",
                icon: "bloating_icon",
                category: "menstrual"
            ),
            SymptomItem(
                name: "Acne",
                icon: "acne_icon",
                category: "menstrual"
            ),
            SymptomItem(
                name: "Mood Swings",
                icon: "mood_icon",
                category: "menstrual"
            )
        ]
    ),

    support: PhaseSupport(
        heading: "Support your body today",
        actions: menstrualSupportActions
    )
)
private let menstrualSupportActions: [SupportAction] = [

    // MARK: Physical Care
    SupportAction(
        category: .physicalCare,
        text: "Try gentle stretches like Cat-Cow or Child’s pose to ease cramps."
    ),
    SupportAction(
        category: .physicalCare,
        text: "Use a warm heating pad on your lower abdomen to reduce pain."
    ),
    SupportAction(
        category: .physicalCare,
        text: "Avoid intense workouts today and opt for light movement."
    ),

    // MARK: Diet & Nutrition
    SupportAction(
        category: .dietNutrition,
        text: "Eat anti-inflammatory foods like leafy greens, berries, nuts, olive oil, and turmeric."
    ),
    SupportAction(
        category: .dietNutrition,
        text: "Include iron-rich foods if bleeding feels heavier than usual."
    ),
    SupportAction(
        category: .dietNutrition,
        text: "Drink enough water to help reduce bloating and fatigue."
    ),

    // MARK: Miscellaneous
    SupportAction(
        category: .miscellaneous,
        text: "Prioritize good sleep and give your body permission to rest."
    ),
    SupportAction(
        category: .miscellaneous,
        text: "Practice stress-reducing habits like breathing or journaling."
    ),
    SupportAction(
        category: .miscellaneous,
        text: "Avoid touching or picking acne-prone skin."
    )
]
