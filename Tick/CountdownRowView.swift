/*
 * CountdownRowView.swift
 * 
 * PURPOSE: Enhanced countdown row with integrated precision display and expandable time details.
 * USED IN: CountdownListView - shows detailed countdown information in an expandable format.
 *          Each row now includes precision timing and expandable time details without manual controls.
 */

import SwiftUI

/// Enhanced countdown row that displays live precision timing and expandable details
/// Auto-running countdowns with integrated time details and improved swipe actions
struct CountdownRowView: View {
    // MARK: - Properties
    
    /// The countdown data to display
    let countdown: CountdownItem
    
    /// Whether this countdown is currently running (from parent ViewModel)
    let isActive: Bool
    
    /// Callback function to handle row tap (expands time details)
    let onTap: () -> Void
    
    /// Whether time details are expanded for this row
    @State private var isExpanded = false
    
    // MARK: - Computed Properties for Real-Time Data
    
    /// Gets the current time remaining, recalculated each time the view updates
    private var timeComponents: TimeComponents {
        countdown.timeRemaining
    }
    
    /// Checks if this countdown has expired (target date has passed)
    private var hasExpired: Bool {
        countdown.hasExpired
    }
    
    /// Date formatter for displaying dates in a readable format
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    // MARK: - Main View Body
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Main Row Content
            mainRowContent
            
