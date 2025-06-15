import SwiftUI

struct DetailedCountdownView: View {
    let countdown: CountdownItem
    @ObservedObject var viewModel: CountdownManagerViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var isActive: Bool {
        viewModel.activeCountdowns.contains(countdown.id)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Text(countdown.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("Target: \(dateFormatter.string(from: countdown.targetDate))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Full Precision Display
                    CountdownDisplayView(
                        timeComponents: countdown.timeRemaining,
                        hasExpired: countdown.hasExpired
                    )
                    
                    // Controls
                    CountdownControlsView(
                        isActive: isActive,
                        hasExpired: countdown.hasExpired,
                        onStart: {
                            viewModel.startCountdown(countdown.id)
                            // Add haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                        },
                        onStop: {
                            viewModel.stopCountdown(countdown.id)
                            // Add haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        },
                        onReset: {
                            // For individual countdowns, reset just stops the timer
                            viewModel.stopCountdown(countdown.id)
                            // Add haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .rigid)
                            impactFeedback.impactOccurred()
                        }
                    )
                    
                    // Status Info
                    if isActive {
                        VStack(spacing: 8) {
                            HStack {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(1.5)
                                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isActive)
                                
                                Text("Live countdown active")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("Updating at ~60fps for smooth precision")
                                .font(.caption2)
                                .foregroundColor(.secondary.opacity(0.7))
                        }
                    }
                    
                    // Time Information
                    timeInfoSection
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.05),
                        Color.clear
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
    }
    
    private var timeInfoSection: some View {
        VStack(spacing: 16) {
            Text("Time Details")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                TimeInfoRow(
                    title: "Created",
                    value: formatDate(countdown.createdDate),
                    icon: "plus.circle"
                )
                
                TimeInfoRow(
                    title: "Target",
                    value: formatDate(countdown.targetDate),
                    icon: "target"
                )
                
                if !countdown.hasExpired {
                    TimeInfoRow(
                        title: "Total Duration",
                        value: formatDuration(countdown.targetDate.timeIntervalSince(countdown.createdDate)),
                        icon: "clock"
                    )
                    
                    TimeInfoRow(
                        title: "Remaining",
                        value: formatDuration(countdown.targetDate.timeIntervalSince(Date())),
                        icon: "hourglass"
                    )
                } else {
                    TimeInfoRow(
                        title: "Expired",
                        value: formatDuration(abs(countdown.targetDate.timeIntervalSince(Date()))) + " ago",
                        icon: "exclamationmark.triangle"
                    )
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ timeInterval: TimeInterval) -> String {
        let components = TimeComponents(from: timeInterval)
        
        if components.days > 0 {
            return "\(components.days) days, \(components.hours) hours"
        } else if components.hours > 0 {
            return "\(components.hours) hours, \(components.minutes) minutes"
        } else {
            return "\(components.minutes) minutes, \(components.seconds) seconds"
        }
    }
}

struct TimeInfoRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    DetailedCountdownView(
        countdown: CountdownItem(name: "Weekend Trip", targetDate: Date().addingTimeInterval(86400 * 2)),
        viewModel: CountdownManagerViewModel()
    )
} 