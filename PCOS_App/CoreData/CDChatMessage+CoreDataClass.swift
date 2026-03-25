//
//  CDChatMessage+CoreDataClass.swift
//  PCOS_App
//

import Foundation
import CoreData

@objc(CDChatMessage)
public class CDChatMessage: NSManagedObject {

    /// Bridge to the lightweight ChatMessage struct used by the UI.
    ///
    /// Why not use CDChatMessage directly in the UI?
    /// Managed objects are tied to a Core Data context and thread.
    /// Passing them to the main-thread UI risks crashes.
    /// Converting to a plain struct is safer — same pattern as CDFoodLog.toFood().
    func toChatMessage() -> ChatMessage {
        return ChatMessage(
            text: text ?? "",
            sender: senderRaw == "user" ? .user : .ai,
            timestamp: timestamp ?? Date()
        )
    }
}
