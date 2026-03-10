//
//  SleepDatabase.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/03/26.
//

import Foundation
import UIKit
import CoreData

// MARK: - SleepDatabase
/// Lightweight UserDefaults-backed store for daily sleep logs.
class SleepDataStore {

    static let shared = SleepDataStore()
    private init() {}

    // MARK: - Keys
    private func key(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "sleepLog_\(formatter.string(from: date))"
    }

    private var todayKey: String { key(for: Date()) }

    // MARK: - Save
    // MARK: - Save
    func saveSleepLog(_ log: SleepLog) {
        // 1. Keep UserDefaults for quick access (sleep card)
        if let encoded = try? JSONEncoder().encode(log) {
            UserDefaults.standard.set(encoded, forKey: key(for: log.wakeTime))
        }
        
        // 2. Also persist to CDDailyContext for correlation engine
        let dailyContext = DailyActivityDataStore.shared.getOrCreateContext(for: log.wakeTime)
        dailyContext.sleepTime = log.sleepTime
        dailyContext.wakeTime = log.wakeTime
        
        // Map SleepRating → sleepQuality (0.0–1.0 scale for correlation)
        let qualityScore: Double
        switch log.rating {
        case .deep:      qualityScore = 1.0
        case .normal:    qualityScore = 0.75
        case .light:     qualityScore = 0.5
        case .disturbed: qualityScore = 0.25
        }
        dailyContext.sleepQuality = qualityScore
        
        // Save context
        let ctx = (UIApplication.shared.delegate as! AppDelegate).viewContext
        if ctx.hasChanges {
            try? ctx.save()
        }
        
        print("✅ SleepLog saved to UserDefaults + CDDailyContext")
    }


    // MARK: - Load today
    func loadTodaySleepLog() -> SleepLog? {
        guard let data = UserDefaults.standard.data(forKey: todayKey),
              let log = try? JSONDecoder().decode(SleepLog.self, from: data) else {
            return nil
        }
        return log
    }

    // MARK: - Load specific date
    func loadSleepLog(for date: Date) -> SleepLog? {
        guard let data = UserDefaults.standard.data(forKey: key(for: date)),
              let log = try? JSONDecoder().decode(SleepLog.self, from: data) else {
            return nil
        }
        return log
    }
}
