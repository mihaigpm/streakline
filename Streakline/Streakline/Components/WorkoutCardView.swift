import SwiftUI

/// A single horizontally-scrollable workout card on the home screen.
struct WorkoutCardView: View {
    let day: WorkoutDay
    let isCompleted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Image(systemName: day.sfSymbol)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(day.accentColor)
                Spacer()
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(DesignSystem.Colors.teal)
                        .transition(.scale.combined(with: .opacity))
                }
            }

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(day.title)
                    .font(DesignSystem.Typography.headlineLarge)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                Text(day.subtitle)
                    .font(DesignSystem.Typography.bodySmall)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .frame(width: 170, height: 170, alignment: .topLeading)
        .background(DesignSystem.Colors.surface, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                .strokeBorder(
                    isCompleted ? DesignSystem.Colors.teal : DesignSystem.Colors.border,
                    lineWidth: isCompleted ? 2 : 1
                )
        )
        .opacity(isCompleted ? 0.7 : 1)
        .animation(DesignSystem.Motion.cardPulse, value: isCompleted)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(day.title), \(day.subtitle)")
        .accessibilityValue(isCompleted ? "Completed" : "Not done")
        .accessibilityHint("Opens workout details")
    }
}

#Preview {
    ZStack {
        DesignSystem.Colors.background.ignoresSafeArea()
        HStack {
            WorkoutCardView(day: .dayA, isCompleted: false)
            WorkoutCardView(day: .dayB, isCompleted: true)
        }
    }
}
