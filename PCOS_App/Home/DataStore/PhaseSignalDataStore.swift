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
            //return ovulationSignal
        case .ovulation:
            return ovulationSignal
        case .luteal:
            return lutealSignal
        case .follicular:
            return follicularSignal
            
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
                icon: "AbdominalCrampsIcon",
                category: "menstrual"
            ),
            SymptomItem(
                name: "Bloating",
                icon: "BloatingIcon",
                category: "menstrual"
            ),
            SymptomItem(
                name: "Acne",
                icon: "AcneIcon",
                category: "menstrual"
            ),
            SymptomItem(
                name: "Mood Swings",
                icon: "DepressedIcon",
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
// MARK: - Ovulation Phase Data

// MARK: - Ovulation Phase Data

private let ovulationSignal = PhaseSignal(
    phase: .ovulation,
    illustration: "ovulation_phase_illustration",
    cards: [.understanding, .symptoms, .support],

    understanding: PhaseUnderstanding(
        heading: "Ovulation in PCOS",
        descriptions: [
            "Ovulation happens when an ovary releases an egg. In people with PCOS, ovulation may not occur regularly because hormone levels can be imbalanced.",
            "When ovulation does occur, estrogen levels are usually higher. Many people notice increased energy, clearer thinking, and improved mood.",
            "Fertility is highest around ovulation because the body is preparing for a possible pregnancy."
        ]
    ),

    symptoms: PhaseSymptoms(
        heading: "How you may feel",
        introText: "Hormones can peak around ovulation. If ovulation occurs, you may notice some of these changes.",
        symptomItems: [

            SymptomItem(
                name: "Acne",
                icon: "AcneIcon",
                category: "Skin and Hair"
            ),

            SymptomItem(
                name: "Fatigue",
                icon: "FatigueIcon",
                category: "Lifestyle"
            ),

            SymptomItem(
                name: "Bloating",
                icon: "BloatingIcon",
                category: "Gut Health"
            ),

            SymptomItem(
                name: "Headache",
                icon: "HeadacheIcon",
                category: "Pain"
            )
        ]
    ),

    support: PhaseSupport(
        heading: "Support your body today",
        actions: ovulationSupportActions
    )
)
private let ovulationSupportActions: [SupportAction] = [

    // MARK: Physical Care
    SupportAction(
        category: .physicalCare,
        text: "Energy levels may be higher during ovulation. Moderate exercise or strength training can feel easier during this phase."
    ),

    SupportAction(
        category: .physicalCare,
        text: "Stay hydrated and maintain balanced meals to support hormone balance and steady energy."
    ),

    // MARK: Diet & Nutrition
    SupportAction(
        category: .dietNutrition,
        text: "Eating protein, healthy fats, and fiber can help stabilize blood sugar, which is especially important for people with PCOS."
    ),

    SupportAction(
        category: .dietNutrition,
        text: "Foods rich in magnesium and zinc may support hormonal health."
    ),

    // MARK: Miscellaneous
    SupportAction(
        category: .miscellaneous,
        text: "Fertility is highest around ovulation. Tracking your cycle can help you better understand your body's patterns."
    ),

    SupportAction(
        category: .miscellaneous,
        text: "Some people notice increased confidence, sociability, or sex drive during ovulation due to higher estrogen levels."
    )
]


// MARK: - Follicular Phase Data

private let follicularSignal = PhaseSignal(
    phase: .follicular,
    illustration: "follicular_phase_illustration",
    cards: [.understanding, .symptoms, .support],

    understanding: PhaseUnderstanding(
        heading: "Follicular Phase in PCOS",
        descriptions: [
            "The follicular phase begins after menstruation and lasts until ovulation.",
            "During this time, estrogen levels gradually increase as the body prepares an egg for release.",
            "In people with PCOS, this phase may last longer because ovulation can be delayed or irregular."
        ]
    ),

    symptoms: PhaseSymptoms(
        heading: "How you may feel",
        introText: "As estrogen rises, many people notice improved mood, focus, and motivation.",
        symptomItems: [

            SymptomItem(
                name: "Fatigue",
                icon: "FatigueIcon",
                category: "Lifestyle"
            ),

            SymptomItem(
                name: "Acne",
                icon: "AcneIcon",
                category: "Skin and Hair"
            ),

            SymptomItem(
                name: "Bloating",
                icon: "BloatingIcon",
                category: "Gut Health"
            ),

            SymptomItem(
                name: "Headache",
                icon: "HeadacheIcon",
                category: "Pain"
            )
        ]
    ),

    support: PhaseSupport(
        heading: "Support your body today",
        actions: follicularSupportActions
    )
)
private let follicularSupportActions: [SupportAction] = [

    // MARK: Physical Care
    SupportAction(
        category: .physicalCare,
        text: "Energy may begin to improve during this phase, making it a good time to gradually increase physical activity."
    ),

    SupportAction(
        category: .physicalCare,
        text: "Strength training or moderate workouts may feel easier as estrogen rises."
    ),

    // MARK: Diet & Nutrition
    SupportAction(
        category: .dietNutrition,
        text: "Focus on balanced meals with protein, healthy fats, and fiber to support blood sugar stability in PCOS."
    ),

    SupportAction(
        category: .dietNutrition,
        text: "Include leafy greens, whole grains, and anti-inflammatory foods."
    ),

    // MARK: Miscellaneous
    SupportAction(
        category: .miscellaneous,
        text: "Mental clarity and motivation often increase in this phase, making it a good time for planning or creative work."
    ),

    SupportAction(
        category: .miscellaneous,
        text: "Tracking your cycle can help you recognize when ovulation may occur."
    )
]
// MARK: - Luteal Phase Data

private let lutealSignal = PhaseSignal(
    phase: .luteal,
    illustration: "luteal_phase_illustration",
    cards: [.understanding, .symptoms, .support],

    understanding: PhaseUnderstanding(
        heading: "Luteal Phase in PCOS",
        descriptions: [
            "The luteal phase occurs after ovulation when progesterone levels rise.",
            "Progesterone prepares the body for a possible pregnancy.",
            "With PCOS, hormone fluctuations during this phase may contribute to symptoms like fatigue, mood changes, or acne."
        ]
    ),

    symptoms: PhaseSymptoms(
        heading: "How you may feel",
        introText: "Hormone changes during the luteal phase can cause both physical and emotional symptoms.",
        symptomItems: [

            SymptomItem(
                name: "Bloating",
                icon: "BloatingIcon",
                category: "Gut Health"
            ),

            SymptomItem(
                name: "Fatigue",
                icon: "FatigueIcon",
                category: "Lifestyle"
            ),

            SymptomItem(
                name: "Acne",
                icon: "AcneIcon",
                category: "Skin and Hair"
            ),

            SymptomItem(
                name: "Depressed",
                icon: "DepressedIcon",
                category: "Lifestyle"
            )
        ]
    ),

    support: PhaseSupport(
        heading: "Support your body today",
        actions: lutealSupportActions
    )
)
private let lutealSupportActions: [SupportAction] = [

    // MARK: Physical Care
    SupportAction(
        category: .physicalCare,
        text: "Gentle exercise such as walking, yoga, or stretching may help reduce bloating and discomfort."
    ),

    SupportAction(
        category: .physicalCare,
        text: "Prioritize sleep and rest as energy levels may decrease in this phase."
    ),

    // MARK: Diet & Nutrition
    SupportAction(
        category: .dietNutrition,
        text: "Balanced meals with protein and complex carbohydrates may help stabilize blood sugar."
    ),

    SupportAction(
        category: .dietNutrition,
        text: "Magnesium-rich foods such as nuts, seeds, and leafy greens may support mood and muscle relaxation."
    ),

    // MARK: Miscellaneous
    SupportAction(
        category: .miscellaneous,
        text: "Mood changes are common during this phase. Gentle self-care and stress management can help."
    ),

    SupportAction(
        category: .miscellaneous,
        text: "Tracking symptoms can help you recognize patterns in your cycle."
    )
]
