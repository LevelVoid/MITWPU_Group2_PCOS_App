//
//  CycleLogicTests.swift
//  PCOS_App
//
//  Temporary verification file — call CycleLogicTests.runAll() from viewDidLoad to test.
//  DELETE this file before shipping.
//

import Foundation

struct CycleLogicTests {

    private static let cal = Calendar.current
    private static let store = CycleDataStore.shared
    private static let engine = PeriodPredictionEngine()

    // ──────────────────────────────────────────────
    // MARK: - Run All
    // ──────────────────────────────────────────────

    static func runAll() {
        print("\n" + String(repeating: "═", count: 60))
        print("  🧪  CYCLE LOGIC VERIFICATION")
        print(String(repeating: "═", count: 60))

        testPhaseForDay()
        testPhaseForDay_LongCycle()
        testPhaseForDay_AnovulatoryCycle()
        testCurrentPhaseInfo_NoCycles()
        testPredictionEngine_NoCycles()
        testPredictionEngine_OneCycle()
        testPredictionEngine_MultipleCycles()
        // testRebuildCycles()  // Disabled — modifies actual store data
        testCycleLengthOngoingNeverZero()

        print(String(repeating: "═", count: 60))
        print("  ✅  ALL TESTS COMPLETE — check output above")
        print(String(repeating: "═", count: 60) + "\n")
    }

    // ──────────────────────────────────────────────
    // MARK: - Phase Logic
    // ──────────────────────────────────────────────

    /// Normal ~28 day cycle: verify menstrual → follicular → ovulation window → luteal
    static func testPhaseForDay() {
        print("\n── Test: phaseForDay (normal 28-day cycle, period 5) ──")
        let cycleLength = 28
        let periodLength = 5

        for day in [1, 3, 5, 6, 10, 14, 15, 16, 20, 28] {
            let phase = store.phaseForDay(
                day: day, cycleLength: cycleLength,
                periodLength: periodLength
            )
            print("  Day \(String(format: "%2d", day)): \(phase.displayName)")
        }
        // Expected: Days 1-5 menstrual, 6-~12 follicular, ~13-15 ovulation window, 16+ luteal
    }

    /// Long PCOS cycle (~40 days): ovulation should shift later
    static func testPhaseForDay_LongCycle() {
        print("\n── Test: phaseForDay (long 40-day PCOS cycle, period 6) ──")
        let cycleLength = 40
        let periodLength = 6

        for day in [1, 6, 7, 15, 20, 25, 26, 27, 28, 35, 40] {
            let phase = store.phaseForDay(
                day: day, cycleLength: cycleLength,
                periodLength: periodLength
            )
            print("  Day \(String(format: "%2d", day)): \(phase.displayName)")
        }
        // Expected: ovulation window should be around day 25-27 (not day 26 like old logic)
    }

    /// Very long cycle >45 days without confirmed ovulation → should show .unknown
    static func testPhaseForDay_AnovulatoryCycle() {
        print("\n── Test: phaseForDay (50-day likely anovulatory, NOT confirmed) ──")
        let cycleLength = 50
        let periodLength = 5

        for day in [1, 5, 6, 10, 11, 20, 30, 40, 50] {
            let phase = store.phaseForDay(
                day: day, cycleLength: cycleLength,
                periodLength: periodLength,
                isOvulationConfirmed: false
            )
            print("  Day \(String(format: "%2d", day)): \(phase.displayName)")
        }
        // Expected: 1-5 menstrual, 6-10 follicular, 11+ UNKNOWN (anovulatory)

        print("\n── Test: phaseForDay (50-day, ovulation IS confirmed via BBT) ──")
        for day in [1, 5, 10, 20, 30, 40, 50] {
            let phase = store.phaseForDay(
                day: day, cycleLength: cycleLength,
                periodLength: periodLength,
                isOvulationConfirmed: true
            )
            print("  Day \(String(format: "%2d", day)): \(phase.displayName)")
        }
        // Expected: normal phase assignment (ovulation ~day 37, then luteal)
    }

    // ──────────────────────────────────────────────
    // MARK: - currentPhaseInfo
    // ──────────────────────────────────────────────

