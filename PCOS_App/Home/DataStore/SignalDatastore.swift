//
//  SignalDatastore.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 17/02/26.
//
import Foundation

let acnePCOSSignal = PCOSSignal(
    symptomName: "Acne",
    signalTitle:"Coping with Acne",
    signalIllustration: "Acne",
    
    // Screen 1
    infoHeading: "PCOS and Acne",
    scientificReasons: [
        "In PCOS, the ovaries produce higher levels of androgen hormones like testosterone and dehydroepiandrosterone (DHEA)",
        "These hormones stimulate sebaceous glands to produce excess oil and slow skin cell turnover, increasing the risk of clogged pores and acne"
    ],
    
    // Screen 2
    appearanceHeading: "What does PCOS acne look like?",
    appearanceDescriptions: [
        "Deeper acne under the skin, such as cystic acne",
        "Most common on the lower face, including the chin, jawline, and lower cheeks",
        "Red and inflamed acne papules",
        "Breakouts that persist despite consistent skincare or standard acne treatments",
        "May worsen around menstrual periods"
    ],
    
    doctorDisclaimer: "If acne is severe, painful, or not improving with basic care, consult a dermatologist or healthcare professional",
    
    // Screen 3
    supportHeading: "Support your body today",
    supportActions: [
        
        // MARK: Diet / Nutrition
        SupportAction(
            category: .dietNutrition,
            text: "Include anti-inflammatory foods like leafy greens, berries, nuts, olive oil, and turmeric"
        ),
        SupportAction(
            category: .dietNutrition,
            text: "Focus on nutrients that support skin health, such as zinc, vitamins A and C, and omega-3 fatty acids"
        ),
        
        // MARK: Physical Care (Skincare / Exercise)
        SupportAction(
            category: .physicalCare,
            text: "Use gentle acne treatments like benzoyl peroxide or salicylic acid for mild breakouts"
        ),
        SupportAction(
            category: .physicalCare,
            text: "Wash your face twice daily with a mild cleanser and use non-comedogenic skincare products"
        ),
        SupportAction(
            category: .physicalCare,
            text: "Avoid picking or squeezing acne lesions to reduce scarring."
        ),
        
        // MARK: Miscellaneous (Sleep / Habits / Home Care)
        SupportAction(
            category: .miscellaneous,
            text: "Prioritize good sleep and manage stress, as hormonal acne can worsen with poor rest"
        ),
        SupportAction(
            category: .miscellaneous,
            text: "Remove makeup thoroughly at the end of the day."
        ),
        SupportAction(
            category: .miscellaneous,
            text: "Avoid excessive sun exposure, especially when using acne treatments that increase skin sensitivity."
        )
    ]
)