            // MARK: - Expandable Time Details
            if isExpanded {
                timeDetailsSection
                    .transition(.opacity.combined(with: .slide))
            }
        }
        .background(rowBackgroundView)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded.toggle()
            }
            onTap()
        }
    }
    
    // MARK: - Main Row Content
    
    /// The main visible content of the countdown row
    private var mainRowContent: some View {
        VStack(spacing: 12) {
            // MARK: - Header Section (Name + Status)
            headerSection
            
            // MARK: - Countdown Display Section
            if hasExpired {
                expiredDisplaySection
            } else {
                precisionCountdownSection
            }
            
            // MARK: - Target Information
            targetInfoSection
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Header Section
    
    /// Header with countdown name and status indicator
    private var headerSection: some View {
        HStack {
            // Countdown name
            Text(countdown.name)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            // Status indicator and expand chevron
            HStack(spacing: 8) {
                statusIndicator
                
                // Expand/collapse chevron
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.easeInOut(duration: 0.3), value: isExpanded)
            }
        }
    }
    
    // MARK: - Status Indicator
    
    /// Visual status indicator for countdown state
    private var statusIndicator: some View {
        Group {
            if hasExpired {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            } else if isActive {
                Circle()
                    .fill(.green)
                    .frame(width: 10, height: 10)
                    .scaleEffect(1.2)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isActive)
            } else {
                Circle()
                    .fill(.gray.opacity(0.4))
                    .frame(width: 10, height: 10)
            }
        }
    }
    
    // MARK: - Expired Display Section
    
    /// Large "TIME'S UP!" display for expired countdowns
    private var expiredDisplaySection: some View {
        VStack(spacing: 8) {
            Text("TIME'S UP!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.red)
                .scaleEffect(1.05)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: hasExpired)
            
            Text("Expired \(timeAgoText)")
                .font(.caption)
                .foregroundColor(.red.opacity(0.8))
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Precision Countdown Section
    
    /// Compact precision countdown display with all time units
    private var precisionCountdownSection: some View {
        VStack(spacing: 8) {
            // Major time units (Days, Hours, Minutes, Seconds)
            HStack(spacing: 16) {
                if timeComponents.days > 0 {
                    compactTimeUnit(value: timeComponents.days, unit: "d")
                }
                if timeComponents.hours > 0 || timeComponents.days > 0 {
                    compactTimeUnit(value: timeComponents.hours, unit: "h")
                }
                compactTimeUnit(value: timeComponents.minutes, unit: "m")
                compactTimeUnit(value: timeComponents.seconds, unit: "s")
            }
            
            // Precision unit (Milliseconds only)
            if timeComponents.days == 0 && timeComponents.hours == 0 {
                Text("\(timeComponents.milliseconds)ms")
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(.primary.opacity(0.1))
                    )
            }
        }
    }
    
    // MARK: - Target Information Section
    
    /// Shows target date and time information
    private var targetInfoSection: some View {
        HStack {
            Image(systemName: "target")
                .font(.caption)
                .foregroundColor(.blue)
            
            Text("Target: \(dateFormatter.string(from: countdown.targetDate))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if isActive {
                Text("LIVE")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(.green.opacity(0.2))
                    )
            }
        }
    }
    
    // MARK: - Expandable Time Details Section
    
    /// Detailed time information section (expandable)
    private var timeDetailsSection: some View {
        VStack(spacing: 12) {
            Divider()
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                Text("Time Details")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                VStack(spacing: 6) {
                    timeDetailRow(
                        icon: "plus.circle",
                        title: "Created",
                        value: formatDate(countdown.createdDate),
                        color: .blue
                    )
                    
                    timeDetailRow(
                        icon: "target",
                        title: "Target",
                        value: formatDate(countdown.targetDate),
                        color: .blue
                    )
                    
                    if hasExpired {
                        timeDetailRow(
                            icon: "exclamationmark.triangle",
                            title: "Expired",
                            value: timeAgoText + " ago",
                            color: .red
                        )
                    } else {
                        timeDetailRow(
                            icon: "clock",
                            title: "Total Duration",
                            value: formatDuration(countdown.targetDate.timeIntervalSince(countdown.createdDate)),
                            color: .green
                        )
                        
                        timeDetailRow(
                            icon: "hourglass",
                            title: "Remaining",
                            value: formatDuration(countdown.targetDate.timeIntervalSince(Date())),
                            color: .orange
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Helper Views
    
    /// Compact time unit display for major time components
    private func compactTimeUnit(value: Int, unit: String) -> some View {
        HStack(spacing: 2) {
            Text("\(value)")
                .font(.system(.title3, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(unit)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.primary.opacity(0.08))
        )
    }
    
    /// Individual row in the time details section
    private func timeDetailRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
                .frame(width: 16)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Row Background Styling
    
    /// Enhanced background with better visual hierarchy
    private var rowBackgroundView: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .stroke(strokeColor, lineWidth: strokeWidth)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    /// Dynamic stroke color based on countdown state
    private var strokeColor: Color {
        if hasExpired {
            return .red.opacity(0.3)
        } else if isActive {
            return .blue.opacity(0.4)
        } else {
            return .clear
        }
    }
    
    /// Dynamic stroke width based on countdown state
    private var strokeWidth: CGFloat {
        (hasExpired || isActive) ? 1 : 0
    }
    
    // MARK: - Helper Functions
    
    /// Formats duration into human-readable text
    private func formatDuration(_ timeInterval: TimeInterval) -> String {
        let components = TimeComponents(from: abs(timeInterval))
        
        if components.days > 0 {
            return "\(components.days) days, \(components.hours) hours"
        } else if components.hours > 0 {
            return "\(components.hours) hours, \(components.minutes) minutes"
        } else {
            return "\(components.minutes) minutes, \(components.seconds) seconds"
        }
    }
    
    /// Formats date for display
    private func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    /// Calculates how long ago the countdown expired
    private var timeAgoText: String {
        let interval = abs(countdown.targetDate.timeIntervalSince(Date()))
        return formatDuration(interval)
    }
}

// MARK: - Preview Provider

#Preview {
    VStack(spacing: 16) {
        // Active countdown
        CountdownRowView(
            countdown: CountdownItem(name: "Weekend Trip", targetDate: Date().addingTimeInterval(86400 * 2)),
            isActive: true,
            onTap: {}
        )
        
        // Short countdown
        CountdownRowView(
            countdown: CountdownItem(name: "Meeting", targetDate: Date().addingTimeInterval(1800)),
            isActive: true,
            onTap: {}
        )
        
        // Expired countdown
        CountdownRowView(
            countdown: CountdownItem(name: "Past Event", targetDate: Date().addingTimeInterval(-3600)),
            isActive: false,
            onTap: {}
        )
    }
    .padding()
} 