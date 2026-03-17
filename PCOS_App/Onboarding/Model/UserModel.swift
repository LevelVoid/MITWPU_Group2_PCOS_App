
//
//  UserModel.swift
//  PCOS_App
//

import Foundation


struct UserProfile {

    let name: String
    let dateOfBirth: Date
    let heightInCm: Double
    let weightInKg: Double

    let dietPattern: DietPattern
    let activityLevel: ActivityLevel
//    let primaryFocus: PrimaryFocus?
    let phenotype: PCOSPhenotype

}



enum DietPattern {
    case balanced
    case highSugar
    case irregular
    case unsure
    
    init(rawString: String) {
        switch rawString {
        case "Balanced Diet":    self = .balanced
        case "Frequent Sugar":   self = .highSugar
        case "Irregular Meals":  self = .irregular
        default:                 self = .unsure
        }
    }
}

enum ActivityLevel {
    case sedentary //1.2 : desk job, no exercise
    case lightlyActive // 1.375-light exercise 1-3 days/week
    case active //1.55 - moderate exercise 3-5 days/week
    case veryActive // 1.725 : hard exercise 6-7 days
    
    init(rawString: String) {
        switch rawString {
        case "Sedentary Type":           self = .sedentary
        case "Light Movements":          self = .lightlyActive
        case "Regular Movements":        self = .active
        case "Very active on most days": self = .veryActive
        default:                         self = .lightlyActive
        }
    }
}


//enum PrimaryFocus {
//    case cycleRegularity
//    case weightManagement
//    case acneOrHair
//    case energy
//    case unsure
//}

enum BMICategory {
    case underweight // <18.5
    case normal // 18.5 -24.9
    case overweight //25-29.9
    case obese // >=30
}

enum PCOSPhenotype: String {
    case typeA = "Type A" // Hyperandrogenism + Anovulation + PCO  → highest IR risk
    case typeB   = "Type B"    // Hyperandrogenism + Anovulation         → adrenal-dominant
    case typeC   = "Type C"    // Hyperandrogenism + PCO                 → mildest metabolic impact
    case typeD   = "Type D"    // Anovulation + PCO                      → non-hyperandrogenic
    case unknown = "I Don't Know"
    
}


//BMI + AGE CALCULATIONS

extension UserProfile {

    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }

    var bmi: Double {
        let h = heightInCm / 100
        return weightInKg / (h * h)
    }

    var bmiCategory: BMICategory {

        switch bmi {

        case ..<18.5:
            return .underweight

        case 18.5..<25:
            return .normal

        case 25..<30:
            return .overweight

        default:
            return .obese
        }
    }
    
