import Foundation
import CoreData

@objc(CDCorrelationResult)
public class CDCorrelationResult: NSManagedObject {
    
    var direction: String {
        rValue >= 0 ? "trigger" : "reducer"
    }
    
    var correlationStrength: String {
        if confidence >= 0.7 { return "strong" }
        if confidence >= 0.4 { return "moderate" }
        if confidence >= 0.2 { return "weak" }
        return "none"
    }
}
