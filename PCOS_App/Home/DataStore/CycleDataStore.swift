//
//  CycleDataStore.swift
//  PCOS_App
//
//  Created by Abhinaya Rajarajan on 17/02/26.
//
import Foundation
import CoreData
import UIKit

final class CycleDataStore {

    static let shared = CycleDataStore()
    private let calendar = Calendar.current
    private let predictionEngine = PeriodPredictionEngine()
    private var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.viewContext
    }


    private(set) var cycles: [CycleData] = []

    private init() {
        migrateIfNeeded()
        loadCycles()
    }

    /// One-time migration to clear stale SavedCycles from old app versions.
    private func migrateIfNeeded() {
        let migrationKey = "CycleDataStore_v2_migrated"
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }

        // Clear old pre-built cycles — we'll rebuild from SavedPeriodDates
        UserDefaults.standard.removeObject(forKey: "SavedCycles")
        UserDefaults.standard.set(true, forKey: migrationKey)
    }
}

// MARK: - Internal seed used only during cycle building

private struct CycleSeed {
    let startDate: Date
    let cycleLength: Int
    let periodLength: Int
}

// MARK: - Predictions

extension CycleDataStore {
    var nextPeriodPrediction: PeriodPrediction {
        predictionEngine.predict(from: cycles)
    }
}

// MARK: - Storage & Queries

extension CycleDataStore {

    func loadCycles() {
        // Try loading from Core Data first
        let request: NSFetchRequest<CDCycleData> = CDCycleData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        
        do {
            let cdCycles = try context.fetch(request)
            if !cdCycles.isEmpty {
                // Convert CDCycleData → CycleData for backward compatibility
                cycles = cdCycles.map { $0.toCycleData(using: self) }
                return
            }
        } catch {
            print("❌ Failed to fetch CDCycleData: \(error)")
        }
        
        // Fallback: rebuild from legacy UserDefaults (first launch after migration)
        if let timestamps = UserDefaults.standard.array(forKey: "SavedPeriodDates") as? [TimeInterval] {
            let dates = timestamps.map { calendar.startOfDay(for: Date(timeIntervalSince1970: $0)) }
            if !dates.isEmpty {
                rebuildCycles(from: dates)
                return
            }
        }
        cycles = []
    }

    func loadRecentCycles(count: Int = 6) -> [CycleData] {
        Array(cycles.prefix(count))
    }

    /// True when we have at least 2 cycles total — enough to show trends.
    var hasTwoCycles: Bool {
        cycles.count >= 2
    }

    // MARK: - Current & Previous Cycle Helpers

    /// The most-recent (ongoing) cycle — the one whose startDate is closest to
    /// today and whose startDate is not in the future.
    var currentCycle: CycleData? {
        let today = calendar.startOfDay(for: Date())
        return cycles
            .filter { calendar.startOfDay(for: $0.startDate) <= today }
            .sorted { $0.startDate > $1.startDate }
            .first
    }

    /// The `count` completed cycles that come before the current cycle,
    /// sorted newest-first.
    func previousCycles(count: Int = 3) -> [CycleData] {
        guard let current = currentCycle else {
            return Array(cycles.prefix(count))
        }
        let prev = cycles
            .filter { $0.id != current.id }
            .sorted { $0.startDate > $1.startDate }
        return Array(prev.prefix(count))
    }

    /// Average cycle length from completed cycles (for estimating the ongoing cycle).
    /// Falls back to 35 (PCOS-friendly default) when there are no completed cycles.
    var averageCompletedCycleLength: Int {
        let completed = cycles.filter { $0.isComplete }
        let lengths = completed.map { $0.cycleLength }.filter { $0 > 0 }
        guard !lengths.isEmpty else { return 35 }
        return lengths.reduce(0, +) / lengths.count
    }
}

// MARK: - PCOS-Aware Phase Logic

extension CycleDataStore {

    /// Determine the phase for a given day within a cycle.
    ///
    /// Key PCOS improvements over the textbook `cycleLength − 14` rule:
    /// - Uses a **dynamic luteal length** (average of user's completed cycles,
    ///   clamped 10-16, default 13) instead of a fixed 14.
    /// - Ovulation is a **3-day window**, not a single day.
    /// - For very long cycles (> 45 days) without confirmed ovulation, mid-cycle
    ///   days are marked `.unknown` (likely anovulatory).
    /// - When `isOvulationConfirmed` is true (future BBT support), ovulation
    ///   placement is trusted even for long cycles.
    func phaseForDay(
        day: Int,
        cycleLength: Int,
        periodLength: Int,
        isOvulationConfirmed: Bool = false
    ) -> Phase {

        guard cycleLength > 0, day >= 1 else { return .unknown }

        // ── Menstrual ──
        if day <= periodLength {
            return .menstrual
        }

        // ── For very long unconfirmed cycles (likely anovulatory in PCOS),
        //    we don't pretend to know where ovulation fell. ──
        if cycleLength > 45 && !isOvulationConfirmed {
            if day <= periodLength { return .menstrual }       // already covered above
            if day <= periodLength + 5 { return .follicular }  // short early follicular
            return .unknown                                    // rest is uncertain
        }

        // ── Luteal length estimate ──
        let estimatedLutealLength = averageLutealLength()      // 10-16, default 13

        // Ovulation day = cycleLength − lutealLength
        let ovulationCenter = max(cycleLength - estimatedLutealLength, periodLength + 1)

        // 3-day ovulation window
        let ovulationStart = max(ovulationCenter - 1, periodLength + 1)
        let ovulationEnd   = min(ovulationCenter + 1, cycleLength)

        // Follicular: from end of period to start of ovulation window
        let follicularStart = periodLength + 1
        let follicularEnd   = ovulationStart - 1

        if day >= follicularStart && day <= follicularEnd {
            return .follicular
        }
        if day >= ovulationStart && day <= ovulationEnd {
            return .ovulation
        }
        if day > ovulationEnd {
            return .luteal
        }

        return .follicular
    }

