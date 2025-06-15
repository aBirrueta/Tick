/*
 * CountdownDisplayView.swift
 * 
 * PURPOSE: High-precision countdown display showing days, hours, minutes, seconds, milliseconds, and microseconds.
 * USED IN: Original single-countdown ContentView and DetailedCountdownView for full precision timer display.
 *          This is the core visual component that shows the beautiful, animated countdown with all time units.
 */

import SwiftUI

/// The main countdown display that shows all time components with high precision
/// This view handles both normal countdown display and expired state animations
struct CountdownDisplayView: View {
    // MARK: - Properties
    
    /// The time remaining broken down into individual components
    let timeComponents: TimeComponents
    
    /// Whether this countdown has reached zero (triggers special expired animation)
    let hasExpired: Bool
    
    // MARK: - Main View Body
    
    var body: some View {
        VStack(spacing: 20) {
            if hasExpired {
                // MARK: - Expired State Display
                expiredStateView
            } else {
                // MARK: - Active Countdown Display
                activeCountdownView
            }
        }
        .padding()
        .background(countdownBackgroundView)
    }
    
    // MARK: - Expired State Component
    
    /// Animated "TIME'S UP!" display shown when countdown reaches zero
    private var expiredStateView: some View {
        Text("TIME'S UP!")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.red)
            .scaleEffect(1.1)
            // Pulsing animation to draw attention to expiration
            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: hasExpired)
    }
    
    // MARK: - Active Countdown Display
    
    /// The main countdown display showing all time components in organized sections
    private var activeCountdownView: some View {
        VStack(spacing: 16) {
            // MARK: - Major Time Units (Days & Hours)
            majorTimeUnitsRow
            
            // MARK: - Medium Time Units (Minutes & Seconds)
            mediumTimeUnitsRow
            
            // MARK: - Precision Time Units (Milliseconds & Microseconds)
            precisionTimeUnitsRow
        }
    }
    
    // MARK: - Time Unit Rows
    
    /// Top row showing days and hours (largest time units)
    private var majorTimeUnitsRow: some View {
        HStack(spacing: 24) {
            TimeUnitView(
                value: timeComponents.days,
                unit: "DAYS",
                isLarge: true
            )
            
            TimeUnitView(
                value: timeComponents.hours,
                unit: "HOURS",
                isLarge: true
            )
        }
    }
    
    /// Middle row showing minutes and seconds (medium time units)
    private var mediumTimeUnitsRow: some View {
        HStack(spacing: 24) {
            TimeUnitView(
                value: timeComponents.minutes,
                unit: "MINUTES",
                isLarge: true
            )
            
            TimeUnitView(
                value: timeComponents.seconds,
                unit: "SECONDS",
                isLarge: true
            )
        }
    }
    
    /// Bottom row showing milliseconds (high precision units)
    private var precisionTimeUnitsRow: some View {
        HStack(spacing: 24) {
            TimeUnitView(
                value: timeComponents.milliseconds,
                unit: "MILLISECONDS",
                isLarge: false  // Smaller display for precision units
            )
        }
    }
    
    // MARK: - Background Styling
    
    /// Translucent background with shadow for the entire countdown display
    private var countdownBackgroundView: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)  // Adapts to light/dark mode automatically
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Supporting Views

/// Individual time unit display (e.g., "5 MINUTES", "123 MILLISECONDS")
/// This reusable component handles both large and small time unit displays
struct TimeUnitView: View {
    // MARK: - Properties
    
    /// The numeric value to display
    let value: Int
    
    /// The unit label (e.g., "DAYS", "MILLISECONDS")
    let unit: String
    
    /// Whether this should use large formatting (for major time units)
    let isLarge: Bool
    
    // MARK: - View Body
    
    var body: some View {
        VStack(spacing: 4) {
            // MARK: - Numeric Value Display
            Text("\(value)")
                .font(numberFont)
                .foregroundColor(.primary)
                .frame(minWidth: numberFrameWidth)
            
            // MARK: - Unit Label
            Text(unit)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, horizontalPadding)
        .background(unitBackgroundView)
    }
    
    // MARK: - Computed Styling Properties
    
    /// Font size and weight based on whether this is a major or precision time unit
    private var numberFont: Font {
        if isLarge {
            // Large, bold font for major time units (days, hours, minutes, seconds)
            return .system(size: 32, weight: .bold, design: .monospaced)
        } else {
            // Smaller font for precision time units (milliseconds, microseconds)
            return .system(size: 24, weight: .semibold, design: .monospaced)
        }
    }
    
    /// Minimum width for consistent alignment across different number sizes
    private var numberFrameWidth: CGFloat {
        isLarge ? 80 : 60
    }
    
    /// Horizontal padding adjusted for unit size
    private var horizontalPadding: CGFloat {
        isLarge ? 12 : 8
    }
    
    /// Background styling for individual time unit containers
    private var unitBackgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.primary.opacity(0.05))  // Very subtle background tint
    }
}

// MARK: - Preview Provider

#Preview {
    CountdownDisplayView(
        timeComponents: TimeComponents(from: 356425.123456),  // ~4 days, 3 hours sample
        hasExpired: false
    )
    .padding()
}

#Preview("Expired") {
    CountdownDisplayView(
        timeComponents: TimeComponents(),  // All zeros
        hasExpired: true
    )
    .padding()
} 