let hirsutismPCOSSignal = PCOSSignal(
    symptomName: "Hirsutism",
    signalTitle: "Managing Excess Hair Growth",
    signalIllustration: "Acne",

    infoHeading: "PCOS and Hirsutism",
    scientificReasons: [
        "Hirsutism refers to thick, dark hair growth in areas where women typically have minimal hair",
        "In PCOS, hormonal imbalances cause the ovaries to produce higher levels of androgens. Excess androgens stimulate hair follicles, leading to increased coarse hair growth"
    ],

    appearanceHeading: "Where can excess hair appear?",
    appearanceDescriptions: [
        "Face (upper lip, chin, jawline)",
        "Neck",
        "Chest",
        "Lower abdomen",
        "Lower back",
        "Inner thighs",
        "Buttocks"
    ],

//    // Screen 3 – Emotional Impact (Still Yellow informational)
//    additionalInfoHeading: "How it may affect you",
//    additionalInfoDescriptions: [
//        "Hirsutism does not harm your physical health.",
//        "However, it can impact self-esteem, confidence, and emotional well-being.",
//        "Some individuals may experience stress, anxiety, or depression related to unwanted hair growth."
//    ],

    doctorDisclaimer: "If you notice sudden, rapidly increasing hair growth, irregular periods, or significant emotional distress, consult a healthcare professional.",

    supportHeading: "Support your body today",
    supportActions: [

        // MARK: Diet / Nutrition
        SupportAction(
            category: .dietNutrition,
            text: "Adopt a balanced diet rich in fruits, vegetables, whole grains, and lean proteins"
        ),
        SupportAction(
            category: .dietNutrition,
            text: "Limit processed foods and sugary beverages to support hormonal balance"
        ),

        // MARK: Physical Care / Hair Management
        SupportAction(
            category: .physicalCare,
            text: "Temporary hair removal methods such as shaving, waxing, or plucking can help manage unwanted hair"
        ),
        SupportAction(
            category: .physicalCare,
            text: "Long-term options like laser hair removal or electrolysis may be considered under professional guidance"
        ),
        SupportAction(
            category: .physicalCare,
            text: "Prescription treatments such as oral contraceptives or anti-androgen medications may help reduce hair growth when recommended by a healthcare provider"
        ),

        // MARK: Miscellaneous (Lifestyle / Emotional Support)
        SupportAction(
            category: .miscellaneous,
            text: "Engage in regular exercise to support hormone regulation and overall well-being"
        ),
        SupportAction(
            category: .miscellaneous,
            text: "Manage stress through activities such as yoga, meditation, or spending time with supportive people"
        ),
        SupportAction(
            category: .miscellaneous,
            text: "Consider speaking with a therapist or joining a support group if emotional distress becomes overwhelming"
        )
    ]
)

let crampsPCOSSignal = PCOSSignal(
    symptomName: "Cramps",
    signalTitle: "Managing Menstrual Cramps",
    signalIllustration: "Cramps",

    infoHeading: "PCOS and Period Pain",
    scientificReasons: [
        "In PCOS, irregular ovulation can cause the uterine lining to become thicker before shedding. A thicker lining may result in heavier bleeding and stronger uterine contractions",
        "Hormonal imbalances, such as higher estrogen and lower progesterone, can intensify cramping. Inflammation, which is common in PCOS, may increase pain sensitivity during menstruation"
    ],

    appearanceHeading: "Why do cramps feel stronger?",
    appearanceDescriptions: [
        "Uterine contractions are triggered by prostaglandins, chemicals involved in inflammation",
        "Higher prostaglandin levels can cause stronger, more painful contractions",
        "Pain may be felt in the lower abdomen, lower back, or thighs",
        "Symptoms may include nausea, fatigue, or headaches alongside cramping"
    ],

    doctorDisclaimer: "If your period pain is severe, worsening, interfering with daily life, or not improving with basic care, consult a healthcare professional for evaluation",

    supportHeading: "Support your body today",
    supportActions: [

        // MARK: Medication Support
//        SupportAction(
//            category: .miscellaneous,
//            text: "Over-the-counter pain relievers such as ibuprofen or aspirin may help reduce cramps by lowering prostaglandins when taken at the first sign of discomfort"
//        ),

        // MARK: Heat Therapy
        SupportAction(
            category: .physicalCare,
            text: "Apply heat using a hot water bottle, heating pad, or warm bath to relax uterine muscles and improve blood flow"
        ),

        // MARK: Diet / Nutrition
        SupportAction(
            category: .dietNutrition,
            text: "Include anti-inflammatory foods such as fatty fish, flaxseeds, chia seeds, berries, leafy greens, turmeric, and ginger"
        ),
        SupportAction(
            category: .dietNutrition,
            text: "Limit highly processed foods and sugary drinks to help reduce inflammation over time"
        ),

        // MARK: Movement / Yoga
        SupportAction(
            category: .physicalCare,
            text: "Gentle yoga poses such as Child’s Pose, Cat-Cow, Reclining Twist, Pigeon Pose, and Savasana might help"
        ),
        SupportAction(
            category: .physicalCare,
            text: "Light stretching, walking, or low-impact movement can support circulation and reduce stiffness"
        ),

        // MARK: Self-Care
        SupportAction(
            category: .miscellaneous,
            text: "Try gentle abdominal massage to encourage blood flow and muscle relaxation"
        ),
        SupportAction(
            category: .miscellaneous,
            text: "Practice stress management techniques such as deep breathing or meditation, as stress can heighten pain sensitivity"
        ),

        // MARK: Supplements
//        SupportAction(
//            category: .dietNutrition,
//            text: "Certain supplements such as myo-inositol may support hormonal balance but consult a healthcare professional before starting any supplement"
//        )
    ]
)