    /// Current cycle day and phase for the home header.
    func currentPhaseInfo() -> (cycleDay: Int, phase: Phase) {
        let today = calendar.startOfDay(for: Date())

        guard let latestCycle = cycles
            .filter({ calendar.startOfDay(for: $0.startDate) <= today })
            .sorted(by: { $0.startDate > $1.startDate })
            .first else {
            return (0, .unknown)       // No cycles logged yet
        }

        let startOfCycle = calendar.startOfDay(for: latestCycle.startDate)
        let daysDiff = calendar.dateComponents([.day], from: startOfCycle, to: today).day ?? 0
        let cycleDay = daysDiff + 1

        if cycleDay < 1 {
            return (1, .unknown)
        }

        // Past the expected cycle length → period may be late / anovulatory
        if cycleDay > latestCycle.cycleLength {
            return (cycleDay, latestCycle.isOvulationConfirmed ? .luteal : .unknown)
        }

        let phase = phaseForDay(
            day: cycleDay,
            cycleLength: latestCycle.cycleLength,
            periodLength: latestCycle.periodLength,
            isOvulationConfirmed: latestCycle.isOvulationConfirmed
        )
        return (cycleDay, phase)
    }

    // MARK: - Luteal Length Estimation

    /// Estimates the user's average luteal phase length from completed cycles.
    /// Clamped to 10-16 (biological range). Defaults to 13 for PCOS.
    private func averageLutealLength() -> Int {
        let completed = cycles.filter { $0.isComplete && $0.cycleLength > 0 && $0.periodLength > 0 }
        guard completed.count >= 2 else { return 13 }   // PCOS default (not textbook 14)

        // luteal ≈ cycleLength − (estimated ovulation day)
        // estimated ovulation ≈ cycleLength − 14 as a starting point, then refine
        // But without BBT we approximate: luteal = cycleLength − periodLength − follicularEstimate
        // Simplest reliable approach: cycleLength − (cycleLength × 0.6) ≈ 0.4 × cycleLength
        // Better: use the last N cycles' (cycleLength - periodLength) / 2 as a rough split

        let lutealEstimates = completed.suffix(4).map { cycle -> Int in
            // Post-period days split roughly 60/40 follicular/luteal is textbook.
            // We do: cycleLength − ovulationEstimate, where ovulation ≈ cycle * 0.58
            let ovEst = max(Int(Double(cycle.cycleLength) * 0.58), cycle.periodLength + 1)
            return cycle.cycleLength - ovEst
        }

        let avg = lutealEstimates.reduce(0, +) / max(lutealEstimates.count, 1)
        return min(max(avg, 10), 16)    // clamp to biological range
    }
}

// MARK: - Cycle Day & Month Builders (Private)

private extension CycleDataStore {

    func symptomsForDay(dayIndex: Int, cycleStartDate: Date) -> [SymptomItem] {
        guard let date = calendar.date(
            byAdding: .day,
            value: dayIndex - 1,
            to: cycleStartDate
        ) else { return [] }
        return SymptomDataStore.loadSymptoms(for: date)
    }

    func generateCycleDays(from seed: CycleSeed) -> [CycleDay] {
        guard seed.cycleLength > 0 else { return [] }
        return (1...seed.cycleLength).map { day in
            CycleDay(
                dayIndex: day,
                phase: phaseForDay(
                    day: day,
                    cycleLength: seed.cycleLength,
                    periodLength: seed.periodLength
                ),
                symptoms: symptomsForDay(
                    dayIndex: day,
                    cycleStartDate: seed.startDate
                ),
                basalBodyTemperature: nil
            )
        }
    }

    func monthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Rebuild Cycles from Period Dates

extension CycleDataStore {

