import SwiftUI

/// A single horizontally-scrollable workout card on the home screen.
struct WorkoutCardView: View {
    let day: WorkoutDay
    let title: String
    let subtitle: String
    let symbol: String
    let isCompleted: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Image(systemName: symbol)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(day.accentColor)
                .accessibilityHidden(true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, DesignSystem.Spacing.xl)

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                        .font(DesignSystem.Typography.headlineLarge)
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: DesignSystem.Spacing.xs)
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(DesignSystem.Colors.teal)
                            .transition(.scale.combined(with: .opacity))
                            .accessibilityHidden(true)
                    }
                }
                Text(subtitle)
                    .font(DesignSystem.Typography.bodySmall)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .frame(width: 180, alignment: .topLeading)
        .frame(minHeight: 170, alignment: .topLeading)
        .background(DesignSystem.Colors.surface, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                .strokeBorder(
                    isCompleted ? DesignSystem.Colors.teal : DesignSystem.Colors.border,
                    lineWidth: isCompleted ? 2 : 1
                )
        )
        .opacity(isCompleted ? 0.7 : 1)
        .animation(reduceMotion ? nil : DesignSystem.Motion.cardPulse, value: isCompleted)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(day.slotName), \(title), \(subtitle)")
        .accessibilityValue(isCompleted ? "Completed" : "Not done")
        .accessibilityHint("Opens workout details")
    }
}

#Preview {
    ZStack {
        DesignSystem.Colors.background.ignoresSafeArea()
        HStack {
            WorkoutCardView(
                day: .dayA,
                title: "Easy run",
                subtitle: "Steady run and glute circuit",
                symbol: "figure.run",
                isCompleted: false
            )
            WorkoutCardView(
                day: .dayB,
                title: "Full body",
                subtitle: "Weights for the whole body",
                symbol: "dumbbell.fill",
                isCompleted: true
            )
        }
    }
}
