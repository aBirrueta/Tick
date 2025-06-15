/*
 * CountdownManagerViewModel.swift
 * 
 * PURPOSE: Central data manager that handles multiple countdown timers, persistence, and live updates.
 * USED IN: Primary ViewModel for CountdownListView, CreateEditCountdownView, and DetailedCountdownView.
 *          This is the "brain" of the app that coordinates all countdown operations and state management.
 */

import SwiftUI
import Foundation

/// Main ViewModel that manages all countdown timers in the app
/// Uses @MainActor to ensure all UI updates happen on the main thread
/// Conforms to ObservableObject so SwiftUI views can automatically update when data changes
@MainActor
final class CountdownManagerViewModel: ObservableObject {
    // MARK: - Published Properties (UI automatically updates when these change)
    
    /// Array of all countdown timers created by the user
    /// SwiftUI views observe this and automatically refresh when countdowns are added/removed/modified
    @Published var countdowns: [CountdownItem] = []
    
    /// Set of countdown IDs that are currently running (showing live updates)
    /// Using Set for O(1) lookup performance when checking if a countdown is active
    @Published var activeCountdowns: Set<UUID> = []
    
    // MARK: - Private Properties
    
    /// Background task that provides smooth 60fps updates for active countdowns
    /// This runs continuously while countdowns are active to trigger UI refreshes
    private var updateTask: Task<Void, Never>?
    
    /// Key used to save/load countdowns from UserDefaults
    /// UserDefaults provides simple local storage that persists between app launches
    private let userDefaultsKey = "SavedCountdowns"
    
    // MARK: - Initialization & Cleanup
    
    /// Initializes the ViewModel by loading saved countdowns and starting the update loop
    init() {
        loadCountdowns()      // Load any previously saved countdowns
        startGlobalUpdates()  // Begin the 60fps update cycle for smooth animations
    }
    
    /// Cleanup when the ViewModel is deallocated
    /// Cancels the background update task to prevent memory leaks
    deinit {
        updateTask?.cancel()
        updateTask = nil
    }
    
    // MARK: - Countdown Management Functions
    
    /// Adds a new countdown to the list, auto-starts it, and saves to persistent storage
    /// - Parameter countdown: The new countdown to add
    func addCountdown(_ countdown: CountdownItem) {
        countdowns.append(countdown)
        
        // Auto-start the countdown immediately if it's not expired
        if countdown.isInFuture {
            startCountdown(countdown.id)
        }
        
        saveCountdowns()  // Persist to UserDefaults immediately
    }
    
    /// Updates an existing countdown with new information
    /// - Parameter countdown: The updated countdown data
    func updateCountdown(_ countdown: CountdownItem) {
        // Find the countdown by ID and replace it with the updated version
        if let index = countdowns.firstIndex(where: { $0.id == countdown.id }) {
            countdowns[index] = countdown
            saveCountdowns()  // Save changes immediately
        }
    }
    
    /// Removes a specific countdown from the list
    /// - Parameter countdown: The countdown to delete
    func deleteCountdown(_ countdown: CountdownItem) {
        // Remove from main array and active set
        countdowns.removeAll { $0.id == countdown.id }
        activeCountdowns.remove(countdown.id)
        saveCountdowns()  // Persist the deletion
    }
    
    /// Removes multiple countdowns at once (used by SwiftUI's .onDelete modifier)
    /// - Parameter offsets: IndexSet indicating which items to delete
    func deleteCountdowns(at offsets: IndexSet) {
        // Stop any active countdowns before deleting them
        for index in offsets {
            let countdown = countdowns[index]
            activeCountdowns.remove(countdown.id)
        }
        
        // Remove from array and save
        countdowns.remove(atOffsets: offsets)
        saveCountdowns()
    }
    
    // MARK: - Active Countdown Control Functions
    
    /// Starts live updates for a specific countdown
    /// - Parameter countdownId: UUID of the countdown to start
    func startCountdown(_ countdownId: UUID) {
        // Add to active set (triggers live updates)
        activeCountdowns.insert(countdownId)
        
        // Update the countdown's isActive flag for UI consistency
        if let index = countdowns.firstIndex(where: { $0.id == countdownId }) {
            countdowns[index].isActive = true
        }
    }
    