    /// Rebuilds ALL cycles from the selected period dates.
    ///
    /// The calendar preloads dates from existing cycles, so `allDates`
    /// is the single source of truth.  Deselecting dates removes them.
    func rebuildCycles(from allDates: [Date]) {

        let sorted = allDates.map { calendar.startOfDay(for: $0) }.sorted()

        guard !sorted.isEmpty else {
            cycles = []
            // Delete all CDCycleData
            let deleteRequest: NSFetchRequest<NSFetchRequestResult> = CDCycleData.fetchRequest()
            let batchDelete = NSBatchDeleteRequest(fetchRequest: deleteRequest)
            try? context.execute(batchDelete)
            try? context.save()
            return
        }


        // ── 1. Group into contiguous period runs (gap > 1 day = new period) ──
        var periodGroups: [[Date]] = [[sorted[0]]]
        for i in 1..<sorted.count {
            let gap = calendar.dateComponents(
                [.day], from: sorted[i - 1], to: sorted[i]
            ).day ?? 0
            if gap <= 1 {
                periodGroups[periodGroups.count - 1].append(sorted[i])
            } else {
                periodGroups.append([sorted[i]])
            }
        }
        periodGroups.sort { ($0.first ?? .distantPast) < ($1.first ?? .distantPast) }

        // ── 2. First pass: calculate cycle lengths from gaps between starts ──
        //    Completed cycles: length = gap to next period start, endDate = day before next start.
        //    Last (ongoing) cycle: use average of completed cycles (PCOS-friendly default 35).
        var completedLengths: [Int] = []
        for idx in 0..<periodGroups.count - 1 {
            let thisStart = calendar.startOfDay(for: periodGroups[idx].first!)
            let nextStart = calendar.startOfDay(for: periodGroups[idx + 1].first!)
            let gap = calendar.dateComponents([.day], from: thisStart, to: nextStart).day ?? 28
            completedLengths.append(max(gap, periodGroups[idx].count))
        }

        // Average completed length for estimating the ongoing cycle
        let avgCompleted: Int
        if completedLengths.isEmpty {
            avgCompleted = 35                          // PCOS-friendly default
        } else {
            avgCompleted = completedLengths.reduce(0, +) / completedLengths.count
        }

        // ── 3. Build final CycleData objects ──
        var finalCycles: [CycleData] = []

        for (idx, group) in periodGroups.enumerated() {
            let startDate = group.first!
            let periodLength = group.count
            let isLast = idx == periodGroups.count - 1

            let cycleLength: Int
            let endDate: Date?

            if !isLast {
                // Completed cycle
                cycleLength = completedLengths[idx]
                let nextStart = calendar.startOfDay(for: periodGroups[idx + 1].first!)
                endDate = calendar.date(byAdding: .day, value: -1, to: nextStart)
            } else {
                // Ongoing cycle — estimate using average or PCOS default
                let today = calendar.startOfDay(for: Date())
                let daysSoFar = calendar.dateComponents([.day], from: calendar.startOfDay(for: startDate), to: today).day ?? 0
                // Use the larger of: average completed length, or days elapsed + buffer
                cycleLength = max(avgCompleted, daysSoFar + 7)
                endDate = nil
            }

            let seed = CycleSeed(
                startDate: startDate,
                cycleLength: cycleLength,
                periodLength: periodLength
            )

            finalCycles.append(CycleData(
                id: UUID(),
                month: monthString(from: startDate),
                startDate: startDate,
                endDate: endDate,
                isOvulationConfirmed: false,
                days: generateCycleDays(from: seed)
            ))
        }

        // ── 4. Store newest-first ──
        cycles = finalCycles.sorted { $0.startDate > $1.startDate }
        
        // ── 5. Persist to Core Data ──
        saveToCoreData(from: cycles)
        
        // ── 6. Clean up legacy UserDefaults ──
        UserDefaults.standard.removeObject(forKey: "SavedCycles")
    }
    
    private func saveToCoreData(from cycleDataArray: [CycleData]) {
        // Delete all existing CDCycleData (we rebuild from scratch each time)
        let deleteRequest: NSFetchRequest<NSFetchRequestResult> = CDCycleData.fetchRequest()
        let batchDelete = NSBatchDeleteRequest(fetchRequest: deleteRequest)
        
        do {
            try context.execute(batchDelete)
        } catch {
            print("❌ Failed to delete old CDCycleData: \(error)")
        }
        
        // Insert fresh CDCycleData objects
        for cycle in cycleDataArray {
            let cdCycle = CDCycleData(context: context)
            cdCycle.id = cycle.id
            cdCycle.startDate = cycle.startDate
            cdCycle.endDate = cycle.endDate
            cdCycle.periodLength = Int16(cycle.periodLength)
            cdCycle.cycleLength = cycle.isComplete ? Int16(cycle.cycleLength) : 0
            cdCycle.isOvulationConfirmed = cycle.isOvulationConfirmed
        }
        
        // Save
        if context.hasChanges {
            do {
                try context.save()
                print("✅ \(cycleDataArray.count) cycles saved to Core Data")
            } catch {
                print("❌ Core Data save error: \(error)")
            }
        }
    }

}
