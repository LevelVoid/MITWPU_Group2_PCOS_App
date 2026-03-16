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
    signalIllustration: "hirsutism",
    
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

let fatiguePCOSSignal = PCOSSignal(
    symptomName: "Fatigue",
    signalTitle: "PCOS and Low Energy",
    signalIllustration: "fatigue",
    
    infoHeading: "Why fatigue can occur in PCOS",
    scientificReasons: [
        "**Insulin resistance**, common in PCOS, can lead to unstable blood sugar levels, contributing to frequent energy crashes.",
        "**Hormonal imbalances** and **sleep disturbances**, such as poor sleep quality or sleep apnea, often result in chronic tiredness."
    ],
    
    appearanceHeading: "How PCOS fatigue may feel",
    appearanceDescriptions: [
        "Feeling tired even after adequate sleep",
        "Low stamina during daily activities",
        "Difficulty concentrating or brain fog",
        "Energy crashes after meals"
    ],
    
    doctorDisclaimer: "Consult a healthcare professional if fatigue is severe, persistent, or associated with dizziness, fainting, or unexplained weight changes.",
    
    supportHeading: "Ways to Support Energy Levels",
    
    supportActions: [
        
        SupportAction(category: .dietNutrition, text: "Eat balanced meals containing protein, healthy fats, and complex carbohydrates such as eggs with whole grain toast or lentils with brown rice to stabilize blood sugar."),
        
        SupportAction(category: .dietNutrition, text: "Include iron-rich foods such as spinach, lentils, tofu, pumpkin seeds, and chickpeas to support energy levels."),
        
        SupportAction(category: .dietNutrition, text: "Add magnesium-rich foods such as almonds, cashews, avocado, and dark leafy greens which support energy metabolism."),
        
        SupportAction(category: .dietNutrition, text: "Avoid high-sugar foods like pastries, sugary drinks, and refined snacks that can cause rapid blood sugar spikes and crashes."),
        
        SupportAction(category: .physicalCare, text: "Perform 30 minutes of brisk walking daily at a pace where talking is possible but slightly challenging to improve metabolic health."),
        
        SupportAction(category: .physicalCare, text: "Strength train 2–3 times per week using exercises such as squats, glute bridges, and resistance band rows to improve insulin sensitivity."),
        
        SupportAction(category: .miscellaneous, text: "Expose yourself to morning sunlight for 15–20 minutes to help regulate circadian rhythm and improve daytime energy."),
        
        SupportAction(category: .miscellaneous, text: "Maintain consistent sleep timing and aim for 7–9 hours of sleep each night."),
        SupportAction(
            category: .dietNutrition,
            text: "Include protein sources such as eggs, Greek yogurt, tofu, or lentils in each meal to prevent rapid energy crashes."
        ),
        
        SupportAction(
            category: .dietNutrition,
            text: "Consume vitamin B12 rich foods such as dairy, eggs, or fortified cereals which support red blood cell production and energy metabolism."
        ),
        
        SupportAction(
            category: .physicalCare,
            text: "Perform light stretching routines such as Cat-Cow, Forward Fold, and gentle spinal twists to reduce physical fatigue and stiffness."
        ),
        
        SupportAction(
            category: .physicalCare,
            text: "Use resistance training exercises such as lunges, push-ups, and resistance band rows to build muscle and improve metabolic health."
        ),
        
        SupportAction(
            category: .miscellaneous,
            text: "Break long sedentary periods by standing or walking for a few minutes every hour to improve circulation and alertness."
        )
    ]
)