let skinDarkeningPCOSSignal = PCOSSignal(
    symptomName: "Skin Darkening",
    signalTitle: "Understanding Skin Darkening",
    signalIllustration: "SkinDarkening",

    infoHeading: "PCOS and Skin Darkening",
    scientificReasons: [
        "Skin darkening in PCOS is often linked to insulin resistance and hormonal imbalance. High insulin levels can stimulate skin cells to grow and produce more pigment",
        "Elevated androgen levels may also contribute to hyperpigmentation",
        "A common form of PCOS-related skin darkening is called acanthosis nigricans"
    ],

    appearanceHeading: "What does it look like?",
    appearanceDescriptions: [
        "Dark, velvety patches of skin",
        "Commonly appears on the neck, underarms, groin, inner thighs, or under the breasts",
        "Skin may feel thicker or slightly raised",
        "Usually develops gradually over time"
    ],

    doctorDisclaimer: "If skin darkening appears suddenly, spreads rapidly, or is accompanied by other concerning symptoms, consult a healthcare professional for proper evaluation",

    supportHeading: "Support your body today",
    supportActions: [

        // MARK: Metabolic Support
        SupportAction(
            category: .dietNutrition,
            text: "Follow a balanced, low-glycemic diet to support insulin sensitivity"
        ),
        SupportAction(
            category: .physicalCare,
            text: "Maintain regular physical activity to help improve insulin regulation"
        ),
        SupportAction(
            category: .dietNutrition,
            text: "Maintain a healthy weight when possible to reduce insulin resistance"
        ),

        // MARK: Skincare
        SupportAction(
            category: .physicalCare,
            text: "Use gentle skincare products and avoid harsh scrubbing of darkened areas"
        ),
        SupportAction(
            category: .miscellaneous,
            text: "Wear breathable fabrics to reduce friction in affected areas"
        ),
        SupportAction(
            category: .physicalCare,
            text: "Consult a dermatologist about topical treatments such as retinoids or pigment-lightening agents if needed"
        ),

        // MARK: Medical Support
        SupportAction(
            category: .miscellaneous,
            text: "Medications that address insulin resistance or hormonal imbalance may help improve skin changes under medical supervision"
        ),
        SupportAction(
            category: .miscellaneous,
            text: "Regular health check-ups can help monitor insulin levels and prevent worsening symptoms"
        )
    ]
)

let hairLossPCOSSignal = PCOSSignal(
    symptomName: "Hair Loss",
    signalTitle: "Understanding PCOS Hair Loss",
    signalIllustration: "HairLoss",
    
    infoHeading: "PCOS and Hair Loss",
    scientificReasons: [
        "Elevated androgen levels can shrink hair follicles.",
        "This may lead to thinning hair or hair loss over time."
    ],
    
    appearanceHeading: "What does it look like?",
    appearanceDescriptions: [
        "Gradual thinning at the crown",
        "Widening part line",
        "Overall reduced hair density"
    ],
    
    doctorDisclaimer: "Consult a healthcare provider if hair loss is sudden or severe.",
    
    supportHeading: "Support your hair health",
    supportActions: [
        SupportAction(category: .dietNutrition, text: "Include protein-rich foods in your diet."),
        SupportAction(category: .miscellaneous, text: "Manage stress to reduce hormonal impact.")
    ]
)
