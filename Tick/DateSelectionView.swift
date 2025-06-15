import SwiftUI

struct DateSelectionView: View {
    @Binding var targetDate: Date
    @State private var isShowingDatePicker = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Target Date & Time")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Button(action: {
                isShowingDatePicker.toggle()
            }) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    
                    Text(dateFormatter.string(from: targetDate))
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isShowingDatePicker ? 180 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isShowingDatePicker)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            if isShowingDatePicker {
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
                        .fill(.ultraThinMaterial)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .animation(.easeInOut(duration: 0.3), value: isShowingDatePicker)
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

#Preview {
    DateSelectionView(targetDate: .constant(Date().addingTimeInterval(3600)))
        .padding()
} 