let moodSwingsPCOSSignal = PCOSSignal(
    symptomName: "Mood Swings",
    signalTitle: "Hormones and Mood Changes",
    signalIllustration: "mood_swings",
    
    infoHeading: "Why mood swings can occur in PCOS",
    scientificReasons: [
        "Fluctuations in estrogen, progesterone, and androgens can influence neurotransmitters such as serotonin and dopamine that regulate mood.",
        "Blood sugar instability caused by insulin resistance may also contribute to irritability and mood changes."
    ],
    
    appearanceHeading: "What mood swings may feel like",
    appearanceDescriptions: [
        "Sudden emotional changes throughout the day",
        "Irritability or frustration",
        "Feeling unusually sensitive or overwhelmed",
        "Periods of low motivation"
    ],
    
    doctorDisclaimer: "Seek professional help if mood changes become persistent or interfere with daily functioning.",
    
    supportHeading: "Ways to Support Emotional Balance",
    
    supportActions: [
        
        SupportAction(category: .dietNutrition, text: "Include omega-3 rich foods such as salmon, sardines, walnuts, or chia seeds which support brain health and mood regulation."),
        
        SupportAction(category: .dietNutrition, text: "Consume complex carbohydrates such as oats, quinoa, and sweet potatoes to support stable serotonin production."),
        
        SupportAction(category: .dietNutrition, text: "Avoid high-sugar desserts and ultra-processed snacks which can worsen blood sugar fluctuations."),
        
        SupportAction(category: .physicalCare, text: "Engage in moderate aerobic exercise such as jogging, cycling, or brisk walking for 30 minutes to improve mood-related neurotransmitters."),
        
        SupportAction(category: .physicalCare, text: "Practice yoga poses such as Bridge Pose, Warrior II, and Tree Pose which may help regulate stress responses."),
        
        SupportAction(category: .miscellaneous, text: "Track mood changes alongside menstrual cycle patterns to identify hormonal triggers."),
        SupportAction(
            category: .dietNutrition,
            text: "Include foods rich in magnesium such as pumpkin seeds, almonds, and spinach which may help regulate mood and reduce irritability."
        ),

        SupportAction(
            category: .dietNutrition,
            text: "Eat regular meals every 3–4 hours to avoid blood sugar drops that can worsen irritability and mood changes."
        ),

        SupportAction(
            category: .physicalCare,
            text: "Engage in rhythmic aerobic activities such as swimming or cycling which can support endorphin release."
        ),

        SupportAction(
            category: .miscellaneous,
            text: "Practice mindfulness meditation for 10–15 minutes daily to improve emotional regulation."
        )
    ]
)

let depressionPCOSSignal = PCOSSignal(
    symptomName: "Depressed",
    signalTitle: "PCOS and Depressive Symptoms",
    signalIllustration: "depressed",

    infoHeading: "Why depression risk may be higher in PCOS",
    scientificReasons: [
        "Hormonal imbalance in PCOS can influence neurotransmitters such as serotonin and dopamine that regulate mood.",
        "Insulin resistance and chronic inflammation associated with PCOS may also affect brain chemistry and increase the risk of depressive symptoms."
    ],

    appearanceHeading: "Common depressive symptoms",
    appearanceDescriptions: [
        "Persistent sadness or low mood",
        "Loss of interest in activities once enjoyed",
        "Low energy, fatigue, or difficulty concentrating",
        "Changes in sleep or appetite"
    ],

    doctorDisclaimer: "Seek professional support if depressive symptoms persist, worsen, interfere with daily life, or include thoughts of self-harm.",

    supportHeading: "Ways to Support Mental Health",

    supportActions: [

        // MARK: Mood-supportive nutrition
        SupportAction(
            category: .dietNutrition,
            text: "Eat tryptophan-rich foods like eggs, oats, and tofu to support serotonin."
        ),

        SupportAction(
            category: .dietNutrition,
            text: "Consume omega-3 sources like salmon and walnuts for mood regulation."
        ),

        SupportAction(
            category: .dietNutrition,
            text: "Add fermented foods like yogurt to support gut health and mood."
        ),

        SupportAction(
            category: .dietNutrition,
            text: "Avoid highly processed foods and excess sugar to reduce inflammation."
        ),

        // MARK: Physical activity
        SupportAction(
            category: .physicalCare,
            text: "Engage in moderate aerobic exercise for 30–45 mins to release endorphins."
        ),

        SupportAction(
            category: .physicalCare,
            text: "Strength train 2-3 times per week to support mood and metabolic health."
        ),

        // MARK: Nervous system regulation
        SupportAction(
            category: .physicalCare,
            text: "Practice relaxing yoga poses like Child’s Pose to reduce stress."
        ),

        // MARK: Lifestyle support
        SupportAction(
            category: .miscellaneous,
            text: "Spend 15–20 mins outdoors daily to support circadian rhythm."
        ),

        SupportAction(
            category: .miscellaneous,
            text: "Maintain consistent sleep times for optimal hormonal balance."
        ),

        SupportAction(
            category: .miscellaneous,
            text: "Reach out to a professional or loved one if mood symptoms persist."
        ),

        SupportAction(
            category: .miscellaneous,
            text: "Track mood, sleep, and cycle patterns to identify potential triggers."
        )
    ]
)

