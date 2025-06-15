/*
 * CountdownControlsView.swift
 * 
 * PURPOSE: Control buttons for starting, pausing, and resetting countdown timers.
 * USED IN: CountdownDisplayView, DetailedCountdownView - provides interactive controls for countdown management.
 *          This reusable component handles the play/pause/reset functionality with proper state management.
 */

import SwiftUI

/// Interactive control buttons for managing countdown timer state
/// Provides start/pause toggle and reset functionality with visual feedback
struct CountdownControlsView: View {
    // MARK: - Properties
    
    /// Whether the countdown is currently running
    let isActive: Bool
    
    /// Whether the countdown has expired (affects button availability)
    let hasExpired: Bool
    
    /// Callback function to start the countdown
    let onStart: () -> Void
    
    /// Callback function to pause/stop the countdown
    let onStop: () -> Void
    
    /// Callback function to reset the countdown
    let onReset: () -> Void
    
    // MARK: - Main View Body
    
    var body: some View {
        HStack(spacing: 20) {
            // MARK: - Start/Pause Button (Primary Control)
            startStopButton
            
            // MARK: - Reset Button (Secondary Control)
            resetButton
        }
        .padding(.horizontal)
    }
    
    // MARK: - Start/Stop Button Component
    
    /// Primary control button that toggles between start and pause
    /// Changes appearance and behavior based on current countdown state
    private var startStopButton: some View {
        Button(action: handleStartStopTap) {
            HStack(spacing: 8) {
                // Dynamic icon based on current state
                Image(systemName: startStopIconName)
                    .font(.title2)
                
                // Dynamic text based on current state
                Text(startStopButtonText)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(startStopBackgroundView)
            .foregroundColor(.white)
            .scaleEffect(buttonScaleEffect)  // Visual feedback for active state
            .animation(.easeInOut(duration: 0.1), value: isActive)
        }
        .disabled(hasExpired)  // Can't start expired countdowns
        .opacity(hasExpired ? 0.6 : 1.0)  // Visual indication when disabled
    }
    
    // MARK: - Reset Button Component
    
    /// Secondary button for resetting the countdown state
    /// Always available regardless of countdown state
    private var resetButton: some View {
        Button(action: onReset) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
                
                Text("Reset")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(resetBackgroundView)
            .foregroundColor(.white)
        }
    }
    
    // MARK: - Computed Properties for Dynamic Styling
    
    /// Icon name that changes based on current countdown state
    private var startStopIconName: String {
        isActive ? "pause.fill" : "play.fill"
    }
    
    /// Button text that changes based on current countdown state
    private var startStopButtonText: String {
        isActive ? "Pause" : "Start"
    }
    
    /// Background color that changes based on current countdown state
    /// Green for start, orange for pause
    private var startStopBackgroundView: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(isActive ? Color.orange : Color.green)
    }
    
    /// Scale effect that provides visual feedback when countdown is active
    /// Slightly smaller scale when active to indicate "pressed" state
    private var buttonScaleEffect: CGFloat {
        isActive ? 0.95 : 1.0
    }
    
    /// Consistent blue background for the reset button
    private var resetBackgroundView: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(Color.blue)
    }
    
    // MARK: - Action Handlers
    
    /// Handles the start/stop button tap with appropriate action based on current state
    private func handleStartStopTap() {
        if isActive {
            onStop()    // Currently running - pause it
        } else {
            onStart()   // Currently paused - start it
        }
    }
}

// MARK: - Preview Provider

#Preview {
    VStack(spacing: 20) {
        // Preview showing different button states
        
        // Paused state (ready to start)
        CountdownControlsView(
            isActive: false,
            hasExpired: false,
            onStart: {},
            onStop: {},
            onReset: {}
        )
        
        // Active state (running, can pause)
        CountdownControlsView(
            isActive: true,
            hasExpired: false,
            onStart: {},
            onStop: {},
            onReset: {}
        )
        
        // Expired state (disabled start button)
        CountdownControlsView(
            isActive: false,
            hasExpired: true,
            onStart: {},
            onStop: {},
            onReset: {}
        )
    }
    .padding()
} 