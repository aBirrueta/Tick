/*
 * CountdownItem.swift
 * 
 * PURPOSE: Data model representing a single countdown timer with a name and target date.
 * USED IN: Throughout the app - this is the core data structure for all countdown functionality.
 *          Used by CountdownManagerViewModel to store countdowns, and by all views to display countdown information.
 */

import Foundation

/// A single countdown timer with a unique identifier, name, and target date
/// This struct represents one countdown that the user has created
struct CountdownItem: Identifiable, Codable {
    // MARK: - Properties
    
    /// Unique identifier for this countdown - automatically generated
    /// SwiftUI uses this for list management and animations
    let id = UUID()
    
    /// User-provided name for this countdown (e.g., "Birthday Party", "Vacation")
    var name: String
    
    /// The date and time this countdown is counting down to
    var targetDate: Date
    
    /// Whether this countdown is currently running (updating live)
    /// Used by the UI to show play/pause state and live indicators
    var isActive: Bool = false
    
    /// When this countdown was first created
    /// Used for statistics and duration calculations in the detail view
    var createdDate: Date = Date()
    
    // MARK: - Initialization
    
    /// Creates a new countdown with a name and target date
    /// - Parameters:
    ///   - name: Display name for the countdown
    ///   - targetDate: When the countdown should reach zero
    init(name: String, targetDate: Date) {
        self.name = name
        self.targetDate = targetDate
    }
    
    // MARK: - Computed Properties
    
    /// Calculates how much time is left until the target date
    /// Returns a TimeComponents struct with days, hours, minutes, seconds, etc.
    /// This is recalculated every time it's accessed for real-time updates
    var timeRemaining: TimeComponents {
        // Calculate the difference between target date and now
        let interval = targetDate.timeIntervalSince(Date())
        
        // If target date has passed, return zero time
        // Otherwise, break down the interval into time components
        return interval > 0 ? TimeComponents(from: interval) : TimeComponents()
    }
    
    /// Checks if this countdown has already reached its target date
    /// Used to show "EXPIRED" status and disable controls
    var hasExpired: Bool {
        return targetDate <= Date()
    }
    
    /// Checks if the target date is still in the future
    /// Opposite of hasExpired - used for validation and filtering
    var isInFuture: Bool {
        return targetDate > Date()
    }
} 