let anxietyPCOSSignal = PCOSSignal(
    symptomName: "Anxiety",
    signalTitle: "PCOS and Anxiety",
    signalIllustration: "anxiety",
    
    infoHeading: "Why anxiety can occur in PCOS",
    scientificReasons: [
        "Hormonal imbalance in PCOS can influence neurotransmitters such as serotonin and GABA that regulate mood and stress responses.",
        "Insulin resistance and chronic inflammation associated with PCOS may increase cortisol levels, which can worsen anxiety and nervous system hyperarousal."
    ],
    
    appearanceHeading: "Common anxiety experiences",
    appearanceDescriptions: [
        "Persistent worry or racing thoughts",
        "Difficulty relaxing or feeling constantly on edge",
        "Sleep disturbances or trouble falling asleep",
        "Physical symptoms such as muscle tension, rapid heartbeat, or restlessness"
    ],
    
    doctorDisclaimer: "Seek professional medical care if anxiety becomes severe, causes panic attacks, interferes with daily functioning, or is associated with thoughts of self-harm.",
    
    supportHeading: "Ways to Support Mental Well-being",
    
    supportActions: [
        
        // MARK: Nervous System Regulation Exercises
        SupportAction(
            category: .physicalCare,
            text: "Practice diaphragmatic breathing (4s inhale, 6s exhale) to relax."
        ),
        SupportAction(
            category: .physicalCare,
            text: "Try box breathing (4s hold on each phase) to calm acute anxiety."
        ),
        
        // MARK: Yoga Poses for Anxiety
        SupportAction(
            category: .physicalCare,
            text: "Practice Child’s Pose for 3–5 mins to promote relaxation."
        ),
        SupportAction(
            category: .physicalCare,
            text: "Legs Up the Wall Pose for 5–10 mins to lower stress."
        ),
        SupportAction(
            category: .physicalCare,
            text: "Do 10–15 slow Cat-Cow flows to reduce tension."
        ),
        
        // MARK: Cardio for Stress Reduction
        SupportAction(
            category: .physicalCare,
            text: "Brisk walking for 30 mins helps regulate cortisol."
        ),
        SupportAction(
            category: .physicalCare,
            text: "Moderate cycling or swimming for 25–40 mins improves mood."
        ),
        
        // MARK: Foods That Support Calm Mood
        SupportAction(
            category: .dietNutrition,
            text: "Eat magnesium-rich foods like pumpkin seeds to support relaxation."
        ),
        SupportAction(
            category: .dietNutrition,
            text: "Eat omega-3 sources like salmon to help reduce inflammation."
        ),
        SupportAction(
            category: .dietNutrition,
            text: "Include fermented foods like yogurt to support a healthy gut microbiome."
        ),
        SupportAction(
            category: .dietNutrition,
            text: "Consume complex carbs like oats to support stable serotonin production."
        ),
        
        // MARK: Things to Limit
        SupportAction(
            category: .dietNutrition,
            text: "Limit excessive caffeine intake as it can increase anxiety symptoms."
        ),
        SupportAction(
            category: .dietNutrition,
            text: "Reduce refined sugars which can cause blood sugar spikes."
        ),
        
        // MARK: Sleep and Stress Management
        SupportAction(
            category: .miscellaneous,
            text: "Maintain a consistent sleep schedule to support hormone regulation."
        ),
        SupportAction(
            category: .miscellaneous,
            text: "Spend 15–20 mins outdoors in sunlight daily to balance cortisol."
        ),
        SupportAction(
            category: .miscellaneous,
            text: "Track anxiety episodes, sleep, and cycles to identify triggers."
        ),
        SupportAction(
            category: .physicalCare,
            text: "Practice progressive muscle relaxation for 10-15 mins to reduce tension."
        ),

        SupportAction(
            category: .physicalCare,
            text: "Perform a 20-30 min yoga session to activate parasympathetic system."
        ),

        SupportAction(
            category: .dietNutrition,
            text: "Include B6-rich foods like bananas to support mood regulation."
        ),

        SupportAction(
            category: .dietNutrition,
            text: "Consume chamomile or lemon balm tea to support relaxation and sleep."
        ),

        SupportAction(
            category: .dietNutrition,
            text: "Limit ultra-processed snacks which worsen blood sugar fluctuations."
        ),

        SupportAction(
            category: .miscellaneous,
            text: "Reduce late-night screen exposure to support melatonin production."
        ),

        SupportAction(
            category: .miscellaneous,
            text: "Keep a journal to track anxiety triggers, sleep, and menstrual cycle."
        )
    ]
)


