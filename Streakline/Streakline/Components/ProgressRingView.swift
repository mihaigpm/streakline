import SwiftUI

/// Dual-arc progress ring. Teal outer arc = workout progress,
/// amber inner arc = drink-budget consumption.
struct ProgressRingView: View {
    let workoutsCompleted: Int
    let workoutTarget: Int
    let drinkFraction: Double
    let isOverBudget: Bool

    private var workoutFraction: Double {
        guard workoutTarget > 0 else { return 0 }
        return min(1, Double(workoutsCompleted) / Double(workoutTarget))
    }

    private let outerLineWidth: CGFloat = 18
    private let innerLineWidth: CGFloat = 12
    private let innerInset: CGFloat = 26

    var body: some View {
        ZStack {
            // Outer track + workout arc.
            Circle()
                .stroke(DesignSystem.Colors.surfaceHigh, lineWidth: outerLineWidth)
            Circle()
                .trim(from: 0, to: workoutFraction)
                .stroke(
                    DesignSystem.Colors.teal,
                    style: StrokeStyle(lineWidth: outerLineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: DesignSystem.Colors.teal.opacity(0.5), radius: 8)

            // Inner track + pint arc.
            Circle()
                .stroke(DesignSystem.Colors.surfaceHigh, lineWidth: innerLineWidth)
                .padding(innerInset)
            Circle()
                .trim(from: 0, to: drinkFraction)
                .stroke(
                    isOverBudget ? DesignSystem.Colors.red : DesignSystem.Colors.amber,
                    style: StrokeStyle(lineWidth: innerLineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .padding(innerInset)

            centerLabel
        }
        .animation(DesignSystem.Motion.ring, value: workoutFraction)
        .animation(DesignSystem.Motion.ring, value: drinkFraction)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress")
        .accessibilityValue("\(workoutsCompleted) of \(workoutTarget) workouts done")
    }

    private var centerLabel: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text("\(workoutsCompleted)")
                .font(DesignSystem.Typography.displayLarge)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .contentTransition(.numericText())
                .animation(DesignSystem.Motion.ring, value: workoutsCompleted)
            Text("of \(workoutTarget) workouts")
                .font(DesignSystem.Typography.labelLarge)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
        }
    }
}

#Preview {
    ZStack {
        DesignSystem.Colors.background.ignoresSafeArea()
        ProgressRingView(workoutsCompleted: 2, workoutTarget: 3, drinkFraction: 0.8, isOverBudget: false)
            .frame(width: 240, height: 240)
    }
}
