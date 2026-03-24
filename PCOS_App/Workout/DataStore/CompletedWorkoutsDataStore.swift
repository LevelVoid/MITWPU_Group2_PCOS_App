import Foundation
import CoreData
import UIKit

final class CompletedWorkoutsDataStore {

    static let shared = CompletedWorkoutsDataStore()
    
    private static var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.viewContext
    }
    
    private init() {
        if loadAll().isEmpty {
            CompletedWorkoutsDataStore.migrateLegacyDataIfNeeded()
        }
    }

    // MARK: - Save
    func save(_ workout: CompletedWorkout) {
            let ctx = Self.context
            
            // Remove any existing partial (not fully completed) record for the same routine
            // to prevent duplicate partial records from piling up
            deletePartialWorkouts(for: workout.routineName, in: ctx)
            
            let cdWorkout = CDCompletedWorkout(context: ctx)
            cdWorkout.id = workout.id
            cdWorkout.routineName = workout.routineName
            cdWorkout.date = workout.date
            cdWorkout.startTime = workout.startTime
            cdWorkout.durationSeconds = Int32(workout.durationSeconds)
            cdWorkout.caloriesBurned = workout.caloriesBurned
            cdWorkout.exercises = workout.exercises
            // Also save as individual CDWorkoutExercise rows for per-exercise queries
            for (index, we) in workout.exercises.enumerated() {
                   let cdExercise = CDWorkoutExercise.from(we, index: index, context: ctx)
                   cdExercise.completedWorkout = cdWorkout
               }
            // Link to CDDailyContext for relational queries
            let dailyContext = DailyActivityDataStore.shared.getOrCreateContext(for: workout.date)
            cdWorkout.dailyContext = dailyContext
        
        if ctx.hasChanges {
            do {
                try ctx.save()
            } catch {
                print(" Failed to save CDCompletedWorkout: \(error)")
            }
        }
    }
    
    // MARK: - Cleanup Partial Records
    /// Deletes any existing partial (not fully completed) workout records for a given routine.
    /// This prevents duplicate partial records from accumulating when the user ends a workout
    /// early multiple times.
    private func deletePartialWorkouts(for routineName: String, in ctx: NSManagedObjectContext) {
        let request: NSFetchRequest<CDCompletedWorkout> = CDCompletedWorkout.fetchRequest()
        request.predicate = NSPredicate(format: "routineName == %@", routineName)
        
        do {
            let results = try ctx.fetch(request)
            for cdWorkout in results {
                let workout = cdWorkout.toCompletedWorkout()
                if !workout.isFullyCompleted {
                    ctx.delete(cdWorkout)
                }
            }
        } catch {
            print("Failed to clean up partial workouts: \(error)")
        }
    }

    // MARK: - Load
    func loadAll() -> [CompletedWorkout] {
        let request: NSFetchRequest<CDCompletedWorkout> = CDCompletedWorkout.fetchRequest()
        // Sort newest first
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let results = try Self.context.fetch(request)
            return results.map { $0.toCompletedWorkout() }
        } catch {
            print("Failed to fetch CDCompletedWorkout: \(error)")
            return []
        }
    }

    // MARK: - Queries
    func workout(on date: Date) -> CompletedWorkout? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return nil }
        
        let request: NSFetchRequest<CDCompletedWorkout> = CDCompletedWorkout.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.fetchLimit = 1
        
        guard let result = try? Self.context.fetch(request).first else { return nil }
        return result.toCompletedWorkout()
    }

    func hasCompletedWorkout(on date: Date) -> Bool {
        return workout(on: date) != nil
    }
    
    // MARK: - Migration
    private static func migrateLegacyDataIfNeeded() {
        let key = "completed_workouts_v1"
        guard let data = UserDefaults.standard.data(forKey: key),
              let legacyWorkouts = try? JSONDecoder().decode([CompletedWorkout].self, from: data) else {
            return
        }
        
        print("Migrating CompletedWorkouts from UserDefaults → Core Data...")
        
        for workout in legacyWorkouts {
            let cdWorkout = CDCompletedWorkout(context: context)
            cdWorkout.id = workout.id
            cdWorkout.routineName = workout.routineName
            cdWorkout.date = workout.date
            cdWorkout.startTime = workout.startTime
            cdWorkout.durationSeconds = Int32(workout.durationSeconds)
            cdWorkout.caloriesBurned = workout.caloriesBurned
            cdWorkout.exercises = workout.exercises
        }
        
        if context.hasChanges {
            try? context.save()
        }
        
        UserDefaults.standard.removeObject(forKey: key)
        print("Migrated \(legacyWorkouts.count) workouts to Core Data")
    }
    
    // MARK: - Seed Mock Data
    func seedMockWorkouts() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Avoid duplicating mock data
        // Only seed historical data if our array has less than 2 workouts
        if loadAll().count > 2 { return }


        // MARK: - Exercises
        let squat = Exercise(name: "Bodyweight Squats", muscleGroup: .legs, equipment: .none, image: "barbell_squat", level: "Beginner", tempo: "2-1-2", form: ["Chest up", "Knees out"], variations: [], commonMistakes: [])
        let pushUps = Exercise(name: "Lat Pulldown", muscleGroup: .chest, equipment: .none, image: "lat_pulldown", level: "Beginner", tempo: "2-0-2", form: ["Straight body line", "Elbows 45°"], variations: [], commonMistakes: [])

        // MARK: - Sets
        let squatSets = [
            ExerciseSet(setNumber: 1, reps: 12, restTimerSeconds: 60, durationSeconds: nil, completionState: .completed),
            ExerciseSet(setNumber: 2, reps: 12, restTimerSeconds: 60, durationSeconds: nil, completionState: .completed)
        ]
        let pushUpSets = [
            ExerciseSet(setNumber: 1, reps: 10, restTimerSeconds: 60, durationSeconds: nil, completionState: .completed)
        ]

        // MARK: - Workout Exercises
        let workoutExercises = [
            WorkoutExercise(id: UUID(), exercise: squat, sets: squatSets, notes: nil),
            WorkoutExercise(id: UUID(), exercise: pushUps, sets: pushUpSets, notes: nil)
        ]
        
        // Let's seed 15 days of dummy historical workouts so your calendar looks great
        for dayOffset in 0..<15 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            // Only workout every other day-ish to look realistic
            if dayOffset % 2 == 0 || dayOffset % 3 == 0 {
                let historicalWorkout = CompletedWorkout(
                    id: UUID(),
                    routineName: "Historical Routine",
                    date: date,
                    startTime: calendar.date(byAdding: .minute, value: -30, to: date) ?? date,
                    durationSeconds: 1800,
                    exercises: workoutExercises,
                    caloriesBurned: 150.0
                )
                save(historicalWorkout)
            }
        }
        print("Seeded CDCompletedWorkout Mock Data")
    }
}
