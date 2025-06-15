import SwiftUI

struct CreateEditCountdownView: View {
    @ObservedObject var viewModel: CountdownManagerViewModel
    @Environment(\.dismiss) private var dismiss
    
    let existingCountdown: CountdownItem?
    
    @State private var name: String = ""
    @State private var targetDate: Date = Date().addingTimeInterval(3600)
    @State private var showingDatePicker = false
    @State private var nameError: String?
    
    private var isEditing: Bool {
        existingCountdown != nil
    }
    
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
        targetDate > Date()
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter
    }
    
    init(viewModel: CountdownManagerViewModel, existingCountdown: CountdownItem? = nil) {
        self.viewModel = viewModel
        self.existingCountdown = existingCountdown
        
        if let countdown = existingCountdown {
            _name = State(initialValue: countdown.name)
            _targetDate = State(initialValue: countdown.targetDate)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerView
                    
                    // Form
                    VStack(spacing: 20) {
                        nameInputSection
                        dateInputSection
                        
                        if !canSave {
                            validationMessage
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    
                    // Preview
                    if canSave {
                        previewSection
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(isEditing ? "Edit Countdown" : "New Countdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "Update" : "Create") {
                        saveCountdown()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
            .background(
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
            )
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: isEditing ? "pencil.circle.fill" : "plus.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text(isEditing ? "Edit Your Countdown" : "Create New Countdown")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(isEditing ? "Modify the details below" : "Set a name and target date")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top)
    }
    
    private var nameInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Countdown Name")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextField("Enter countdown name", text: $name)
                .textFieldStyle(.roundedBorder)
                .font(.body)
                .onChange(of: name) { oldValue, newValue in
                    nameError = nil
                }
            
            if let error = nameError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var dateInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Target Date & Time")
                .font(.headline)
                .foregroundColor(.primary)
            
            Button(action: {
                showingDatePicker.toggle()
            }) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    
                    Text(dateFormatter.string(from: targetDate))
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(showingDatePicker ? 180 : 0))
                        .animation(.easeInOut(duration: 0.2), value: showingDatePicker)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            if showingDatePicker {
                DatePicker(
                    "Select Date and Time",
                    selection: $targetDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.quaternary)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .animation(.easeInOut(duration: 0.3), value: showingDatePicker)
            }
        }
    }
    
    private var validationMessage: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 2) {
                if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Please enter a countdown name")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                if targetDate <= Date() {
                    Text("Target date must be in the future")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.orange.opacity(0.1))
        )
    }
    
    private var previewSection: some View {
        VStack(spacing: 12) {
            Text("Preview")
                .font(.headline)
                .foregroundColor(.primary)
            
            CountdownRowView(
                countdown: CountdownItem(name: name, targetDate: targetDate),
                isActive: false,
                onTap: {}
            )
            .disabled(true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private func saveCountdown() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            nameError = "Name cannot be empty"
            return
        }
        
        guard targetDate > Date() else {
            return
        }
        
        if let existing = existingCountdown {
            var updated = existing
            updated.name = trimmedName
            updated.targetDate = targetDate
            viewModel.updateCountdown(updated)
        } else {
            let newCountdown = CountdownItem(name: trimmedName, targetDate: targetDate)
            viewModel.addCountdown(newCountdown)
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        dismiss()
    }
}

#Preview("Create") {
    CreateEditCountdownView(viewModel: CountdownManagerViewModel())
}

#Preview("Edit") {
    CreateEditCountdownView(
        viewModel: CountdownManagerViewModel(),
        existingCountdown: CountdownItem(name: "Sample Countdown", targetDate: Date().addingTimeInterval(86400))
    )
} 
