//
//  ChatPersistenceManager.swift
//  PCOS_App
//
//  Created by LevelVoid on 25/03/26.
//

import Foundation
import CoreData
import UIKit

final class ChatPersistenceManager {

    static let shared = ChatPersistenceManager()
    private init() {}

    private var context: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }

    // MARK: - Load Today's Messages

    /// Fetches only today's messages, sorted by sortOrder.
    ///
    /// Why filter by date?
    /// Chat only persists within the day. The Foundation Model's
    /// LanguageModelSession is in-memory — it resets on app kill.
    /// Showing yesterday's messages that the AI can't recall would
    /// break conversational continuity. The AI still accesses all
    /// historical health data (previous days' meals, symptoms, cycles)
    /// through SharedContextEngine — that's independent of chat.
    func loadTodaysMessages() -> [ChatMessage] {
        let startOfDay = Calendar.current.startOfDay(for: Date())

        let request: NSFetchRequest<CDChatMessage> = CDChatMessage.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp >= %@", startOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]

        let results = (try? context.fetch(request)) ?? []
        return results.map { $0.toChatMessage() }
    }

    // MARK: - Save Message

    /// Saves a message immediately after it appears on screen.
    ///
    /// Why save immediately, not in a batch?
    /// If the app crashes or is killed mid-conversation,
    /// every message up to that point is already persisted.
    func saveMessage(text: String, sender: MessageSender) {
        // Get next sortOrder based on today's messages
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let request: NSFetchRequest<CDChatMessage> = CDChatMessage.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp >= %@", startOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: false)]
        request.fetchLimit = 1

        let lastOrder = (try? context.fetch(request))?.first?.sortOrder ?? -1

        let cdMessage = CDChatMessage(context: context)
        cdMessage.id = UUID()
        cdMessage.text = text
        cdMessage.senderRaw = sender == .user ? "user" : "ai"
        cdMessage.timestamp = Date()
        cdMessage.sortOrder = lastOrder + 1

        save()
    }

    // MARK: - Build Chat Summary for AI Re-injection

    /// Returns a compact summary of today's earlier conversation
    /// so the AI has context after a cold restart.
    ///
    /// Why this approach?
    /// LanguageModelSession loses all memory when the app is killed.
    /// Re-injecting a summary into the context block gives the AI
    /// enough conversational awareness to handle follow-ups like
    /// "tell me more about that" without replaying every message.
    ///
    /// Why only last 5 pairs?
    /// The system prompt + health context already consume tokens.
    /// Keeping the summary compact avoids hitting context limits.
    func buildChatSummary() -> String {
        let todaysMessages = loadTodaysMessages()

        guard todaysMessages.count > 1 else { return "" }

        // Take the last 5 user-AI exchange pairs (10 messages max)
        let recentMessages = todaysMessages.suffix(10)

        var lines: [String] = []
        for msg in recentMessages {
            let role = msg.sender == .user ? "User" : "Adira"
            // Truncate long AI responses to keep summary compact
            let content = msg.sender == .ai
                ? String(msg.text.prefix(100)) + (msg.text.count > 100 ? "..." : "")
                : msg.text
            lines.append("\(role): \(content)")
        }

        return """
        [EARLIER TODAY — conversation summary for continuity:]
        \(lines.joined(separator: "\n"))
        [END SUMMARY]
        """
    }

    // MARK: - Clear All Messages

    /// Deletes all CDChatMessage records — used by the "Clear Chat" button.
    func clearAllMessages() {
        let request: NSFetchRequest<NSFetchRequestResult> = CDChatMessage.fetchRequest()
        let batchDelete = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try context.execute(batchDelete)
            try context.save()
            // Reset context so in-memory objects reflect the deletion
            context.reset()
        } catch {
            print("ERROR: Failed to clear chat messages: \(error)")
        }
    }

    // MARK: - Cleanup Old Messages

    /// Deletes messages from previous days. Call on app launch.
    ///
    /// Why not keep them forever?
    /// They'll never be fetched (date filter excludes them),
    /// so they're dead weight. Cleaning up prevents unbounded
    /// growth of the SQLite store.
    func deleteOldMessages() {
        let startOfDay = Calendar.current.startOfDay(for: Date())

        let request: NSFetchRequest<NSFetchRequestResult> = CDChatMessage.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp < %@", startOfDay as NSDate)

        let batchDelete = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try context.execute(batchDelete)
            try context.save()
        } catch {
            print("ERROR: Failed to delete old messages: \(error)")
        }
    }

    // MARK: - Save Context

    private func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("ERROR: ChatPersistenceManager save failed: \(error)")
        }
    }
}