// ── Mifflin-St Jeor BMR — female formula (PCOS is a female condition) ────
    // BMR = (10 × kg) + (6.25 × cm) − (5 × age) − 161
    // Most validated equation for PCOS populations vs Harris-Benedict
    fileprivate var bmr: Double {
        (10.0 * weightInKg) + (6.25 * heightInCm) - (5.0 * Double(age)) - 161.0
    }
 
    // ── TDEE = BMR × PAL multiplier ─────────────────────────────────────────
    // Physical Activity Level (PAL) values from ESHRE PCOS Guidelines 2023
    fileprivate var tdee: Double {
        let pal: Double
        switch activityLevel {
        case .sedentary:     pal = 1.200
        case .lightlyActive: pal = 1.375
        case .active:        pal = 1.550
        case .veryActive:    pal = 1.725
        }
        return bmr * pal
    }
 
    // ── High IR-risk flag ────────────────────────────────────────────────────
    // Type A & B carry the worst insulin resistance profiles;
    // overweight/obese compounds that risk. Used to tighten carb targets.
    fileprivate var isHighIRRisk: Bool {
        (phenotype == .typeA || phenotype == .typeB) &&
        (bmiCategory == .overweight || bmiCategory == .obese)
    }

    // ── Goal-readiness multipliers ──────────────────────────────────────────
    //
    // Workout readiness: how much of the ideal workout volume a user should
    // start with on day 1, based on their self-reported activity level.
    //
    //   Very active  → 1.00  (already training; full ideal target from day 1)
    //   Active       → 0.90  (mostly consistent; small warm-in buffer)
    //   Lightly active→ 0.70  (occasional movement; begin at ~70% to build habit)
    //   Sedentary    → 0.55  (desk-bound; starting too high causes drop-off)
    //
    fileprivate var workoutReadiness: Double {
        switch activityLevel {
        case .veryActive:    return 1.00
        case .active:        return 0.90
        case .lightlyActive: return 0.70
        case .sedentary:     return 0.55
        }
    }

    // Diet readiness: fraction of the ideal macro target shown on day 1.
    //
    //   Balanced / unsure → 1.00  (no transition needed)
    //   High sugar        → 0.85  (reduce carbs/protein gradually; avoid rebound)
    //   Irregular meals   → 0.80  (erratic intake means hard cutoffs are unsustainable)
    //
    fileprivate var dietReadiness: Double {
        switch dietPattern {
        case .balanced, .unsure: return 1.00
        case .highSugar:         return 0.85
        case .irregular:         return 0.80
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - GOAL MODELS  (unchanged)
// ─────────────────────────────────────────────────────────────────────────────
 
struct DietGoals {
    /// Full ideal macro targets (phenotype + BMI calibrated)
    let proteinGrams: Int
    let carbsGrams: Int
    let fatsGrams: Int

    /// Day-1 starting targets (ramped down for irregular/high-sugar eaters so the
    /// transition is sustainable; equals ideal for balanced eaters).
    let startingProteinGrams: Int
    let startingCarbsGrams: Int
    let startingFatsGrams: Int
}

struct WorkoutGoals {
    /// Full ideal targets (phenotype + BMI calibrated)
    let workoutMinutesPerDay: Int
    let caloriesBurnedPerDay: Int
    let stepsPerDay: Int

    /// Day-1 starting targets (reduced for sedentary/lightly-active users so the
    /// habit is achievable from the outset; equals ideal for active/very-active users).
    let startingMinutesPerDay: Int
    let startingStepsPerDay: Int
}

struct SleepGoals {
    let sleepHours: Double
    let bedtimeRecommendation: String
}

struct UserGoals {
    let diet: DietGoals
    let workout: WorkoutGoals
    let sleep: SleepGoals
    /// Plain-language explanation of why goals may be set lower than the ideal,
    /// and how they will increase over time. Empty string when no ramp-up applies.
    let rampUpNote: String
}
 
// ─────────────────────────────────────────────────────────────────────────────
// MARK: - GOAL ENGINE
// ─────────────────────────────────────────────────────────────────────────────
 
struct GoalEngine {
    static func generateGoals(for user: UserProfile) -> UserGoals {
        UserGoals(
            diet:      dietGoals(for: user),
            workout:   workoutGoals(for: user),
            sleep:     sleepGoals(for: user),
            rampUpNote: rampUpNote(for: user)
        )
    }

    // ── Plain-language ramp-up explanation shown to the user ─────────────────
    private static func rampUpNote(for user: UserProfile) -> String {
        let activityRamped = user.activityLevel == .sedentary || user.activityLevel == .lightlyActive
        let dietRamped     = user.dietPattern == .irregular || user.dietPattern == .highSugar

        if activityRamped && dietRamped {
            return "Your goals are set to a gentler starting level because both your current activity and eating patterns suggest a gradual approach will be more sustainable. Expect your daily targets to increase every 2–3 weeks as your habits build."
        } else if activityRamped {
            return "Your workout targets start a little lower than the ideal to help you build a lasting habit. They'll progress upward as your fitness grows."
        } else if dietRamped {
            return "Your nutrition targets are slightly eased for the first few weeks to give your body time to adjust. They'll move toward the full PCOS-optimised goal as your eating patterns stabilise."
        } else {
            return ""
        }
    }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// MARK: - DIET GOALS
//
// Logic order:
//   1. Compute daily calorie target from TDEE + BMI-based deficit/surplus
//   2. Pick macro % split from phenotype × BMI grid  (research-backed)
//   3. Nudge percentages for dietPattern
//   4. Convert % → grams using 4/4/9 kcal-per-gram rule
// ─────────────────────────────────────────────────────────────────────────────
 
private func dietGoals(for user: UserProfile) -> DietGoals {
 
    // ── Step 1: Calorie target ───────────────────────────────────────────────
    //
    // Underweight → maintenance + 150 kcal surplus
    //   Lean PCOS must NOT be in a deficit; energy restriction worsens cortisol
    //   and can trigger hypothalamic amenorrhea on top of PCOS.
    //
    // Normal      → maintenance (TDEE)
    //   No deficit needed; metabolic improvements come from diet quality, not restriction.
    //
    // Overweight  → mild deficit −300 kcal
    //   Research: even 5% body-weight loss in overweight PCOS restores ovulation
    //   and reduces androgens. A −300 kcal deficit reaches ~0.3 kg/week — sustainable.
    //
    // Obese       → moderate deficit −500 kcal  (floor: 1 200 kcal)
    //   −500 kcal targets ~0.5 kg/week loss. Below 1 200 kcal, lean mass loss
    //   and nutrient deficiencies undermine the hormonal goals.
 
    let rawCalories: Double
    switch user.bmiCategory {
    case .underweight: rawCalories = user.tdee + 150
    case .normal:      rawCalories = user.tdee
    case .overweight:  rawCalories = user.tdee - 300
    case .obese:       rawCalories = user.tdee - 500
    }
    let dailyCalories = max(1_200, rawCalories)
 
    // ── Step 2: Macro % split (phenotype × BMI grid) ─────────────────────────
    //
    // Science summary:
    //   • Type A/B dominate insulin resistance (IR) and hyperandrogenism.
    //     Low-GI, lower-carb diets reduce fasting insulin and free androgen index.
    //     Higher protein preserves lean mass and increases satiety.
    //   • Type C/D have a milder IR burden; moderate carb intake is well tolerated.
    //   • Lean/normal users must NOT be over-restricted on carbs — energy is needed
    //     for ovulatory function and HPA axis stability.
    //   • Fat is kept ≥ 30 % to support steroidogenesis (hormones are fat-derived).
    //     Emphasis is on unsaturated fats; sat fat capped via food-quality guidance.
    //   Source: Moran et al. 2013; ESHRE PCOS Guidelines 2023
 
    let carbPct: Double
    let proteinPct: Double
    let fatPct: Double
 
    switch (user.phenotype, user.bmiCategory) {
 
    // High IR + high BMI → most aggressive carb reduction
    case (.typeA, .obese), (.typeA, .overweight),
         (.typeB, .obese), (.typeB, .overweight):
        carbPct = 0.25; proteinPct = 0.30; fatPct = 0.45
 
    // High IR + healthy weight → moderate carb reduction
    case (.typeA, .normal), (.typeA, .underweight),
         (.typeB, .normal), (.typeB, .underweight):
        carbPct = 0.35; proteinPct = 0.28; fatPct = 0.37
 
    // Moderate IR + high BMI
    case (.typeC, .obese), (.typeC, .overweight):
        carbPct = 0.32; proteinPct = 0.27; fatPct = 0.41
 
    // Moderate IR + healthy weight
    case (.typeC, .normal), (.typeC, .underweight):
        carbPct = 0.42; proteinPct = 0.23; fatPct = 0.35
 
    // Low IR risk + high BMI
    case (.typeD, .obese), (.typeD, .overweight):
        carbPct = 0.35; proteinPct = 0.25; fatPct = 0.40
 
    // Low IR risk + healthy weight / unknown
    default:
        carbPct = 0.42; proteinPct = 0.23; fatPct = 0.35
    }
 
    // ── Step 3: Diet-pattern nudge ────────────────────────────────────────────
    //
    // Nudges shift the percentage split — not gram targets — so the adjustment
    // scales correctly for any body size.
    //
    // highSugar  → user already eats too many refined carbs; pull carbs back 5 %
    //              and replace with protein to improve satiety and blunt insulin spikes.
    // irregular  → erratic eating destabilises insulin; mild carb reduction
    //              encourages structured, lower-GI meals.
    // balanced   → no change needed; macro split from phenotype grid is appropriate.
    // unsure     → no change; conservative default protects against over-restriction.
 
    var finalCarbPct    = carbPct
    var finalProteinPct = proteinPct
 
    switch user.dietPattern {
    case .highSugar:
        finalCarbPct    -= 0.05
        finalProteinPct += 0.03
    case .irregular:
        finalCarbPct    -= 0.02
        finalProteinPct += 0.02
    case .balanced, .unsure:
        break
    }
 
    // Clamp to physiologically safe ranges before converting
    finalCarbPct    = min(0.55, max(0.20, finalCarbPct))
    finalProteinPct = min(0.40, max(0.20, finalProteinPct))
    let finalFatPct = max(0.25, 1.0 - finalCarbPct - finalProteinPct)
 
    // ── Step 4: Convert % → grams ─────────────────────────────────────────────
    // Protein = 4 kcal/g  |  Carbs = 4 kcal/g  |  Fat = 9 kcal/g
    let protein = Int(dailyCalories * finalProteinPct / 4.0)
    let carbs   = Int(dailyCalories * finalCarbPct    / 4.0)
    let fats    = Int(dailyCalories * finalFatPct     / 9.0)

    // ── Step 5: Apply diet-readiness ramp-up ──────────────────────────────────
    // Irregular and high-sugar eaters receive lower day-1 macro targets so the
    // dietary shift is gradual and sustainable (avoids restriction-rebound cycle).
    let r = user.dietReadiness
    let startProtein = Int(Double(protein) * r)
    let startCarbs   = Int(Double(carbs)   * r)
    let startFats    = Int(Double(fats)    * r)

    return DietGoals(
        proteinGrams:         protein,
        carbsGrams:           carbs,
        fatsGrams:            fats,
        startingProteinGrams: startProtein,
        startingCarbsGrams:   startCarbs,
        startingFatsGrams:    startFats
    )
}
 
// ─────────────────────────────────────────────────────────────────────────────
// MARK: - WORKOUT GOALS
//
// Logic order:
//   1. Base duration/steps from activity level  (PCOS guideline: 150–300 min/week)
//   2. BMI adjustments
//   3. Phenotype-specific intensity cap/boost
//   4. Calorie burn estimate from minutes × MET proxy
// ─────────────────────────────────────────────────────────────────────────────
 
private func workoutGoals(for user: UserProfile) -> WorkoutGoals {
 
    // ── Step 1: Base values from activity level ──────────────────────────────
    //
    // PCOS guidelines (ESHRE 2023): 150–300 min/week moderate-intensity aerobic
    // OR 75–150 min/week vigorous; plus muscle-strengthening 2×/week.
    // Daily targets are derived from weekly totals ÷ session frequency.
 
    var minutes: Int
    var steps: Int
 
    switch user.activityLevel {
    case .sedentary:
        // Entry point: short sessions build the habit without overwhelming a
        // completely inactive user. Step target matches ~20 min casual walking.
        minutes = 20; steps = 4_000
 
    case .lightlyActive:
        // Meets the lower end of the 150 min/week PCOS guideline (30 min × 5).
        minutes = 30; steps = 6_000
 
    case .active:
        // Mid-range of guideline; 40 min sessions 5×/week = 200 min/week.
        minutes = 40; steps = 8_000
 
    case .veryActive:
        // Approaches the 300 min/week upper guideline for maximal benefit.
        minutes = 50; steps = 10_000
    }
 
    // ── Step 2: BMI adjustments ──────────────────────────────────────────────
    //
    // Overweight: increase both volume and steps — extra energy expenditure
    //   accelerates the 5-10% weight-loss threshold that restores ovulation.
    //
    // Obese: raise step floor to improve NEAT (non-exercise activity thermogenesis)
    //   but cap session length at 45 min to reduce injury risk and drop-off.
    //   Research shows obese users sustain shorter sessions better long-term.
    //
    // Underweight: protect from over-training. Excess exercise in lean PCOS
    //   elevates cortisol, worsens HPA dysregulation, and suppresses ovulation.
 
    switch user.bmiCategory {
    case .overweight:
        minutes += 10
        steps   += 2_000
    case .obese:
        steps   = max(steps, 6_000)
        minutes = min(minutes + 10, 45)
    case .underweight:
        minutes = min(minutes, 30)
        steps   = min(steps, 6_000)
    case .normal:
        break
    }
 
    // ── Step 3: Phenotype intensity adjustments ──────────────────────────────
    //
    // Type A (highest IR): HIIT and resistance training are evidence-best for
    //   reducing insulin resistance and free androgen index. Boost volume slightly.
    //
    // Type B (adrenal-dominant): cortisol is already elevated. Excessive exercise
    //   spikes cortisol further → worsens androgen production. Hard-cap at 40 min.
    //   Rest days are therapeutically important, not a failure.
    //
    // Type C: moderate intensity sufficient; no special cap or boost needed.
    //
    // Type D: steady-state aerobic and yoga both shown to improve anovulation
    //   without the cortisol burden. Step target is adequate; no intensity boost.
    //
    // Source: Patten et al. 2020 — HIIT vs moderate exercise in PCOS;
    //         Gaskins & Chavarro 2018 — exercise and ovulation
 
    switch user.phenotype {
    case .typeA:
        minutes  = min(minutes + 5, 60)     // HIIT benefit; cap at 60 min
        steps   += 1_000
    case .typeB:
        minutes  = min(minutes, 40)          // hard cortisol-protection cap
        steps    = min(steps, 8_000)
    case .typeC, .typeD, .unknown:
        break
    }
 
    // ── Step 4: Calories burned estimate ────────────────────────────────────
    //
    // Proxy: MET × weight × hours
    // MET values: sedentary/light ≈ 3.5 (brisk walk), active ≈ 5.0 (moderate cardio),
    //             veryActive ≈ 7.0 (vigorous cardio/HIIT)
    // Formula: kcal = MET × weightKg × (minutes / 60)
 
    let met: Double
    switch user.activityLevel {
    case .sedentary, .lightlyActive: met = 3.5
    case .active:                    met = 5.0
    case .veryActive:                met = 7.0
    }
    let caloriesBurned = Int(met * user.weightInKg * (Double(minutes) / 60.0))
 
    // ── Step 5: Apply workout-readiness ramp-up ──────────────────────────────
    // Sedentary and lightly-active users start at a reduced fraction of their
    // ideal target so the habit is achievable from day 1 (high initial goals
    // correlate with early abandonment in previously inactive PCOS populations).
    let w = user.workoutReadiness
    let startMinutes = max(10, Int(Double(minutes) * w))  // floor: 10 min always
    let startSteps   = max(2_000, Int(Double(steps) * w)) // floor: 2 000 steps always

    return WorkoutGoals(
        workoutMinutesPerDay: minutes,
        caloriesBurnedPerDay: caloriesBurned,
        stepsPerDay:          steps,
        startingMinutesPerDay: startMinutes,
        startingStepsPerDay:   startSteps
    )
}
 
// ─────────────────────────────────────────────────────────────────────────────
// MARK: - SLEEP GOALS
//
// Logic order:
//   1. Phenotype-driven baseline hours + recommendation text
//   2. Age guard for adolescents
//   3. BMI adjustment (obesity raises sleep disorder risk)
// ─────────────────────────────────────────────────────────────────────────────
 
private func sleepGoals(for user: UserProfile) -> SleepGoals {
 
    // ── Step 1: Phenotype baseline ────────────────────────────────────────────
    //
    // Type A: highest cortisol + IR burden. 8.5 h supports cortisol clearance,
    //   insulin sensitivity restoration overnight, and LH pulse normalisation.
    //
    // Type B: adrenal-dominant. Consistent sleep timing stabilises the HPA axis
    //   and prevents the cortisol spike that drives adrenal androgen excess.
    //
    // Type C: mildest metabolic impact; standard 7.5 h is adequate.
    //
    // Type D: no hyperandrogenism, but chronic stress worsens anovulation.
    //   Sleep hygiene is a low-cost intervention to reduce stress load.
    //
    // Unknown: conservative 8 h; erratic sleep disrupts reproductive hormones
    //   in all PCOS presentations and is a safe recommendation without phenotype data.
    //
    // Source: Fernandez et al. 2018 — sleep quality and PCOS hormonal profile
 
    var sleepHours: Double
    var recommendation: String
 
    switch user.phenotype {
    case .typeA:
        sleepHours    = 8.5
        recommendation = "Prioritise 8–9 hours. Deep sleep is when cortisol clears and insulin sensitivity resets — both critical for Type A. Keep a strict wake time even on weekends."
 
    case .typeB:
        sleepHours    = 8.0
        recommendation = "Consistent bed and wake times stabilise your adrenal rhythm. Irregular sleep directly raises adrenal androgens in Type B — treat sleep timing as part of your treatment."
 
    case .typeC:
        sleepHours    = 7.5
        recommendation = "Aim for 7–8 hours with a consistent schedule. Avoid late-night eating, as it disrupts the insulin-cortisol rhythm overnight."
 
    case .typeD:
        sleepHours    = 7.5
        recommendation = "Focus on stress reduction and a steady bedtime. Chronic stress worsens anovulation even without elevated androgens — quality sleep is a key regulator."
 
    case .unknown:
        sleepHours    = 8.0
        recommendation = "Aim for 7.5–8.5 hours with consistent timing. Irregular sleep disrupts reproductive hormones regardless of PCOS type."
    }
 
    // ── Step 2: Age guard ────────────────────────────────────────────────────
    //
    // Adolescents (< 20) are in active hormonal development.
    // NSF guidelines: teenagers need 8–10 h. Insufficient sleep in adolescent PCOS
    // amplifies both IR and androgen excess during a critical developmental window.
 
    if user.age < 20 {
        sleepHours    = max(sleepHours, 9.0)
        recommendation += " As a teenager, aim for 9–10 hours — your hormonal system is still maturing and needs the extra recovery."
    }
 
    // ── Step 3: Obesity sleep-risk note ─────────────────────────────────────
    //
    // Obese PCOS users have significantly higher rates of sleep apnoea,
    // which further disrupts insulin sensitivity and cortisol rhythm.
    // Flag this without adding a new field — appended to recommendation text.
 
    if user.bmiCategory == .obese {
        recommendation += " If you snore or wake unrefreshed, discuss sleep apnoea screening with your doctor — it's common in PCOS and worsens insulin resistance."
    }
 
    return SleepGoals(
        sleepHours:            sleepHours,
        bedtimeRecommendation: recommendation
    )
}
