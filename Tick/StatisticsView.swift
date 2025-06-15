/*
 * StatisticsView.swift
 * 
 * PURPOSE: Dedicated screen displaying countdown statistics and overview information.
 * USED IN: Separated from CountdownListView - shows total, active, and expired countdown counts.
 *          This screen provides analytics and overview of all countdown timers in the app.
 */

import SwiftUI

/// Dedicated statistics screen showing countdown analytics and overview
/// Displays total, active, and expired countdown counts with detailed information
struct StatisticsView: View {
    // MARK: - Properties
    
    /// The countdown manager that provides statistics data
    @ObservedObject var viewModel: CountdownManagerViewModel
    
    // MARK: - Main View Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // MARK: - Main Statistics Cards
                    statisticsCardsSection
                    
                    // MARK: - Detailed Breakdown
                    if !viewModel.countdowns.isEmpty {
                        detailedBreakdownSection
                    }
                    
                    // MARK: - Quick Actions
                    quickActionsSection
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .background(appBackgroundGradient)
        }
    }
    
    // MARK: - Statistics Cards Section
    
    /// Main statistics display with large cards showing key metrics
    private var statisticsCardsSection: some View {
        VStack(spacing: 20) {
            Text("Countdown Overview")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Main statistics row
            HStack(spacing: 20) {
                // Total countdowns card
                LargeStatView(
                    title: "Total",
                    value: "\(viewModel.countdowns.count)",
                    color: .blue,
                    icon: "timer"
                )
                
                // Active countdowns card
                LargeStatView(
                    title: "Active",
                    value: "\(viewModel.activeCountdownsCount)",
                    color: .green,
                    icon: "play.circle.fill"
                )
                
                // Expired countdowns card
                LargeStatView(
                    title: "Expired",
                    value: "\(viewModel.expiredCountdowns.count)",
                    color: .red,
                    icon: "exclamationmark.triangle.fill"
                )
            }
        }
    }
    
    // MARK: - Detailed Breakdown Section
    
    /// Detailed information about countdown categories
    private var detailedBreakdownSection: some View {
        VStack(spacing: 16) {
            Text("Breakdown")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // Future countdowns info
                DetailRow(
                    title: "Future Countdowns",
                    value: "\(viewModel.futureCountdowns.count)",
                    subtitle: "Still counting down",
                    color: .blue
                )
                
                // Active countdowns info
                DetailRow(
                    title: "Running Now",
                    value: "\(viewModel.activeCountdownsCount)",
                    subtitle: "Live updates active",
                    color: .green
                )
                
                // Expired countdowns info
                DetailRow(
                    title: "Past Due",
                    value: "\(viewModel.expiredCountdowns.count)",
                    subtitle: "Target date reached",
                    color: .red
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    // MARK: - Quick Actions Section
    
    /// Quick action buttons for common operations
    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            Text("Quick Actions")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // Stop All button (only show if there are active countdowns)
                if viewModel.activeCountdownsCount > 0 {
                    QuickActionButton(
                        title: "Stop All Countdowns",
                        subtitle: "Pause all running timers",
                        icon: "pause.circle.fill",
                        color: .orange
                    ) {
                        withAnimation {
                            viewModel.stopAllCountdowns()
                        }
                        
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    }
                }
                
                // Placeholder for future actions
                if viewModel.expiredCountdowns.count > 0 {
                    QuickActionButton(
                        title: "Clean Up Expired",
                        subtitle: "Remove old countdowns",
                        icon: "trash.circle.fill",
                        color: .red
                    ) {
                        // Future implementation for bulk cleanup
                        print("Clean up expired countdowns")
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    // MARK: - Background Styling
    
    /// Consistent app background gradient
    private var appBackgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.05),
                Color.purple.opacity(0.02),
                Color.clear
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Supporting Views

/// Large statistics card for main metrics display
struct LargeStatView: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            // Value
            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            // Title
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

/// Detailed breakdown row for secondary information
struct DetailRow: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(.horizontal, 4)
    }
}

/// Quick action button for common operations
struct QuickActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primary.opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview Provider

#Preview {
    StatisticsView(viewModel: CountdownManagerViewModel())
} 