    /// Brand-new user with no cycles → should get .unknown, NOT .luteal
    static func testCurrentPhaseInfo_NoCycles() {
        print("\n── Test: currentPhaseInfo with 0 cycles ──")
        _ = store.cycles  // save current state

        // Temporarily clear cycles to test empty state
        // (We can't easily set cycles on a singleton, so we just check what the current state is)
        let info = store.currentPhaseInfo()
        print("  Current state: Cycle Day \(info.cycleDay), Phase: \(info.phase.displayName)")

        if store.cycles.isEmpty {
            let isCorrect = info.phase == .unknown
            print("  ✅ Empty cycles → phase is \(info.phase) (expected .unknown): \(isCorrect ? "PASS" : "❌ FAIL")")
        } else {
            print("  ℹ️  Store has \(store.cycles.count) cycles, so this isn't testing the empty case.")
            print("      Phase: \(info.phase.displayName) on cycle day \(info.cycleDay)")
        }
    }

    // ──────────────────────────────────────────────
    // MARK: - Prediction Engine
    // ──────────────────────────────────────────────

    static func testPredictionEngine_NoCycles() {
        print("\n── Test: PredictionEngine with 0 cycles ──")
        let prediction = engine.predict(from: [])
        print("  Confidence: \(prediction.confidence)")
        print("  Summary: \(prediction.summaryText)")
        let isCorrect = prediction.confidence == .none
        print("  \(isCorrect ? "✅ PASS" : "❌ FAIL"): confidence should be .none")
    }

    static func testPredictionEngine_OneCycle() {
        print("\n── Test: PredictionEngine with 1 completed cycle ──")
        let today = cal.startOfDay(for: Date())
        let start = cal.date(byAdding: .day, value: -35, to: today)!
        let end   = cal.date(byAdding: .day, value: -5, to: today)!

        let cycle = makeCycle(start: start, end: end, cycleLength: 30, periodLength: 5)
        let prediction = engine.predict(from: [cycle])

        print("  Confidence: \(prediction.confidence)")
        print("  Avg cycle length: \(prediction.averageCycleLength ?? 0)")
        print("  Days until: \(prediction.daysUntil ?? -999)")
        print("  Summary: \(prediction.summaryText)")
        print("  \(prediction.confidence == .low ? "✅ PASS" : "❌ FAIL"): 1 completed cycle → .low confidence")
    }

    static func testPredictionEngine_MultipleCycles() {
        print("\n── Test: PredictionEngine with 3 completed cycles (28, 32, 30 days) ──")
        let today = cal.startOfDay(for: Date())

        let c1Start = cal.date(byAdding: .day, value: -95, to: today)!
        let c1End   = cal.date(byAdding: .day, value: -68, to: today)!  // 28 days

        let c2Start = cal.date(byAdding: .day, value: -67, to: today)!
        let c2End   = cal.date(byAdding: .day, value: -36, to: today)!  // 32 days

        let c3Start = cal.date(byAdding: .day, value: -35, to: today)!
        let c3End   = cal.date(byAdding: .day, value: -6, to: today)!   // 30 days

        let ongoingStart = cal.date(byAdding: .day, value: -5, to: today)!

        let cycles = [
            makeCycle(start: c1Start, end: c1End, cycleLength: 28, periodLength: 5),
            makeCycle(start: c2Start, end: c2End, cycleLength: 32, periodLength: 4),
            makeCycle(start: c3Start, end: c3End, cycleLength: 30, periodLength: 5),
            makeCycle(start: ongoingStart, end: nil, cycleLength: 30, periodLength: 5)  // ongoing
        ]

        let prediction = engine.predict(from: cycles)
        print("  Confidence: \(prediction.confidence)")
        print("  Avg cycle length: \(prediction.averageCycleLength ?? 0) (median of [28,32,30] = 30)")
        print("  Predicted start: \(prediction.predictedStartDate.map { "\($0)" } ?? "nil")")
        print("  Days until: \(prediction.daysUntil ?? -999)")
        print("  Summary: \(prediction.summaryText)")
        print("  \(prediction.confidence == .high ? "✅ PASS" : "❌ FAIL"): 3 completed → .high confidence")
        print("  \(prediction.averageCycleLength == 30 ? "✅ PASS" : "❌ FAIL"): median should be 30")
    }

