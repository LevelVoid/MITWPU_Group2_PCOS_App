//
//  PersistenceController.swift
//  PCOS_App
//
//  Thin wrapper that gives SharedContextEngine the
//  PersistenceController.shared.container.viewContext it expects —
//  delegates to the NSPersistentContainer that lives in AppDelegate.
//
import CoreData
import UIKit

struct PersistenceController {

    // MARK: - Shared instance
    static let shared = PersistenceController()
    

    private init() {}

    // MARK: - Forwarded container
    /// Returns the persistent container owned by AppDelegate.
    var container: NSPersistentContainer {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found — cannot access Core Data container.")
        }
        return delegate.persistentContainer
    }
}
