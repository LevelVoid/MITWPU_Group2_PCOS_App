//
//  CycleDataStore.swift
//  PCOS_App
//
//  Created by Abhinaya Rajarajan on 17/02/26.
//
import Foundation

final class CycleDataStore {

    static let shared = CycleDataStore()
    private let calendar = Calendar.current

    private(set) var cycles: [CycleData] = []

    private init() {
        loadCycles()
    }
}

extension CycleDataStore {
    private func generateMockCycles(count: Int) -> [CycleData] {
        let seeds = mockCycleSeeds(count: count)

        return seeds.map { seed in
            CycleData(
                id: UUID(),
                month: monthString(from: seed.startDate),
                startDate: seed.startDate,
                days: generateCycleDays(from: seed)
            )
        }
    }

}
private struct CycleSeed {
    let startDate: Date
    let cycleLength: Int
    let periodLength: Int
}

private extension CycleDataStore {

    func mockCycleSeeds(count: Int) -> [CycleSeed] {

        let today = calendar.startOfDay(for: Date())

        return [
            CycleSeed(
                startDate: calendar.date(byAdding: .day, value: -30, to: today)!,
                cycleLength: 29,
                periodLength: 4
            ),
            CycleSeed(
                startDate: calendar.date(byAdding: .day, value: -60, to: today)!,
                cycleLength: 27,
                periodLength: 5
            ),
            CycleSeed(
                startDate: calendar.date(byAdding: .day, value: -100, to: today)!,
                cycleLength: 31,
                periodLength: 4
            )
        ].prefix(count).map { $0 }
    }
    
}
extension CycleDataStore {

    func loadCycles() {
        if let data = UserDefaults.standard.data(forKey: "SavedCycles"),
           let decoded = try? JSONDecoder().decode([CycleData].self, from: data) {
            cycles = decoded
        } else {
            cycles = generateMockCycles(count: 3)
        }
    }

    func saveCycles() {
        if let data = try? JSONEncoder().encode(cycles) {
            UserDefaults.standard.set(data, forKey: "SavedCycles")
        }
    }

    func loadRecentCycles(count: Int = 6) -> [CycleData] {
        Array(cycles.prefix(count))
    }
}

private extension CycleDataStore {

    func phaseForDay(
        day: Int,
        cycleLength: Int,
        periodLength: Int
    ) -> Phase {

        if day <= periodLength {
            return .menstrual
        }

        let ovulationDay = max(cycleLength - 14, periodLength + 1)
        let fertileStart = max(ovulationDay - 4, periodLength + 1)
        let fertileEnd = ovulationDay + 1

        if day == ovulationDay {
            return .ovulation
        }

        if day >= fertileStart && day <= fertileEnd {
            return .follicular
        }

        if day > ovulationDay {
            return .luteal
        }

        return .unknown
    }
}
private extension CycleDataStore {

    func symptomsForDay(
        dayIndex: Int,
        cycleStartDate: Date
    ) -> [SymptomItem] {

        guard let date = calendar.date(
            byAdding: .day,
            value: dayIndex - 1,
            to: cycleStartDate
        ) else {
            return []
        }

        return SymptomDataStore.loadSymptoms(for: date)
    }
}
private extension CycleDataStore {

    func generateCycleDays(from seed: CycleSeed) -> [CycleDay] {

        (1...seed.cycleLength).map { day in
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
                )
            )
        }
    }
}
private extension CycleDataStore {

    func monthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
extension CycleDataStore {

    func createCycle(from periodDates: [Date]) -> CycleData {

        let startDate = periodDates.min()!
        let periodLength = periodDates.count
        let estimatedCycleLength = 28 // until prediction exists

        let seed = CycleSeed(
            startDate: startDate,
            cycleLength: estimatedCycleLength,
            periodLength: periodLength
        )

        return CycleData(
            id: UUID(),
            month: monthString(from: startDate),
            startDate: startDate,
            days: generateCycleDays(from: seed)
        )
    }

    func addCycle(_ cycle: CycleData) {
        cycles.insert(cycle, at: 0)
        saveCycles()
    }
}

