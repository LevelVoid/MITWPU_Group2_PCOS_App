import Foundation
import CoreData

@objc(CDCycleData)
public class CDCycleData: NSManagedObject {
    
    /// Whether this cycle has ended (another period started after it)
    var isComplete: Bool {
        endDate != nil
    }
    
    /// Effective cycle length — stored value for completed, estimated for ongoing
    var effectiveCycleLength: Int {
        if cycleLength > 0 {
            return Int(cycleLength)
        }
        // Ongoing cycle: days elapsed so far
        let today = Calendar.current.startOfDay(for: Date())
        guard let start = startDate else { return 35 }
        let daysSoFar = Calendar.current.dateComponents([.day], from: start, to: today).day ?? 0
        return max(daysSoFar + 7, 35) // PCOS-friendly estimate
    }
    
    /// Convert to the existing CycleData struct for backward compatibility
    /// This lets all existing UI code keep working without changes
    func toCycleData(using dataStore: CycleDataStore) -> CycleData {
        let start = startDate ?? Date()
        let pLength = Int(periodLength)
        let cLength = effectiveCycleLength
        
        // Generate CycleDay array exactly like rebuildCycles currently does
        let days: [CycleDay] = (1...cLength).map { day in
            CycleDay(
                dayIndex: day,
                phase: dataStore.phaseForDay(
                    day: day,
                    cycleLength: cLength,
                    periodLength: pLength,
                    isOvulationConfirmed: isOvulationConfirmed
                ),
                symptoms: SymptomDataStore.loadSymptoms(
                    for: Calendar.current.date(byAdding: .day, value: day - 1, to: start) ?? start
                ),
                basalBodyTemperature: nil
            )
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        return CycleData(
            id: id ?? UUID(),
            month: formatter.string(from: start),
            startDate: start,
            endDate: endDate,
            isOvulationConfirmed: isOvulationConfirmed,
            days: days
        )
    }
}
