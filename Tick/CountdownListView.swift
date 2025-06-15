/*
 * CountdownListView.swift
 * 
 * PURPOSE: Main screen of the app that displays all countdown timers in a list format.
 * USED IN: ContentView - This is the primary interface users see when opening the app.
 *          Coordinates with CountdownManagerViewModel to show live countdowns and navigation to other screens.
 */

import SwiftUI

/// The main screen showing all countdown timers with live updates and management controls
/// This view serves as the home screen and navigation hub of the app
struct CountdownListView: View {
    // MARK: - State Properties
    
    /// The main data manager that handles all countdown operations
    /// @StateObject ensures this ViewModel is created once and shared across view updates
    @StateObject private var viewModel = CountdownManagerViewModel()
    
    /// Controls the visibility of the "Add New Countdown" sheet
    @State private var showingAddCountdown = false
    
    /// Holds the countdown selected for editing (triggers edit sheet when set)
    @State private var selectedCountdown: CountdownItem?
    
    /// Controls the visibility of the statistics screen
    @State private var showingStatistics = false
    
    // MARK: - Main View Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Main Content Area (Countdown List Only)
                mainContentArea
            }
            .navigationTitle("Countdowns")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
            }
            .background(appBackgroundGradient)
        }
        .sheet(isPresented: $showingAddCountdown) {
            // Sheet for creating new countdowns
            CreateEditCountdownView(viewModel: viewModel)
        }
        .sheet(item: $selectedCountdown) { countdown in
            // Sheet for editing existing countdowns
            CreateEditCountdownView(
                viewModel: viewModel,
                existingCountdown: countdown
            )
        }
        .sheet(isPresented: $showingStatistics) {
            // Sheet for viewing statistics screen
            StatisticsView(viewModel: viewModel)
        }
    }
    

    
    // MARK: - Main Content Area
    
    /// Shows either the countdown list or empty state based on data availability
    @ViewBuilder
    private var mainContentArea: some View {
        if viewModel.countdowns.isEmpty {
            emptyStateView
        } else {
            countdownList
        }
    }
    
    // MARK: - Countdown List
    
    /// The main list showing all countdowns with interactive controls
    private var countdownList: some View {
        List {
            ForEach(viewModel.countdowns) { countdown in
                CountdownRowView(
                    countdown: countdown,
                    isActive: viewModel.activeCountdowns.contains(countdown.id),
                    onTap: {
                        // Haptic feedback for expansion
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    // Enhanced swipe actions with better visual design
                    
                    // Delete button (red, destructive)
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.deleteCountdown(countdown)
                        }
                        
                        // Haptic feedback for deletion
                        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                        impactFeedback.impactOccurred()
                    } label: {
                        VStack {
                            Image(systemName: "trash.fill")
                                .font(.title3)
                            Text("Delete")
                                .font(.caption2)
                        }
                    }
                    .tint(.red)
                    
                    // Edit button (blue)
                    Button {
                        selectedCountdown = countdown
                        
                        // Haptic feedback for edit
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    } label: {
                        VStack {
                            Image(systemName: "pencil")
                                .font(.title3)
                            Text("Edit")
                                .font(.caption2)
                        }
                    }
                    .tint(.blue)
                }
                .listRowSeparator(.hidden)        // Remove default separators
                .listRowBackground(Color.clear)   // Transparent row backgrounds
                .padding(.vertical, 8)            // Increased spacing for larger rows
            }
            .onDelete(perform: viewModel.deleteCountdowns)  // Enable swipe-to-delete
        }
        .listStyle(.plain)                    // Remove default list styling
        .scrollContentBackground(.hidden)    // Make list background transparent
    }
    
    // MARK: - Empty State View
    
    /// Shown when no countdowns exist - encourages user to create their first countdown
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Large timer icon
            Image(systemName: "timer")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.6))
            
            // Explanatory text
            VStack(spacing: 8) {
                Text("No Countdowns Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Create your first countdown to get started")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Call-to-action button
            Button(action: {
                showingAddCountdown = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Countdown")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: 200)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.blue)
                )
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Toolbar Content
    
    /// Navigation bar toolbar with statistics, add button and conditional "Stop All" button
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // Statistics button (left side)
        ToolbarItem(placement: .topBarLeading) {
            Button(action: {
                showingStatistics = true
            }) {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
            }
        }
        
        // Add new countdown button (right side)
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                showingAddCountdown = true
            }) {
                Image(systemName: "plus")
                    .font(.title2)
            }
        }
        
        // "Stop All" button (only shown when countdowns are active, secondary position)
        if viewModel.activeCountdownsCount > 0 {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Stop All") {
                    withAnimation {
                        viewModel.stopAllCountdowns()
                    }
                }
                .foregroundColor(.orange)
                .font(.caption)
            }
        }
    }
    
    // MARK: - Background Styling
    
    /// Subtle gradient background for the entire screen
    private var appBackgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.05),     // Very light blue at top
                Color.purple.opacity(0.02),   // Very light purple in middle
                Color.clear                   // Transparent at bottom
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    

}



// MARK: - Preview Provider

#Preview {
    CountdownListView()
} 
