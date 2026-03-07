//
//  PeriodPredictionModel.swift
//  PCOS_App
//
//  Created by Abhinaya Rajarajan on 07/03/26.
//

import Foundation

// MARK: - Prediction Confidence

enum PredictionConfidence {
    case none, low, medium, high

    var label: String {
        switch self {
        case .none:   return ""
        case .low:    return "Low confidence"
        case .medium: return "Medium confidence"
        case .high:   return "Based on your recent cycles"
        }
    }
}

// MARK: - Period Prediction Result

struct PeriodPrediction {
    let predictedStartDate: Date?
    let predictedEndDate: Date?
    let daysUntil: Int?
    let confidence: PredictionConfidence
    let averageCycleLength: Int?
    let averagePeriodLength: Int?
    let isLate: Bool

    var summaryText: String {
        switch confidence {
        case .none:
            return "Log your period to start tracking"
        case .low, .medium, .high:
            guard let days = daysUntil else { return "Log more cycles for predictions" }
            if isLate { return "Cycle may be irregular — keep tracking" }
            if days == 0 { return "Period may start today" }
            if days < 0 {
                let overdue = abs(days)
                return "Period is \(overdue) day\(overdue == 1 ? "" : "s") late"
            }
            let confidenceNote = confidence == .low ? " (low confidence)" : ""
            return "Next period in ~\(days) day\(days == 1 ? "" : "s")\(confidenceNote)"
        }
    }

    /// Empty prediction for brand-new users.
    static let empty = PeriodPrediction(
        predictedStartDate: nil,
        predictedEndDate: nil,
        daysUntil: nil,
        confidence: .none,
        averageCycleLength: nil,
        averagePeriodLength: nil,
        isLate: false
    )
}

// MARK: - Prediction Engine

struct PeriodPredictionEngine {

    private let calendar = Calendar.current

    /// PCOS cycles can be very long; cap predictions so the UI doesn't show
    /// "next period in 90 days" from a single outlier cycle.
    private let maxPredictableCycleLength = 60

    // MARK: - Public API

    /// Main prediction: when is the next period?
    func predict(from cycles: [CycleData]) -> PeriodPrediction {

        let sorted = cycles.sorted { $0.startDate < $1.startDate }

        guard let latestCycle = sorted.last else { return .empty }

        let completedCycles = sorted.filter { $0.isComplete }

        let confidence: PredictionConfidence
        switch completedCycles.count {
        case 0:            confidence = .none
        case 1:            confidence = .low
        case 2:            confidence = .medium
        default:           confidence = .high
        }

        // Need at least one completed cycle to predict anything
        guard !completedCycles.isEmpty else {
            return PeriodPrediction(
                predictedStartDate: nil,
                predictedEndDate: nil,
                daysUntil: nil,
                confidence: confidence,
                averageCycleLength: nil,
                averagePeriodLength: nil,
                isLate: false
            )
        }

        // Use up to 3 most-recent completed cycles (median, not mean — resistant to outliers)
        let recentCompleted = Array(completedCycles.suffix(3))
        let cycleLengths = recentCompleted.map { $0.cycleLength }.filter { $0 > 0 }

        let calculatedCycleLength: Int
        if cycleLengths.isEmpty {
            calculatedCycleLength = 35          // PCOS-friendly default
        } else {
            calculatedCycleLength = median(of: cycleLengths)
        }

        let appliedCycleLength = min(calculatedCycleLength, maxPredictableCycleLength)

        // Period length (for predictedEndDate)
        let periodLengths = recentCompleted.map { $0.periodLength }.filter { $0 > 0 }
        let avgPeriodLength = periodLengths.isEmpty ? 5 : max(1, median(of: periodLengths))

        // Predicted start = last cycle start + avg cycle length
        let lastCycleStart = calendar.startOfDay(for: latestCycle.startDate)

        guard let predictedStart = calendar.date(byAdding: .day, value: appliedCycleLength, to: lastCycleStart) else {
            return PeriodPrediction(
                predictedStartDate: nil,
                predictedEndDate: nil,
                daysUntil: nil,
                confidence: confidence,
                averageCycleLength: appliedCycleLength,
                averagePeriodLength: avgPeriodLength,
                isLate: false
            )
        }

        let predictedEnd = calendar.date(byAdding: .day, value: avgPeriodLength - 1, to: predictedStart)
        let today = calendar.startOfDay(for: Date())
        let daysUntil = calendar.dateComponents([.day], from: today, to: predictedStart).day ?? 0

        let currentCycleLength = calendar.dateComponents([.day], from: lastCycleStart, to: today).day ?? 0
        let isLate = daysUntil < 0
            && (currentCycleLength > Int(Double(appliedCycleLength) * 1.4)
                || currentCycleLength > maxPredictableCycleLength)

        return PeriodPrediction(
            predictedStartDate: predictedStart,
            predictedEndDate: predictedEnd,
            daysUntil: daysUntil,
            confidence: confidence,
            averageCycleLength: appliedCycleLength,
            averagePeriodLength: avgPeriodLength,
            isLate: isLate
        )
    }

    /// Returns an array of predicted period dates (for calendar display).
    func predictedDates(from cycles: [CycleData]) -> [Date] {
        let prediction = predict(from: cycles)
        guard let start = prediction.predictedStartDate,
              let end   = prediction.predictedEndDate else { return [] }

        var dates: [Date] = []
        var current = start
        while current <= end {
            dates.append(calendar.startOfDay(for: current))
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return dates
    }

    // MARK: - Helpers

    /// Median value — more resistant to outlier cycles than mean.
    private func median(of values: [Int]) -> Int {
        let sorted = values.sorted()
        let count = sorted.count
        if count % 2 == 0 {
            return (sorted[count / 2 - 1] + sorted[count / 2]) / 2
        } else {
            return sorted[count / 2]
        }
    }
}
