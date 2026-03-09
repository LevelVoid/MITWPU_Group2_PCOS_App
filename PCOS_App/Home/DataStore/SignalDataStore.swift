//
//  SignalDatastore.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 17/02/26.
//
import Foundation

let brownSpottingPCOSSignal = PCOSSignal(
    symptomName: "Brown",
    signalTitle: "Understanding Brown Spotting",
    signalIllustration: "spotting",

    // Screen 1
    infoHeading: "PCOS and Hormonal Patterns",
    scientificReasons: [
        "In PCOS, irregular ovulation can lead to unstable shedding of the uterine lining. Brown spotting usually represents older blood leaving the uterus more slowly.",
        "Irregular cycles in PCOS may expose the endometrium to prolonged estrogen stimulation, increasing abnormal bleeding risk."
    ],

    // Screen 2
    appearanceHeading: "What does brown spotting mean?",
    appearanceDescriptions: [
        "Dark brown discharge outside of your normal period",
        "Often older blood that has oxidized before exiting the body",
        "May occur before or after a period",
        "Can appear after prolonged missed cycles"
    ],

    doctorDisclaimer: "Consult a healthcare professional if spotting becomes persistent, heavy, or occurs alongside prolonged missed periods.",

    // Screen 3
    supportHeading: "Support your body today",
    supportActions: [

        // MARK: Monitoring
        SupportAction(
            category: .miscellaneous,
            text: "Monitor how often spotting occurs and whether it follows missed or irregular cycles"
        ),

        // MARK: Medical Awareness
        SupportAction(
            category: .miscellaneous,
            text: "Persistent spotting in PCOS should be evaluated due to potential endometrial changes"
        ),

        // MARK: Nutrition
        SupportAction(
            category: .dietNutrition,
            text: "If bleeding is frequent, ensure sufficient dietary iron intake to reduce anemia risk"
        ),

        // MARK: Emergency Guidance
        SupportAction(
            category: .miscellaneous,
            text: "Seek urgent care if spotting becomes heavy, is associated with severe pain, dizziness, or suspected pregnancy"
        )
    ]
)



let redSpottingPCOSSignal = PCOSSignal(
    symptomName: "Red",
    signalTitle: "Understanding Red Spotting",
    signalIllustration: "spotting",

    // Screen 1
    infoHeading: "PCOS and Irregular Bleeding",
    scientificReasons: [
        "In PCOS, irregular or absent ovulation (anovulation) can lead to unstable hormone patterns. This hormonal imbalance may cause abnormal uterine bleeding, including spotting outside of expected cycle patterns",
        "Red spotting typically represents fresh bleeding from the uterine lining"
    ],

    // Screen 2
    appearanceHeading: "What does red spotting mean?",
    appearanceDescriptions: [
        "Bright or fresh red blood outside of your normal period",
        "May occur between cycles due to ovulatory dysfunction",
        "Can appear after missed periods",
        "Not a defining PCOS symptom, but irregular bleeding patterns are common in PCOS"
    ],

    doctorDisclaimer: "Seek medical evaluation if spotting is persistent, heavy, occurs after sex, happens between every cycle, or if you experience prolonged missed periods.",

    // Screen 3
    supportHeading: "Support your body today",
    supportActions: [

        // MARK: Monitoring
        SupportAction(
            category: .miscellaneous,
            text: "Track the timing, color, and frequency of spotting in your cycle log"
        ),

        // MARK: Nutrition
        SupportAction(
            category: .dietNutrition,
            text: "If bleeding is frequent or heavier than usual, ensure adequate iron intake through diet"
        ),

        // MARK: Medical Awareness
        SupportAction(
            category: .miscellaneous,
            text: "Do not ignore persistent spotting, especially if you have prolonged gaps between periods"
        ),

        // MARK: Emergency Guidance
        SupportAction(
            category: .miscellaneous,
            text: "Seek immediate care if bleeding soaks a pad hourly, is accompanied by severe pelvic pain, dizziness, fainting, or possible pregnancy"
        )
    ]
)

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



