//
//  AppDelegate.swift
//  PCOS_App
//
//  Created by SDC-USER on 22/11/25.
//

import UIKit
import HealthKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Core Data Stack
        
        /// The persistent container holds:
        /// - The managed object model (.xcdatamodeld schema)
        /// - The persistent store coordinator (SQLite file on disk)
        /// - The managed object context (in-memory scratchpad you read/write through)
        ///
        /// `lazy` because we only create it once, on first access.
        /// The name "PCOS_App" must match your .xcdatamodeld file name exactly.
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PCOS_App")
        
        let description = NSPersistentStoreDescription()
        description.url = NSPersistentContainer.defaultDirectoryURL()
            .appendingPathComponent("PCOS_App.sqlite")
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Core Data store failed to load: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()

        
        /// Shortcut — this is the main-thread context you'll use in view controllers.
        /// Every Core Data read/write on the UI thread goes through this.
        var viewContext: NSManagedObjectContext {
            return persistentContainer.viewContext
        }
        
        /// Call this whenever you've made changes that need to persist.
        /// If the context has no changes, this is a no-op (cheap to call).
        func saveContext() {
            let context = viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nsError = error as NSError
                    // In production, log this and show an alert — don't crash
                    print("Core Data save error: \(nsError), \(nsError.userInfo)")
                }
            }
        }
    
    func applicationWillTerminate(_ application: UIApplication) {
            // Save any pending changes when the app is about to be killed.
            // This catches the edge case where the user force-quits
            // right after making changes.
            saveContext()
        }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Request HealthKit authorization up-front so the permission sheet
        // appears at launch rather than mid-workout.
        
        HealthKitManager.shared.requestAuthorization { granted, error in
            if let error = error {
                print("HealthKit auth error: \(error.localizedDescription)")
            } else {
                print("HealthKit authorization granted: \(granted)")
            }
        }
        print("📂 Core Data path: \(NSPersistentContainer.defaultDirectoryURL())")
        _ = SymptomDataStore.shared
//        FoodLogDataStore.seedSampleDataIfNeeded()
        ChatPersistenceManager.shared.deleteOldMessages()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

