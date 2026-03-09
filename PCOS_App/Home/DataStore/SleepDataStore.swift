//
//  SleepDatabase.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/03/26.
//

import Foundation

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
    func saveSleepLog(_ log: SleepLog) {
        if let encoded = try? JSONEncoder().encode(log) {
            UserDefaults.standard.set(encoded, forKey: todayKey)
        }
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