let skinDarkeningPCOSSignal = PCOSSignal(
    symptomName: "Skin Darkening",
    signalTitle: "Understanding Skin Darkening",
    signalIllustration: "skin_darkening",

    infoHeading: "PCOS and Skin Darkening",
    scientificReasons: [
        "Skin darkening in PCOS is often linked to insulin resistance and hormonal imbalance. High insulin levels can stimulate skin cells to grow and produce more pigment",
        "Elevated androgen levels may also contribute to hyperpigmentation. A common form of PCOS-related skin darkening is called acanthosis nigricans"
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
    signalTitle: "Addressing Hair Thinning",
    signalIllustration: "hairloss_illustration",

    // Screen 1
    infoHeading: "How PCOS Can Affect Hair Growth",
    scientificReasons: [
        "PCOS often involves elevated androgen levels. These hormones, especially DHT (dihydrotestosterone), can shrink hair follicles and shorten the hair growth cycle. Insulin resistance may increase androgen production and contribute to inflammation, which can further disrupt normal hair growth.",
        "Chronic low-grade inflammation can push more hair follicles into the resting (telogen) phase, leading to increased shedding."
    ],

    // Screen 2
    appearanceHeading: "What does PCOS-related hair loss look like?",
    appearanceDescriptions: [
        "Gradual thinning at the crown or top of the scalp",
        "Widening of the hair part",
        "Increased hair shedding during washing or brushing",
        "Thinner or more brittle hair strands",
        "Slower hair regrowth over time"
    ],

    doctorDisclaimer: "Consult a healthcare professional if hair loss is sudden, severe, rapidly worsening, or associated with other symptoms such as irregular periods, fatigue, or signs of thyroid imbalance",

    // Screen 3
    supportHeading: "Support your hair and hormonal health",
    supportActions: [

        // MARK: Medical Options
        SupportAction(
            category: .physicalCare,
            text: "Topical treatments such as minoxidil may help stimulate hair growth when used consistently under professional guidance"
        ),
        SupportAction(
            category: .miscellaneous,
            text: "Hormonal treatments or anti-androgen medications may be considered under medical supervision"
        ),

        // MARK: Nutrition
        SupportAction(
            category: .dietNutrition,
            text: "Focus on a balanced diet rich in protein, iron, vitamin D, and omega-3 fatty acids"
        ),
        SupportAction(
            category: .dietNutrition,
            text: "If hair shedding is significant, consider evaluation for iron deficiency, thyroid imbalance, or other nutrient deficiencies"
        ),

        // MARK: Lifestyle
        SupportAction(
            category: .physicalCare,
            text: "Engage in regular physical activity to support insulin sensitivity and hormonal balance"
        ),
        SupportAction(
            category: .miscellaneous,
            text: "Manage stress through mindfulness, yoga, or relaxation techniques, as chronic stress can worsen shedding"
        ),

        // MARK: Hair Care
        SupportAction(
            category: .physicalCare,
            text: "Use gentle, sulphate-free shampoos and avoid excessive heat styling or tight hairstyles that strain hair follicles"
        ),
        SupportAction(
            category: .miscellaneous,
            text: "Protect hair from excessive sun exposure and environmental damage"
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


let lowerBackPCOSSignal = PCOSSignal(
    symptomName: "Lower Back",
    signalTitle: "Lower Back Pain During Periods",
    signalIllustration: "lower_back",

    // Screen 1
    infoHeading: "Why menstrual pain can affect your lower back",
    scientificReasons: [
        "Low back pain is a common symptom of dysmenorrhea (painful periods). Uterine muscle contractions during menstruation can cause pain that radiates to the lower back.",
        "Pelvic muscle tension and inflammation may increase discomfort, which can feel more noticeable in individuals with irregular or painful cycles."
    ],

    // Screen 2
    appearanceHeading: "What does menstrual-related back pain feel like?",
    appearanceDescriptions: [
        "Dull or aching pain in the lower back during your period",
        "Pain that starts with cramps and spreads toward the back",
        "Increased discomfort during heavy or painful cycles",
        "Muscle tightness in the lower back or pelvic area"
    ],

    doctorDisclaimer: "Seek medical evaluation urgently if back pain is accompanied by fever, numbness, weakness, loss of bladder or bowel control, or severe worsening pain.",

    // Screen 3
    supportHeading: "Support your body today",
    supportActions: [

        // MARK: Heat Therapy
        SupportAction(
            category: .physicalCare,
            text: "Apply a warm heat wrap or heating pad to the lower back to help relax muscles and reduce discomfort."
        ),

        // MARK: Movement / Yoga
        SupportAction(
            category: .physicalCare,
            text: "Gentle yoga or stretching such as Child’s Pose, Cat-Cow, Sphinx Pose, or a gentle spinal twist may help ease tension."
        ),
        SupportAction(
            category: .physicalCare,
            text: "Light walking or low-impact movement can support circulation and reduce stiffness."
        ),

        // MARK: Nutrition
        SupportAction(
            category: .dietNutrition,
            text: "Include anti-inflammatory foods such as berries, leafy greens, turmeric, ginger, and omega-3-rich foods."
        ),

        // MARK: Monitoring
        SupportAction(
            category: .miscellaneous,
            text: "Track whether back pain consistently occurs with your menstrual cycle or outside of it."
        )
    ]
)


let tenderBreastsPCOSSignal = PCOSSignal(
    symptomName: "Tender Breasts",
    signalTitle: "Cyclic Breast Tenderness",
    signalIllustration: "tender_breasts",

    // Screen 1
    infoHeading: "Why breast tenderness happens",
    scientificReasons: [
        "Cyclic breast pain (mastalgia) is commonly linked to hormonal changes during the menstrual cycle. Fluctuations in estrogen and progesterone can cause breast tissue swelling, fullness, and tenderness.",
        "Breast discomfort is often more noticeable in the days leading up to a period."
    ],

    // Screen 2
    appearanceHeading: "What does cyclic breast pain feel like?",
    appearanceDescriptions: [
        "Heaviness or fullness in both breasts",
        "Tenderness that worsens before menstruation",
        "Generalized soreness rather than sharp, localized pain",
        "Symptoms that improve after the period begins"
    ],

    doctorDisclaimer: "Seek medical evaluation if breast pain is persistent, occurs in only one area, is accompanied by a lump, nipple discharge, skin changes, or does not follow a menstrual pattern.",

    // Screen 3
    supportHeading: "Support your body today",
    supportActions: [

        // MARK: Support Garments
        SupportAction(
            category: .physicalCare,
            text: "Wear a well-fitted, supportive bra, especially during high-sensitivity days."
        ),

        // MARK: Gentle Movement
        SupportAction(
            category: .physicalCare,
            text: "Light movement and gentle upper-body stretching may help reduce muscle tension."
        ),

        // MARK: Nutrition
        SupportAction(
            category: .dietNutrition,
            text: "Include foods rich in healthy fats and micronutrients, such as nuts and seeds."
        ),
        SupportAction(
            category: .dietNutrition,
            text: "Vitamin E has been studied for cyclic mastalgia, but evidence is mixed. Consult a healthcare professional before starting supplements."
        ),

        // MARK: Monitoring
        SupportAction(
            category: .miscellaneous,
            text: "Track whether tenderness follows a consistent premenstrual pattern."
        )
    ]
)


let headachePCOSSignal = PCOSSignal(
    symptomName: "Headache",
    signalTitle: "Hormonal Headaches",
    signalIllustration: "headache",

    // Screen 1
    infoHeading: "How hormones can trigger headaches",
    scientificReasons: [
        "Estrogen fluctuations across the menstrual cycle, especially estrogen withdrawal before menstruation, are linked to menstrual migraine.",
        "Hormonal imbalance may influence headache frequency and severity. Some studies suggest migraine prevalence may be higher in individuals with PCOS due to hormonal interplay."
    ],

    // Screen 2
    appearanceHeading: "What does a hormonal headache feel like?",
    appearanceDescriptions: [
        "Throbbing or pulsating head pain",
        "Pain that worsens around the menstrual period",
        "Sensitivity to light or sound",
        "Nausea or visual disturbances in migraine cases"
    ],

    doctorDisclaimer: "Seek urgent medical care for sudden severe headache, headache with fever, stiff neck, confusion, weakness, vision loss, or the worst headache of your life.",

    // Screen 3
    supportHeading: "Ways to Manage Headaches",

    supportActions: [

        // MARK: Hydration & Nutrition
        SupportAction(
            category: .dietNutrition,
            text: "Stay well hydrated throughout the day, as dehydration can trigger headaches."
        ),
        SupportAction(
            category: .dietNutrition,
            text: "Avoid skipping meals. Low blood sugar may worsen headaches."
        ),
        SupportAction(
            category: .dietNutrition,
            text: "Include magnesium-rich foods such as spinach, almonds, seeds, and legumes."
        ),
        SupportAction(
            category: .dietNutrition,
            text: "Magnesium supplementation is used in migraine prevention. Consult a healthcare professional before starting supplements."
        ),
        SupportAction(
            category: .dietNutrition,
            text: "Limit excessive caffeine, as both overuse and withdrawal can trigger headaches."
        ),

        // MARK: Movement
        SupportAction(
            category: .physicalCare,
            text: "Engage in regular light aerobic exercise such as walking or cycling to help reduce migraine frequency."
        ),
        SupportAction(
            category: .physicalCare,
            text: "Gentle yoga poses like Child’s Pose, Supine Twist, Forward Fold, or Legs Up the Wall may ease tension."
        ),
        SupportAction(
            category: .physicalCare,
            text: "Neck and shoulder stretches may relieve muscle tension linked to tension-type headaches."
        ),

        // MARK: Sleep
        SupportAction(
            category: .miscellaneous,
            text: "Maintain a consistent sleep schedule, as irregular sleep patterns can trigger migraines."
        ),

        // MARK: Stress Management
        SupportAction(
            category: .miscellaneous,
            text: "Practice stress-reduction techniques such as meditation, deep breathing, or progressive muscle relaxation."
        ),
        SupportAction(
            category: .miscellaneous,
            text: "Consider mindfulness-based practices to reduce stress-related headache triggers."
        ),

        // MARK: Environmental Triggers
        SupportAction(
            category: .miscellaneous,
            text: "Identify and minimize triggers such as bright lights, strong odors, or prolonged screen time."
        ),

        // MARK: Tracking
        SupportAction(
            category: .miscellaneous,
            text: "Track headache timing and symptoms to identify menstrual or hormonal patterns."
        ),

        // MARK: Acute Relief
        SupportAction(
            category: .physicalCare,
            text: "Rest in a dark, quiet room during acute migraine episodes."
        ),
        SupportAction(
            category: .physicalCare,
            text: "Apply a cold compress to the forehead or neck during migraine attacks."
        )
    ]
)