let crampsPCOSSignal = PCOSSignal(
    symptomName: "Cramps",
    signalTitle: "Managing Menstrual Cramps",
    signalIllustration: "cramps",
    
    infoHeading: "PCOS and Period Pain",
    scientificReasons: [
        "In PCOS, **irregular ovulation** can cause the uterine lining to become thicker before shedding, leading to **heavier bleeding** and **stronger contractions**.",
        "Higher estrogen and lower progesterone levels exacerbate cramping. **Inflammation**, common in PCOS, further increases pain sensitivity."
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
            text: "Wear a well-fitted, supportive bra, especially during sensitive days."
        ),
        
        // MARK: Gentle Movement
        SupportAction(
            category: .physicalCare,
            text: "Light movement and gentle upper-body stretching reduces muscle tension."
        ),
        
        // MARK: Nutrition
        SupportAction(
            category: .dietNutrition,
            text: "Include foods rich in healthy fats and micronutrients like nuts and seeds."
        ),
        SupportAction(
            category: .dietNutrition,
            text: "Consult a professional before using Vitamin E for cyclic mastalgia."
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

let vulvarPainPCOSSignal = PCOSSignal(
    symptomName: "Vulvar Pain",
    signalTitle: "Vulvar Discomfort",
    signalIllustration: "vulvar_pain",
    
    infoHeading: "Why vulvar pain may occur",
    scientificReasons: [
        "Hormonal fluctuations can influence vaginal tissue health and lubrication levels.",
        "Irritation, infections, or inflammation may contribute to vulvar discomfort."
    ],
    
    appearanceHeading: "What vulvar pain may feel like",
    appearanceDescriptions: [
        "Burning or stinging sensation",
        "Tenderness or soreness",
        "Pain during sitting or sexual activity"
    ],
    
    doctorDisclaimer: "Seek medical evaluation if vulvar pain is persistent, severe, or associated with unusual discharge, swelling, or fever.",
    
    supportHeading: "Ways to Support Vulvar Comfort",
    
    supportActions: [
        
        SupportAction(category: .dietNutrition, text: "Stay well hydrated to support mucosal tissue health."),
        
        SupportAction(category: .physicalCare, text: "Perform pelvic floor relaxation exercises such as diaphragmatic breathing combined with gentle pelvic floor release."),
        
        SupportAction(category: .miscellaneous, text: "Avoid scented soaps, harsh cleansers, or fragranced hygiene products that may irritate vulvar skin."),
        
        SupportAction(category: .miscellaneous, text: "Wear breathable cotton underwear and avoid prolonged moisture exposure.")
    ]
)

let bloatingPCOSSignal = PCOSSignal(
    symptomName: "Bloating",
    signalTitle: "Hormones and Digestive Bloating",
    signalIllustration: "bloating",
    
    infoHeading: "Why bloating can occur",
    scientificReasons: [
        "Hormonal fluctuations can influence digestion and water retention, contributing to abdominal bloating.",
        "Changes in gut microbiome and insulin resistance may also affect digestion and gas production."
    ],
    
    appearanceHeading: "What bloating may feel like",
    appearanceDescriptions: [
        "Abdominal fullness or tightness",
        "Visible stomach swelling",
        "Pressure or discomfort after meals"
    ],
    
    doctorDisclaimer: "Seek medical advice if bloating is severe, persistent, or associated with vomiting, fever, or unexplained weight loss.",
    
    supportHeading: "Ways to Support Digestive Comfort",
    
    supportActions: [
        
        SupportAction(category: .dietNutrition, text: "Eat slowly and chew food thoroughly to reduce swallowed air and digestive stress."),
        
        SupportAction(category: .dietNutrition, text: "Include probiotic foods such as yogurt, kefir, or fermented vegetables to support gut microbiome balance."),
        
        SupportAction(category: .dietNutrition, text: "Limit carbonated beverages, chewing gum, and highly processed foods that may worsen bloating."),
        
        SupportAction(category: .physicalCare, text: "Take a 10–15 minute walk after meals to stimulate digestion and reduce bloating."),
        
        SupportAction(category: .physicalCare, text: "Practice yoga poses such as Wind-Relieving Pose (Pavanamuktasana) and Supine Twist to support digestive movement."),
        SupportAction(
            category: .dietNutrition,
            text: "Reduce large high-fat meals which may slow stomach emptying and worsen bloating."
        ),

        SupportAction(
            category: .dietNutrition,
            text: "Use digestive spices such as ginger or peppermint which may help reduce gastrointestinal discomfort."
        ),

        SupportAction(
            category: .physicalCare,
            text: "Perform gentle abdominal massage in clockwise circular motions to stimulate bowel movement."
        ),

        SupportAction(
            category: .physicalCare,
            text: "Try the yoga pose Apanasana (Knees-to-Chest Pose) for several slow breaths to help release trapped gas."
        )
    ]
)


let constipationPCOSSignal = PCOSSignal(
    symptomName: "Constipated",
    signalTitle: "Hormones and Slow Digestion",
    signalIllustration: "constipated",
    
    infoHeading: "Why constipation may occur",
    scientificReasons: [
        "Hormonal fluctuations can influence gastrointestinal motility and slow bowel movements.",
        "Low fiber intake, dehydration, or reduced physical activity may worsen constipation."
    ],
    
    appearanceHeading: "Signs of constipation",
    appearanceDescriptions: [
        "Infrequent bowel movements",
        "Hard or difficult-to-pass stools",
        "Abdominal discomfort or straining"
    ],
    
    doctorDisclaimer: "Seek medical advice if constipation is persistent, severe, or accompanied by blood in stool or unexplained weight loss.",
    
    supportHeading: "Ways to Support Regular Digestion",
    
    supportActions: [
        
        SupportAction(category: .dietNutrition, text: "Increase fiber intake with foods such as oats, chia seeds, flaxseeds, lentils, and vegetables."),
        
        SupportAction(category: .dietNutrition, text: "Drink sufficient water throughout the day to support fiber digestion."),
        
        SupportAction(category: .dietNutrition, text: "Limit excessive processed foods and refined flour products that contain little fiber."),
        
        SupportAction(category: .physicalCare, text: "Perform 20–30 minutes of brisk walking daily to stimulate intestinal movement."),
        
        SupportAction(category: .physicalCare, text: "Yoga poses such as Malasana (Yogic Squat) and Knees-to-Chest Pose may help stimulate bowel movements."),
        SupportAction(
            category: .dietNutrition,
            text: "Include ground flaxseed or chia seeds in oatmeal or yogurt to increase dietary fiber intake."
        ),

        SupportAction(
            category: .dietNutrition,
            text: "Consume prunes or kiwi fruit which may help stimulate bowel movements."
        ),

        SupportAction(
            category: .physicalCare,
            text: "Practice Malasana (Yogic Squat) which may help align the rectum and facilitate easier bowel movements."
        ),

        SupportAction(
            category: .miscellaneous,
            text: "Establish a consistent bathroom routine, such as attempting bowel movements after breakfast when the gastrocolic reflex is strongest."
        )
    ]
)

let diarrheaPCOSSignal = PCOSSignal(
    symptomName: "Diarrhea",
    signalTitle: "Hormones and Digestive Upset",
    signalIllustration: "constipated",
    
    infoHeading: "Why diarrhea can occur in PCOS",
    scientificReasons: [
        "Hormonal fluctuations across the menstrual cycle can influence gastrointestinal motility, sometimes causing faster intestinal movement and loose stools.",
        "Insulin resistance and gut microbiome imbalance associated with PCOS may affect digestion and increase sensitivity to certain foods."
    ],
    
    appearanceHeading: "What diarrhea may feel like",
    appearanceDescriptions: [
        "Frequent loose or watery stools",
        "Urgent need to use the bathroom",
        "Abdominal cramping or discomfort",
        "Possible dehydration or fatigue if episodes persist"
    ],
    
    doctorDisclaimer: "Seek medical care if diarrhea lasts longer than several days, causes dehydration, includes blood in stool, or is accompanied by fever or severe abdominal pain.",
    
    supportHeading: "Ways to Support Digestive Recovery",
    
    supportActions: [
        
        // Hydration
        SupportAction(
            category: .dietNutrition,
            text: "Drink oral rehydration solutions or electrolyte fluids such as coconut water or oral rehydration salts to replace lost fluids and electrolytes."
        ),
        
        SupportAction(
            category: .dietNutrition,
            text: "Consume easily digestible foods such as bananas, white rice, applesauce, and toast which may help firm stools during digestive upset."
        ),
        
        // Gut-soothing foods
        SupportAction(
            category: .dietNutrition,
            text: "Include probiotic foods such as yogurt with live cultures or kefir which may help restore beneficial gut bacteria."
        ),
        
        SupportAction(
            category: .dietNutrition,
            text: "Consume soluble fiber foods such as oats or psyllium husk which may help absorb excess water in the intestines."
        ),
        
        // Foods to limit
        SupportAction(
            category: .dietNutrition,
            text: "Avoid fatty or fried foods which can worsen intestinal irritation and increase bowel movements."
        ),
        
        SupportAction(
            category: .dietNutrition,
            text: "Limit caffeine, alcohol, and very spicy foods which may stimulate bowel motility."
        ),
        
        SupportAction(
            category: .dietNutrition,
            text: "Avoid large amounts of dairy if lactose intolerance symptoms worsen diarrhea."
        ),
        
        // Movement
        SupportAction(
            category: .physicalCare,
            text: "Engage in light walking for 10–15 minutes after meals which may support gentle digestion without stressing the gut."
        ),
        
        // Stress management
        SupportAction(
            category: .miscellaneous,
            text: "Practice relaxation techniques such as slow breathing or meditation since stress can influence the gut–brain axis and worsen digestive symptoms."
        ),
        
        // Tracking
        SupportAction(
            category: .miscellaneous,
            text: "Track foods, stress levels, and menstrual cycle timing to identify potential triggers for digestive flare-ups."
        )
    ]
)

let gasPCOSSignal = PCOSSignal(
    symptomName: "Gas",
    signalTitle: "Digestive Gas and PCOS",
    signalIllustration: "gas",
    
    infoHeading: "Why gas may occur",
    scientificReasons: [
        "Gut microbiome imbalance and fermentation of certain foods in the intestines can lead to gas production.",
        "Hormonal changes may influence digestive motility and gas buildup."
    ],
    
    appearanceHeading: "Common gas symptoms",
    appearanceDescriptions: [
        "Passing gas frequently",
        "Abdominal pressure or fullness",
        "Bloating or discomfort"
    ],
    
    doctorDisclaimer: "Seek medical advice if gas is severe, persistent, or accompanied by weight loss, vomiting, or severe abdominal pain.",
    
    supportHeading: "Ways to Support Digestive Health",
    
    supportActions: [
        
        SupportAction(category: .dietNutrition, text: "Eat smaller meals and chew food thoroughly to support proper digestion."),
        
        SupportAction(category: .dietNutrition, text: "Limit gas-producing foods such as excessive carbonated drinks or large quantities of fried foods."),
        
        SupportAction(category: .dietNutrition, text: "Include digestive herbs such as ginger or fennel seeds which may help reduce gas."),
        
        SupportAction(category: .physicalCare, text: "Take a gentle walk after meals to support intestinal movement and gas release."),
        
        SupportAction(category: .physicalCare, text: "Practice yoga poses such as Wind-Relieving Pose and Happy Baby Pose which may help relieve gas buildup."),
        SupportAction(
            category: .dietNutrition,
            text: "Reduce rapid eating and avoid drinking through straws which may increase swallowed air."
        ),

        SupportAction(
            category: .dietNutrition,
            text: "Use fennel seeds or ginger tea after meals which may help reduce digestive gas."
        ),

        SupportAction(
            category: .physicalCare,
            text: "Perform gentle torso twists such as Supine Twist to encourage movement of intestinal gas."
        )
    ]
)
