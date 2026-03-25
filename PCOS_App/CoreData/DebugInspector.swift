import Foundation
import CoreData
import UIKit

struct DebugInspector {

    private static var context: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }

    static func printAll() {
        print("\n" + String(repeating: "=", count: 70))
        print("🔍 CORE DATA DEBUG INSPECTOR")
        print(String(repeating: "=", count: 70))

        printChatMessages()
        printUsers()
        printCycleData()
        printDailyContexts()
        printFoodLogs()
        printCustomFoods()
        printSymptomLogs()
        printRoutines()
        printCompletedWorkouts()

        print(String(repeating: "=", count: 70))
        print("🔍 END DEBUG INSPECTOR\n")
    }

    static func printChatMessages() {
        let request: NSFetchRequest<CDChatMessage> = CDChatMessage.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        guard let results = try? context.fetch(request) else { return }
        print("\n💬 CDChatMessage (\(results.count) records)")
        for m in results {
            let preview = (m.text ?? "").prefix(50)
            print("  • [\(m.sortOrder)] \(m.senderRaw ?? "?") | \(fmt(m.timestamp)) | \"\(preview)\"")
        }
    }

    static func printUsers() {
        let request: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        guard let results = try? context.fetch(request) else { return }
        print("\n👤 CDUser (\(results.count) records)")
        for u in results {
            let cycleCount = (u.cycles as? Set<CDCycleData>)?.count ?? 0
            print("  • \(u.name ?? "nil") | H=\(u.heightCm)cm W=\(u.weightKg)kg | phenotype=\(u.pcosPhenotype ?? "nil") | cycles=\(cycleCount)")
        }
    }

    static func printCycleData() {
        let request: NSFetchRequest<CDCycleData> = CDCycleData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        guard let results = try? context.fetch(request) else { return }
        print("\n🔴 CDCycleData (\(results.count) records)")
        for c in results {
            print("  • start=\(fmt(c.startDate)) end=\(fmt(c.endDate)) cycle=\(c.cycleLength)d period=\(c.periodLength)d")
        }
    }

    static func printDailyContexts() {
        let request: NSFetchRequest<CDDailyContext> = CDDailyContext.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 7
        guard let results = try? context.fetch(request) else { return }
        print("\n📅 CDDailyContext (last 7)")
        for d in results {
            let foods = (d.foodLogs as? Set<CDFoodLog>)?.count ?? 0
            let symptoms = (d.symptomLogs as? Set<CDSymptomLog>)?.count ?? 0
            print("  • \(fmt(d.date)) | day=\(d.cycleDay) phase=\(d.cyclePhase ?? "nil") | foods=\(foods) symptoms=\(symptoms) steps=\(d.steps)")
        }
    }

    static func printFoodLogs() {
        let request: NSFetchRequest<CDFoodLog> = CDFoodLog.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
        request.fetchLimit = 10
        guard let results = try? context.fetch(request) else { return }
        print("\n🍽️ CDFoodLog (last 10)")
        for f in results {
            print("  • \(f.name ?? "nil") | \(fmt(f.timeStamp)) | P=\(Int(f.proteinContent))g C=\(Int(f.carbsContent))g F=\(Int(f.fatsContent))g")
        }
    }

    static func printCustomFoods() {
        let request: NSFetchRequest<CDCustomFood> = CDCustomFood.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        guard let results = try? context.fetch(request) else { return }
        print("\n🥘 CDCustomFood (\(results.count) records)")
        for f in results {
            print("  • \(f.name ?? "nil") | \(f.calories)kcal | used=\(f.timesUsed)x | AI=\(f.isAIScanned)")
        }
    }

    static func printSymptomLogs() {
        let request: NSFetchRequest<CDSymptomLog> = CDSymptomLog.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 10
        guard let results = try? context.fetch(request) else { return }
        print("\n🩺 CDSymptomLog (last 10)")
        for s in results {
            print("  • \(s.symptomName ?? "nil") [\(s.symptomCategory ?? "nil")] | \(fmt(s.date))")
        }
    }

    static func printRoutines() {
        let request: NSFetchRequest<CDRoutine> = CDRoutine.fetchRequest()
        guard let results = try? context.fetch(request) else { return }
        print("\n🏋️ CDRoutine (\(results.count) records)")
        for r in results {
            let exCount = (r.exercises as? Set<CDRoutineExercise>)?.count ?? 0
            print("  • \(r.name ?? "nil") | type=\(r.routineType ?? "nil") | exercises=\(exCount)")
        }
    }

    static func printCompletedWorkouts() {
        let request: NSFetchRequest<CDCompletedWorkout> = CDCompletedWorkout.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 5
        guard let results = try? context.fetch(request) else { return }
        print("\n✅ CDCompletedWorkout (last 5)")
        for w in results {
            print("  • \(w.routineName ?? "nil") | \(fmt(w.date)) | \(w.durationSeconds/60)min | \(Int(w.caloriesBurned))kcal")
        }
    }

    private static func fmt(_ date: Date?) -> String {
        guard let date = date else { return "nil" }
        let f = DateFormatter()
        f.dateFormat = "dd-MMM HH:mm"
        return f.string(from: date)
    }
}