    /// Stops live updates for a specific countdown
    /// - Parameter countdownId: UUID of the countdown to stop
    func stopCountdown(_ countdownId: UUID) {
        // Remove from active set (stops live updates)
        activeCountdowns.remove(countdownId)
        
        // Update the countdown's isActive flag
        if let index = countdowns.firstIndex(where: { $0.id == countdownId }) {
            countdowns[index].isActive = false
        }
    }
    
    /// Stops all currently running countdowns at once
    /// Used by the "Stop All" button in the main interface
    func stopAllCountdowns() {
        // Clear the active set (stops all live updates)
        activeCountdowns.removeAll()
        
        // Update all countdown isActive flags to false
        for index in countdowns.indices {
            countdowns[index].isActive = false
        }
    }
    
    // MARK: - Live Update System
    
    /// Starts the background task that provides smooth 60fps updates
    /// This creates a continuous loop that triggers UI refreshes while countdowns are active
    private func startGlobalUpdates() {
        updateTask = Task {
            // Run until the task is cancelled (when ViewModel is deallocated)
            while !Task.isCancelled {
                // Only trigger UI updates if there are active countdowns
                // This saves battery and CPU when no countdowns are running
                if !activeCountdowns.isEmpty {
                    // Tell SwiftUI that our data has changed (triggers UI refresh)
                    objectWillChange.send()
                }
                
                // Wait ~16.67 milliseconds for 60fps refresh rate
                // This provides smooth millisecond and microsecond updates
                try? await Task.sleep(nanoseconds: 16_666_667)
            }
        }
    }
    
    // MARK: - Data Persistence Functions
    
    /// Saves all countdowns to UserDefaults for persistence between app launches
    /// Uses JSON encoding to convert countdown objects to storable data
    private func saveCountdowns() {
        do {
            // Convert countdown array to JSON data
            let data = try JSONEncoder().encode(countdowns)
            // Store in UserDefaults with our key
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            // Log error but don't crash the app if saving fails
            print("Failed to save countdowns: \(error)")
        }
    }
    
    /// Loads previously saved countdowns from UserDefaults
    /// If no saved data exists, creates sample countdowns for demonstration
    private func loadCountdowns() {
        // Try to get saved data from UserDefaults
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            // No saved data - create sample countdowns for first-time users
            addSampleCountdowns()
            return
        }
        
        do {
            // Decode JSON data back into countdown objects
            countdowns = try JSONDecoder().decode([CountdownItem].self, from: data)
        } catch {
            // If decoding fails, create sample data instead
            print("Failed to load countdowns: \(error)")
            addSampleCountdowns()
        }
    }
    
    /// Creates sample countdown data for first-time app users or when loading fails
    /// Provides example countdowns to demonstrate the app's functionality
    private func addSampleCountdowns() {
        let sampleCountdowns = [
            // New Year countdown - demonstrates long-term countdown
            CountdownItem(name: "New Year 2026", targetDate: Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 1)) ?? Date().addingTimeInterval(86400)),
            
            // Short-term countdown - demonstrates hours/minutes display
            CountdownItem(name: "Lunch Break", targetDate: Date().addingTimeInterval(3600))
        ]
        
        countdowns = sampleCountdowns
        saveCountdowns()  // Immediately save the sample data
    }
    
    // MARK: - Computed Properties for UI
    
    /// Returns the number of currently active (running) countdowns
    /// Used by the UI to show statistics and determine when to show "Stop All" button
    var activeCountdownsCount: Int {
        activeCountdowns.count
    }
    
    /// Returns all countdowns that have passed their target date
    /// Used for statistics display in the header
    var expiredCountdowns: [CountdownItem] {
        countdowns.filter { $0.hasExpired }
    }
    
    /// Returns all countdowns that still have time remaining
    /// Used for filtering and statistics
    var futureCountdowns: [CountdownItem] {
        countdowns.filter { $0.isInFuture }
    }
} 