    // ──────────────────────────────────────────────
    // MARK: - rebuildCycles
    // ──────────────────────────────────────────────

    static func testRebuildCycles() {
        print("\n── Test: rebuildCycles from raw period dates ──")
        let today = cal.startOfDay(for: Date())

        // Simulate 3 periods: 5 days each, ~30 days apart
        var dates: [Date] = []
        for periodStart in [-90, -60, -5] {
            for dayOffset in 0..<5 {
                dates.append(cal.date(byAdding: .day, value: periodStart + dayOffset, to: today)!)
            }
        }

        store.rebuildCycles(from: dates)

        print("  Total cycles built: \(store.cycles.count)")
        for (i, cycle) in store.cycles.enumerated() {
            print("  Cycle \(i+1): start=\(shortDate(cycle.startDate)), " +
                  "length=\(cycle.cycleLength), period=\(cycle.periodLength), " +
                  "complete=\(cycle.isComplete), endDate=\(cycle.endDate.map { shortDate($0) } ?? "nil")")
        }

        let completedCount = store.cycles.filter { $0.isComplete }.count
        let ongoingCount = store.cycles.filter { !$0.isComplete }.count
        print("  \(completedCount == 2 ? "✅ PASS" : "❌ FAIL"): should have 2 completed cycles")
        print("  \(ongoingCount == 1 ? "✅ PASS" : "❌ FAIL"): should have 1 ongoing cycle")

        // Check that the ongoing cycle does NOT have cycleLength = 28
        if let ongoing = store.cycles.first(where: { !$0.isComplete }) {
            print("  \(ongoing.cycleLength != 28 ? "✅ PASS" : "❌ FAIL"): ongoing cycle length should NOT be hardcoded 28 (got \(ongoing.cycleLength))")
        }

        // Check that the last completed cycle has proper endDate
        if let firstCompleted = store.cycles.filter({ $0.isComplete }).sorted(by: { $0.startDate > $1.startDate }).first {
            print("  \(firstCompleted.endDate != nil ? "✅ PASS" : "❌ FAIL"): completed cycle has endDate")
        }
    }

    // ──────────────────────────────────────────────
    // MARK: - cycleLength never 0
    // ──────────────────────────────────────────────

    static func testCycleLengthOngoingNeverZero() {
        print("\n── Test: ongoing cycle cycleLength is never 0 ──")
        let today = cal.startOfDay(for: Date())
        let start = cal.date(byAdding: .day, value: -3, to: today)!

        // Build a minimal ongoing cycle
        let days = (1...30).map { day in
            CycleDay(
                dayIndex: day,
                phase: day <= 5 ? .menstrual : .follicular,
                symptoms: [],
                basalBodyTemperature: nil
            )
        }
        let ongoingCycle = CycleData(
            id: UUID(), month: "Test", startDate: start,
            endDate: nil, isOvulationConfirmed: false, days: days
        )
        print("  Ongoing cycle cycleLength: \(ongoingCycle.cycleLength)")
        print("  \(ongoingCycle.cycleLength > 0 ? "✅ PASS" : "❌ FAIL"): should be > 0 (got \(ongoingCycle.cycleLength))")

        // Also test empty days edge case
        let emptyCycle = CycleData(
            id: UUID(), month: "Test", startDate: start,
            endDate: nil, isOvulationConfirmed: false, days: []
        )
        print("  Empty-days cycle cycleLength: \(emptyCycle.cycleLength)")
        print("  ℹ️  (days.count = 0 is only possible if seed had cycleLength=0, which generateCycleDays guards against)")
    }

    // ──────────────────────────────────────────────
    // MARK: - Helpers
    // ──────────────────────────────────────────────

    private static func makeCycle(start: Date, end: Date?, cycleLength: Int, periodLength: Int) -> CycleData {
        let days = (1...cycleLength).map { day in
            CycleDay(
                dayIndex: day,
                phase: day <= periodLength ? .menstrual : .follicular,
                symptoms: [],
                basalBodyTemperature: nil
            )
        }
        return CycleData(
            id: UUID(), month: shortDate(start), startDate: start,
            endDate: end, isOvulationConfirmed: false, days: days
        )
    }

    private static func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
}
