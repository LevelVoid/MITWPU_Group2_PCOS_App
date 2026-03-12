//
//  ProfileService.swift
//  PCOS_App
//
//  Migrated from UserDefaults to Core Data
//

import Foundation
import CoreData
import UIKit

class ProfileService {
    static let shared = ProfileService()
    
    // Old key — only used for one-time migration
    private let legacyProfileKey = "savedUserProfile"
    
    private var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.viewContext
    }
    
    private init() {
        migrateLegacyDataIfNeeded()
    }
    
    // MARK: - Read
    
    /// Fetches the singleton CDUser. Returns nil if no profile exists yet.
    func getProfile() -> CDUser? {
        let request: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("❌ Failed to fetch CDUser: \(error)")
            return nil
        }
    }
    
    // MARK: - Write
    
    /// Creates or updates the singleton CDUser.
    /// Called from HealthDetailsTableViewController (edit mode)
    /// and from UserGoalViewController (end of onboarding).
    func setProfile(name: String, dob: Date, heightCm: Double, weightKg: Double,
                    dietPattern: String, activityLevel: String, pcosPhenotype: String?) {
        
        // Fetch existing or create new
        let user = getProfile() ?? CDUser(context: context)
        
        // Only set id + created_at on first creation
        if user.id == nil {
            user.id = UUID()
            user.createdAt = Date()
        }
        
        user.name = name
        user.dateOfBirth = dob
        user.heightCm = heightCm
        user.weightKg = weightKg
        user.dietPattern = dietPattern
        user.activityLevel = activityLevel
        user.pcosPhenotype = pcosPhenotype
        
        saveContext()
    }
    
    /// Convenience overload that accepts the old ProfileModel
    /// so HealthDetailsTableViewController doesn't break immediately.
    /// We'll remove this once HealthDetailsVC is fully migrated.
    func setProfile(to profile: ProfileModel) {
        setProfile(
            name: profile.name,
            dob: profile.dob,
            heightCm: Double(profile.height),
            weightKg: Double(profile.weight),
            dietPattern: profile.dietType,
            activityLevel: profile.workoutType,
            pcosPhenotype: profile.pcosPhenotype
        )
    }
    
    // MARK: - Delete
    
    func deleteProfile() {
        if let user = getProfile() {
            context.delete(user)
            saveContext()
            print("🗑️ CDUser deleted")
        }
    }
    
    // MARK: - Save Helper
    
    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
            print("✅ CDUser saved successfully")
        } catch {
            print("❌ CoreData save error: \(error)")
        }
    }
    
    // MARK: - One-Time Migration
    
    /// If the old UserDefaults profile exists and no CDUser exists yet,
    /// migrate the data to Core Data and delete the old key.
    private func migrateLegacyDataIfNeeded() {
        guard let legacyData = UserDefaults.standard.data(forKey: legacyProfileKey),
              getProfile() == nil else {
            return
        }
        
        print("🔄 Migrating profile from UserDefaults → Core Data...")
        
        guard let oldProfile = try? JSONDecoder().decode(ProfileModel.self, from: legacyData) else {
            print("⚠️ Failed to decode legacy ProfileModel")
            return
        }
        
        setProfile(to: oldProfile)
        
        // Remove old data so we never migrate again
        UserDefaults.standard.removeObject(forKey: legacyProfileKey)
        print("✅ Profile migration complete")
    }
}
