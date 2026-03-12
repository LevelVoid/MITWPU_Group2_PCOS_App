
//
//  UserModel.swift
//  PCOS_App
//

import Foundation

// MARK: - USER PROFILE

struct UserProfile {

    let name: String
    let dateOfBirth: Date
    let heightInCm: Double
    let weightInKg: Double

    let dietPattern: DietPattern
    let activityLevel: ActivityLevel
    let primaryFocus: PrimaryFocus?
    let phenotype: PCOSPhenotype

}

// MARK: - ENUMS

enum DietPattern {
    case balanced
    case highSugar
    case irregular
    case unsure
}

enum ActivityLevel {
    case sedentary
    case lightlyActive
    case active
    case veryActive
}

enum PrimaryFocus {
    case cycleRegularity
    case weightManagement
    case acneOrHair
    case energy
    case unsure
}

enum BMICategory {
    case underweight
    case normal
    case overweight
    case obese
}

enum PCOSPhenotype: String {
    case typeA = "Type A"
    case typeB = "Type B"
    case typeC = "Type C"
    case typeD = "Type D"
    case unknown = "I Don't Know"
}


// MARK: - BMI + AGE CALCULATIONS

extension UserProfile {

    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }

    var bmi: Double {
        let heightMeters = heightInCm / 100
        return weightInKg / (heightMeters * heightMeters)
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
}

// MARK: - GOAL MODELS

struct DietGoals {

    let proteinGrams: Int
    let carbsGrams: Int
    let fatsGrams: Int

}

struct WorkoutGoals {

    let workoutMinutesPerDay: Int
    let caloriesBurnedPerDay: Int
    let stepsPerDay: Int

}

struct SleepGoals {

    let sleepHours: Double
    let bedtimeRecommendation: String

}

struct UserGoals {

    let diet: DietGoals
    let workout: WorkoutGoals
    let sleep: SleepGoals

}

// MARK: - GOAL ENGINE

struct GoalEngine {

    static func generateGoals(for user: UserProfile) -> UserGoals {

        let diet = dietGoals(for: user)
        let workout = workoutGoals(for: user)
        let sleep = sleepGoals(for: user)

        return UserGoals(
            diet: diet,
            workout: workout,
            sleep: sleep
        )
    }
}

// MARK: - DIET RULES

private func dietGoals(for user: UserProfile) -> DietGoals {

    var protein = 90
    var carbs = 170
    var fats = 60

    // Diet pattern rules

    switch user.dietPattern {

    case .balanced:
        protein = 90
        carbs = 180
        fats = 60

    case .highSugar:
        protein = 100
        carbs = 150
        fats = 65

    case .irregular:
        protein = 95
        carbs = 160
        fats = 60

    case .unsure:
        protein = 85
        carbs = 170
        fats = 60
    }

    // Phenotype adjustments

    switch user.phenotype {

    case .typeA:
        carbs -= 20
        protein += 10

    case .typeB:
        protein += 10

    case .typeC:
        break

    case .typeD:
        fats += 5

    case .unknown:
        break
    }

    // BMI adjustment

    if user.bmiCategory == .overweight || user.bmiCategory == .obese {
        carbs -= 10
        protein += 5
    }

    return DietGoals(
        proteinGrams: protein,
        carbsGrams: carbs,
        fatsGrams: fats
    )
}

// MARK: - WORKOUT RULES

private func workoutGoals(for user: UserProfile) -> WorkoutGoals {

    var minutes = 30
    var calories = 250
    var steps = 6000

    switch user.activityLevel {

    case .sedentary:
        minutes = 15
        calories = 150
        steps = 4000

    case .lightlyActive:
        minutes = 25
        calories = 250
        steps = 6000

    case .active:
        minutes = 40
        calories = 350
        steps = 8000

    case .veryActive:
        minutes = 50
        calories = 450
        steps = 10000
    }

    // BMI boost for weight management

    if user.bmiCategory == .overweight || user.bmiCategory == .obese {
        steps += 2000
        minutes += 10
    }

    // Adrenal-like phenotype adjustment (stress sensitive)

    if user.phenotype == .typeB {
        minutes -= 5
    }

    return WorkoutGoals(
        workoutMinutesPerDay: minutes,
        caloriesBurnedPerDay: calories,
        stepsPerDay: steps
    )
}

// MARK: - SLEEP RULES

private func sleepGoals(for user: UserProfile) -> SleepGoals {

    var sleepHours: Double = 7.5
    var recommendation = "Maintain a consistent sleep schedule."

    switch user.phenotype {

    case .typeA:
        sleepHours = 8.5
        recommendation = "Prioritize 8–9 hours of sleep to support hormone recovery."

    case .typeB:
        sleepHours = 8.0
        recommendation = "Aim for regular sleep to support androgen balance."

    case .typeC:
        sleepHours = 7.5
        recommendation = "Maintain consistent sleep patterns."

    case .typeD:
        sleepHours = 7.5
        recommendation = "Focus on stress reduction and steady sleep timing."

    case .unknown:
        sleepHours = 7.5
        recommendation = "Aim for 7–8 hours of sleep for hormonal balance."
    }

    if user.primaryFocus == .energy {
        sleepHours += 0.5
    }

    return SleepGoals(
        sleepHours: sleepHours,
        bedtimeRecommendation: recommendation
    )
}
