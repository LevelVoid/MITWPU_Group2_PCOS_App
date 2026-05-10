//
//  WorkoutLiveActivityAttributes.swift
//  PCOS_App
//

import Foundation
import ActivityKit

public struct WorkoutLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var startDate: Date
        /// The workout end date (used to drive the countdown timer in the Dynamic Island)
        public var endDate: Date
        /// Workout name, e.g. "Upper Body Strength"
        public var workoutName: String

        public init(startDate: Date, endDate: Date, workoutName: String) {
            self.startDate = startDate
            self.endDate = endDate
            self.workoutName = workoutName
        }
    }

    public var routineName: String

    public init(routineName: String) {
        self.routineName = routineName
    }
}
