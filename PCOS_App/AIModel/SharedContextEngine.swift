//
//  SharedContextEngine.swift
//  PCOS_App
//
import Foundation
import CoreData

@MainActor
final class SharedContextEngine {

    static let shared = SharedContextEngine()
    private init() {}

    private var context: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }

    func buildContext() async -> String {
        let user      = fetchUser()
        let goals     = computeGoals(for: user)
        let todayCtx  = fetchTodayContext()
        let patterns  = fetchSevenDayPatterns()
        let cycleInfo = fetchCycleInfo(user: user)
        return format(user: user, goals: goals, todayCtx: todayCtx,
                      patterns: patterns, cycleInfo: cycleInfo)
    }

    // ── CDUser → UserProfile ──────────────────────────────────────────────
    private func fetchUser() -> UserProfile? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDUser")
        request.fetchLimit = 1
        guard let cd = try? context.fetch(request).first else { return nil }
        return UserProfile(
            name:          cd.value(forKey: "name") as? String ?? "",
            dateOfBirth:   cd.value(forKey: "dateOfBirth") as? Date ?? Date(),
            heightInCm:    cd.value(forKey: "heightCm") as? Double ?? 160,
            weightInKg:    cd.value(forKey: "weightKg") as? Double ?? 60,
            dietPattern:   DietPattern(rawString: cd.value(forKey: "dietPattern") as? String ?? ""),
            activityLevel: ActivityLevel(rawString: cd.value(forKey: "activityLevel") as? String ?? ""),
            phenotype:     PCOSPhenotype(rawValue: cd.value(forKey: "pcosPhenotype") as? String ?? "") ?? .unknown
        )
    }

    private func computeGoals(for user: UserProfile?) -> UserGoals? {
        guard let user else { return nil }
        return GoalEngine.generateGoals(for: user)
    }

    // ── TodayContext ──────────────────────────────────────────────────────
    private struct TodayContext {
        var sleepTime: Date?
        var wakeTime: Date?
        var sleepQuality: Double
        var sleepDurationHours: Double
        var steps: Int
        var caloriesBurned: Int
        var waterL: Double
        var cyclePhase: String
        var cycleDay: Int
        var foodLogs: [FoodLogSnapshot]
        var symptoms: [String]
        var completedWorkouts: [WorkoutSnapshot]
    }

    private struct FoodLogSnapshot {
        let name: String
        let protein: Double
        let carbs: Double
        let fats: Double
        let calories: Double
        let timeStamp: Date
        let tags: [String]
    }

    private struct WorkoutSnapshot {
        let routineName: String
        let durationSeconds: Int
        let caloriesBurned: Double
    }

    private func fetchTodayContext() -> TodayContext? {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: Date())
        guard let todayEnd = cal.date(byAdding: .day, value: 1, to: todayStart) else { return nil }

        let request = NSFetchRequest<NSManagedObject>(entityName: "CDDailyContext")
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@",
                                        todayStart as NSDate, todayEnd as NSDate)
        request.fetchLimit = 1
        guard let cd = try? context.fetch(request).first else { return nil }

        let sleepTime    = cd.value(forKey: "sleepTime") as? Date
        let wakeTime     = cd.value(forKey: "wakeTime") as? Date
        let sleepQuality = cd.value(forKey: "sleepQuality") as? Double ?? 0
        var sleepHours   = 0.0
        if let s = sleepTime, let w = wakeTime {
            var wake = w
            if wake < s { wake = cal.date(byAdding: .day, value: 1, to: wake) ?? wake }
            sleepHours = wake.timeIntervalSince(s) / 3600.0
        }

        let foodSet  = cd.value(forKey: "foodLogs") as? Set<NSManagedObject> ?? []
        let foodLogs: [FoodLogSnapshot] = foodSet.map { fl in
            let protein   = fl.value(forKey: "proteinContent") as? Double ?? 0
            let carbs     = fl.value(forKey: "carbsContent") as? Double ?? 0
            let fats      = fl.value(forKey: "fatsContent") as? Double ?? 0
            let customCal = fl.value(forKey: "customCalories") as? Double
            return FoodLogSnapshot(
                name:      fl.value(forKey: "name") as? String ?? "Unknown",
                protein:   protein, carbs: carbs, fats: fats,
                calories:  customCal ?? (protein * 4 + carbs * 4 + fats * 9),
                timeStamp: fl.value(forKey: "timeStamp") as? Date ?? Date(),
                tags:      decodeTags(from: fl.value(forKey: "tagsData") as? Data)
            )
        }.sorted { $0.timeStamp < $1.timeStamp }

        let symptomSet = cd.value(forKey: "symptomLogs") as? Set<NSManagedObject> ?? []
        let symptoms   = symptomSet.map {
            "\($0.value(forKey: "symptomName") as? String ?? "") (\($0.value(forKey: "symptomCategory") as? String ?? ""))"
        }

        let workoutSet = cd.value(forKey: "completedWorkouts") as? Set<NSManagedObject> ?? []
        let workouts   = workoutSet.map {
            WorkoutSnapshot(
                routineName:     $0.value(forKey: "routineName") as? String ?? "",
                durationSeconds: Int($0.value(forKey: "durationSeconds") as? Int32 ?? 0),
                caloriesBurned:  $0.value(forKey: "caloriesBurned") as? Double ?? 0
            )
        }

        return TodayContext(
            sleepTime: sleepTime, wakeTime: wakeTime,
            sleepQuality: sleepQuality, sleepDurationHours: sleepHours,
            steps: Int(cd.value(forKey: "steps") as? Int32 ?? 0),
            caloriesBurned: Int(cd.value(forKey: "caloriesBurned") as? Int32 ?? 0),
            waterL: cd.value(forKey: "waterL") as? Double ?? 0,
            cyclePhase: cd.value(forKey: "cyclePhase") as? String ?? "Unknown",
            cycleDay: Int(cd.value(forKey: "cycleDay") as? Int16 ?? 0),
            foodLogs: foodLogs, symptoms: symptoms, completedWorkouts: workouts
        )
    }

    // ── 7-Day Patterns ────────────────────────────────────────────────────
    private struct SevenDayPatterns {
        var avgSleepHours: Double
        var highGIMealCount: Int
        var avgProteinPerMeal: Double
        var totalWorkoutSessions: Int
        var strengthSessions: Int
        var recurringSymptoms: [String]
        var avgSteps: Int
        var avgWaterL: Double
    }

    private func fetchSevenDayPatterns() -> SevenDayPatterns {
        let cal        = Calendar.current
        let todayStart = cal.startOfDay(for: Date())
        let empty      = SevenDayPatterns(avgSleepHours: 0, highGIMealCount: 0,
                                          avgProteinPerMeal: 0, totalWorkoutSessions: 0,
                                          strengthSessions: 0, recurringSymptoms: [],
                                          avgSteps: 0, avgWaterL: 0)
        guard let sevenDaysAgo = cal.date(byAdding: .day, value: -7, to: todayStart) else { return empty }

        let request = NSFetchRequest<NSManagedObject>(entityName: "CDDailyContext")
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@",
                                        sevenDaysAgo as NSDate, todayStart as NSDate)
        guard let days = try? context.fetch(request), !days.isEmpty else { return empty }

        var totalSleepH = 0.0; var sleepDayCount = 0
        for day in days {
            if let s = day.value(forKey: "sleepTime") as? Date,
               let w = day.value(forKey: "wakeTime") as? Date {
                var wake = w
                if wake < s { wake = cal.date(byAdding: .day, value: 1, to: wake) ?? wake }
                totalSleepH += wake.timeIntervalSince(s) / 3600.0
                sleepDayCount += 1
            }
        }

        var allFoodLogs: [NSManagedObject] = []
        days.forEach { allFoodLogs.append(contentsOf: ($0.value(forKey: "foodLogs") as? Set<NSManagedObject> ?? [])) }

        let highGITags: Set<String> = ["highGlycemic", "insulinSpiking", "highInsulinLoad"]
        let highGICount  = allFoodLogs.filter {
            !Set(decodeTags(from: $0.value(forKey: "tagsData") as? Data)).isDisjoint(with: highGITags)
        }.count
        let totalProtein = allFoodLogs.reduce(0.0) { $0 + (($1.value(forKey: "proteinContent") as? Double) ?? 0) }

        var totalWorkouts = 0; var strengthCount = 0
        for day in days {
            let wkSet = day.value(forKey: "completedWorkouts") as? Set<NSManagedObject> ?? []
            totalWorkouts += wkSet.count
            for wk in wkSet {
                let n = (wk.value(forKey: "routineName") as? String ?? "").lowercased()
                if !n.contains("cardio") && !n.contains("yoga") && !n.contains("walk") && !n.contains("run") {
                    strengthCount += 1
                }
            }
        }

        var symptomDayMap: [String: Int] = [:]
        for day in days {
            let names = Set((day.value(forKey: "symptomLogs") as? Set<NSManagedObject> ?? [])
                .compactMap { $0.value(forKey: "symptomName") as? String })
            names.forEach { symptomDayMap[$0, default: 0] += 1 }
        }

        return SevenDayPatterns(
            avgSleepHours:        (sleepDayCount > 0 ? totalSleepH / Double(sleepDayCount) : 0).rounded(toPlaces: 1),
            highGIMealCount:      highGICount,
            avgProteinPerMeal:    (allFoodLogs.isEmpty ? 0 : totalProtein / Double(allFoodLogs.count)).rounded(toPlaces: 1),
            totalWorkoutSessions: totalWorkouts,
            strengthSessions:     strengthCount,
            recurringSymptoms:    symptomDayMap.filter { $0.value >= 3 }.map { "\($0.key) (\($0.value)/7 days)" }.sorted(),
            avgSteps:             days.reduce(0) { $0 + Int(($1.value(forKey: "steps") as? Int32) ?? 0) } / days.count,
            avgWaterL:            (days.reduce(0.0) { $0 + (($1.value(forKey: "waterL") as? Double) ?? 0) } / Double(days.count)).rounded(toPlaces: 1)
        )
    }

    // ── Cycle Info ────────────────────────────────────────────────────────
    private struct CycleInfo {
        let currentPhase: String
        let cycleDay: Int
        let nextPeriodDaysAway: Int?
        let avgCycleLength: Int?
        let isLate: Bool
    }

    private func fetchCycleInfo(user: UserProfile?) -> CycleInfo {
        let cycles = (try? context.fetch(NSFetchRequest<NSManagedObject>(entityName: "CDCycleData"))) ?? []

        let cycleDataArray: [CycleData] = cycles.compactMap { cd in
            guard let id = cd.value(forKey: "id") as? UUID,
                  let startDate = cd.value(forKey: "startDate") as? Date else { return nil }
            let endDate = cd.value(forKey: "endDate") as? Date
            let storedCycleLength = Int(cd.value(forKey: "cycleLength") as? Int16 ?? 0)

            // For ongoing cycle, compute actual length from startDate to today
            let actualLength: Int
            if endDate == nil {
                actualLength = Calendar.current.dateComponents(
                    [.day], from: Calendar.current.startOfDay(for: startDate),
                    to: Calendar.current.startOfDay(for: Date())
                ).day ?? 0
            } else {
                actualLength = storedCycleLength
            }

            // Build enough stub days so cycleLength computed property returns correct value
            let stubDays = (0..<max(1, actualLength)).map { i in
                CycleDay(dayIndex: i, phase: .follicular, symptoms: [])
            }

            return CycleData(
                id: id,
                month: DateFormatter.monthYear.string(from: startDate),
                startDate: startDate,
                endDate: endDate,
                isOvulationConfirmed: cd.value(forKey: "isOvulationConfirmed") as? Bool ?? false,
                days: stubDays  // ← gives cycleLength = actualLength
            )
        }

        let prediction = PeriodPredictionEngine().predict(from: cycleDataArray)

        let todayCtxReq = NSFetchRequest<NSManagedObject>(entityName: "CDDailyContext")
        let todayStart  = Calendar.current.startOfDay(for: Date())
        todayCtxReq.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            todayStart as NSDate,
            Calendar.current.date(byAdding: .day, value: 1, to: todayStart)! as NSDate
        )
        todayCtxReq.fetchLimit = 1
        let todayCD = try? context.fetch(todayCtxReq).first

        return CycleInfo(
            currentPhase:       todayCD?.value(forKey: "cyclePhase") as? String ?? prediction.summaryText,
            cycleDay:           Int(todayCD?.value(forKey: "cycleDay") as? Int16 ?? 0),
            nextPeriodDaysAway: prediction.daysUntil,
            avgCycleLength:     prediction.averageCycleLength,
            isLate:             prediction.isLate
        )
    }

    // ── Format ────────────────────────────────────────────────────────────
    private func format(
        user: UserProfile?,
        goals: UserGoals?,
        todayCtx: TodayContext?,
        patterns: SevenDayPatterns,
        cycleInfo: CycleInfo
    ) -> String {

        // Profile — include BMI category explicitly so model never suggests weight loss incorrectly
        let profileBlock: String
        if let u = user {
            profileBlock = "User: \(u.name), Age \(u.age), BMI \(String(format: "%.1f", u.bmi)) (\(u.bmiCategory.displayName)), PCOS \(u.phenotype.rawValue), \(u.activityLevel.displayName), \(u.dietPattern.displayName) diet"
        } else {
            profileBlock = "User: No profile"
        }

        // Goals
        let goalsBlock = goals.map {
            "Targets: \($0.diet.dailyCalories)kcal | P\($0.diet.proteinGrams)g C\($0.diet.carbsGrams)g F\($0.diet.fatsGrams)g | \($0.workout.workoutMinutesPerDay)min workout | \(Int($0.sleep.sleepHours))h sleep"
        } ?? "Targets: unavailable"

        // ── Cycle — calendar date so model never does arithmetic ──────────
        let df = DateFormatter()
        df.dateFormat = "MMMM d, yyyy"
        let cal = Calendar.current

        let nextStr: String
        if cycleInfo.isLate {
            nextStr = "cycle is irregular — no reliable prediction"
        } else if let daysAway = cycleInfo.nextPeriodDaysAway {
            let predictedDate = cal.date(byAdding: .day, value: daysAway,
                                         to: cal.startOfDay(for: Date())) ?? Date()
            let dateStr = df.string(from: predictedDate)
            if daysAway == 0 {
                nextStr = "predicted to start TODAY (\(dateStr))"
            } else if daysAway < 0 {
                nextStr = "is \(abs(daysAway)) days late (was expected \(dateStr))"
            } else {
                nextStr = "predicted on \(dateStr) — that is \(daysAway) days from today"
            }
        } else {
            nextStr = "cannot be predicted yet — not enough cycle history logged"
        }

        let cycleBlock = """
        Current cycle day: \(cycleInfo.cycleDay) (she is on day \(cycleInfo.cycleDay) of her current cycle — NOT the next period date).
        Current phase: \(cycleInfo.currentPhase).
        Next period: \(nextStr).\(cycleInfo.avgCycleLength != nil ? " Average cycle length: \(cycleInfo.avgCycleLength!) days." : "")
        """

        // Today
        let todayBlock: String
        if let t = todayCtx {
            let totalP   = Int(t.foodLogs.reduce(0.0) { $0 + $1.protein })
            let totalCal = Int(t.foodLogs.reduce(0.0) { $0 + $1.calories })
            let lastMeal = t.foodLogs.last.map { $0.name } ?? "none"
            let sleepStr = t.sleepDurationHours > 0
                ? String(format: "%.1fh", t.sleepDurationHours) : "not logged"
            let workoutStr  = t.completedWorkouts.isEmpty ? "none"
                : t.completedWorkouts.map { $0.routineName }.joined(separator: ", ")
            let symptomsStr = t.symptoms.isEmpty ? "none" : t.symptoms.joined(separator: ", ")

            todayBlock = """
            Today: protein \(totalP)g/\(goals?.diet.proteinGrams ?? 0)g, \(totalCal)kcal logged. Last meal: \(lastMeal).
            Sleep: \(sleepStr). Steps: \(t.steps). Workout: \(workoutStr).
            Symptoms today: \(symptomsStr)
            """
        } else {
            todayBlock = "Today: no data logged"
        }

        // 7-day
        let patternsBlock = """
        7-day: avg sleep \(patterns.avgSleepHours)h (target \(goals?.sleep.sleepHours ?? 8.0)h), \(patterns.highGIMealCount) high-GI meals, \(patterns.totalWorkoutSessions) workouts (\(patterns.strengthSessions) strength).
        Recurring symptoms:   \(patterns.recurringSymptoms.isEmpty ? "none" : patterns.recurringSymptoms.joined(separator: ", "))
        """

        return [profileBlock, goalsBlock, cycleBlock, todayBlock, patternsBlock]
            .joined(separator: "\n")
    }

    // ── Helpers ───────────────────────────────────────────────────────────
    private func decodeTags(from data: Data?) -> [String] {
        guard let data else { return [] }
        if let tags = try? JSONDecoder().decode([ImpactTags].self, from: data) {
            return tags.map { $0.rawValue }
        }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }
}

// MARK: - Extensions
private extension BMICategory {
    var displayName: String {
        switch self {
        case .underweight: return "Underweight"
        case .normal:      return "Normal weight"
        case .overweight:  return "Overweight"
        case .obese:       return "Obese"
        }
    }
}

private extension ActivityLevel {
    var displayName: String {
        switch self {
        case .sedentary:     return "Sedentary"
        case .lightlyActive: return "Lightly Active"
        case .active:        return "Active"
        case .veryActive:    return "Very Active"
        }
    }
}

private extension DietPattern {
    var displayName: String {
        switch self {
        case .balanced:  return "Balanced"
        case .highSugar: return "High Sugar"
        case .irregular: return "Irregular"
        case .unsure:    return "Unsure"
        }
    }
}

private extension DateFormatter {
    static let monthYear: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()
}
