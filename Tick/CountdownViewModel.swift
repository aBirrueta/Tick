/*
 * CountdownViewModel.swift
 * 
 * PURPOSE: Original single-countdown ViewModel with high-precision time calculation utilities.
 * USED IN: Contains TimeComponents struct used throughout the app for precise time calculations.
 *          This file provides the foundation for microsecond-precision countdown timing.
 * NOTE: This was the original implementation before the multi-countdown refactor.
 */

import SwiftUI
import Foundation

/// Original ViewModel for single countdown management
/// NOTE: This is kept for TimeComponents definition used throughout the app
@MainActor
final class CountdownViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Target date for the countdown
    @Published var targetDate = Date().addingTimeInterval(3600) // Default to 1 hour from now
    
    /// Current time remaining broken down into components
    @Published var timeRemaining = TimeComponents()
    
    /// Whether countdown is currently running
    @Published var isActive = false
    
    /// Whether countdown has reached zero
    @Published var hasExpired = false
    
    // MARK: - Private Properties
    
    /// Background task for 60fps updates
    private var countdownTask: Task<Void, Never>?
    
    // MARK: - Initialization & Cleanup
    
    init() {
        updateCountdown()
    }
    
    /// Cleanup background task to prevent memory leaks
    deinit {
        countdownTask?.cancel()
        countdownTask = nil
    }
    
    // MARK: - Countdown Control Functions
    
    func startCountdown() {
        stopCountdown() // Ensure any existing task is cancelled
        isActive = true
        hasExpired = false
        
        countdownTask = Task {
            while !Task.isCancelled {
                await updateCountdown()
                
                // Update at ~60fps for smooth millisecond display
                try? await Task.sleep(nanoseconds: 16_666_667) // ~16.67ms
            }
        }
    }
    
    func stopCountdown() {
        countdownTask?.cancel()
        countdownTask = nil
        isActive = false
    }
    
    func resetCountdown() {
        stopCountdown()
        hasExpired = false
        updateCountdown()
    }
    
    private func updateCountdown() {
        let now = Date()
        let interval = targetDate.timeIntervalSince(now)
        
        if interval <= 0 {
            timeRemaining = TimeComponents()
            hasExpired = true
            if isActive {
                stopCountdown()
            }
            return
        }
        
        timeRemaining = TimeComponents(from: interval)
    }
    
    func setTargetDate(_ date: Date) {
        targetDate = date
        hasExpired = false
        updateCountdown()
    }
}

// MARK: - High-Precision Time Components

/// Structure representing time broken down into individual components with microsecond precision
/// This is the core time calculation system used throughout the app for countdown displays
struct TimeComponents {
    // MARK: - Time Component Properties
    
    /// Number of complete days remaining
    let days: Int
    
    /// Number of complete hours remaining (0-23)
    let hours: Int
    
    /// Number of complete minutes remaining (0-59)
    let minutes: Int
    
    /// Number of complete seconds remaining (0-59)
    let seconds: Int
    
    /// Number of complete milliseconds remaining (0-999)
    /// This provides high precision for smooth countdown display
    let milliseconds: Int
    
    // MARK: - Initializers
    
    /// Creates a TimeComponents with all values set to zero
    /// Used for expired countdowns or initial state
    init() {
        self.days = 0
        self.hours = 0
        self.minutes = 0
        self.seconds = 0
        self.milliseconds = 0
    }
    
    /// Creates TimeComponents from a TimeInterval with microsecond precision
    /// This is where the magic happens - breaking down a time interval into all components
    /// - Parameter timeInterval: Total seconds (with fractional seconds for sub-second precision)
    init(from timeInterval: TimeInterval) {
        let totalSeconds = timeInterval
        
        // MARK: - Days Calculation
        // 86400 seconds = 24 hours × 60 minutes × 60 seconds
        self.days = Int(totalSeconds / 86400)
        let remainingAfterDays = totalSeconds.truncatingRemainder(dividingBy: 86400)
        
        // MARK: - Hours Calculation
        // 3600 seconds = 60 minutes × 60 seconds
        self.hours = Int(remainingAfterDays / 3600)
        let remainingAfterHours = remainingAfterDays.truncatingRemainder(dividingBy: 3600)
        
        // MARK: - Minutes Calculation
        // 60 seconds = 1 minute
        self.minutes = Int(remainingAfterHours / 60)
        let remainingAfterMinutes = remainingAfterHours.truncatingRemainder(dividingBy: 60)
        
        // MARK: - Seconds Calculation
        // Extract the whole number of seconds
        self.seconds = Int(remainingAfterMinutes)
        
        // MARK: - Sub-Second Precision Calculation
        // Get the fractional part (everything after the decimal point)
        let fractionalSeconds = remainingAfterMinutes - Double(self.seconds)
        
        // Convert fractional seconds to milliseconds (multiply by 1000)
        // This gives us precision down to thousandths of a second
        self.milliseconds = Int(fractionalSeconds * 1000)
    }
    
    // MARK: - Computed Properties
    
    /// Checks if all time components are zero (countdown has expired)
    /// Used to determine if a countdown has reached its target
    var isZero: Bool {
        return days == 0 && hours == 0 && minutes == 0 && seconds == 0 && milliseconds == 0
    }
} 