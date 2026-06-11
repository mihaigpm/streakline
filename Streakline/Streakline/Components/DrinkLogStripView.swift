import SwiftUI

/// Compact drink counter at the bottom of the home screen.
/// Background shifts amber over 70% of budget, red when over budget.
/// Also shows the week's dry-day dots: teal = dry, amber = drank, outlined = today.
struct DrinkLogStripView: View {
    let total: Double
    let budget: Int
    let unit: DrinkUnit
    let dayStates: [Gamification.DayDrinkState]
    let onAdd: () -> Void
    let onSubtract: () -> Void

    private var fraction: Double {
        guard budget > 0 else { return 0 }
        return total / Double(budget)
    }

    private var tint: Color {
        if fraction > 1 { DesignSystem.Colors.red }
        else if fraction > 0.7 { DesignSystem.Colors.amber }
        else { DesignSystem.Colors.surface }
    }

    private var fill: Color {
        if fraction > 1 { DesignSystem.Colors.red.opacity(0.18) }
        else if fraction > 0.7 { DesignSystem.Colors.amberDim }
        else { DesignSystem.Colors.surface }
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "mug.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(fraction > 0.7 ? DesignSystem.Colors.amber : DesignSystem.Colors.textSecondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(totalLabel)
                        .font(DesignSystem.Typography.headlineSmall)
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                        .contentTransition(.numericText())
                    Text("\(budget) \(unit.pluralNoun) budget")
                        .font(DesignSystem.Typography.labelSmall)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }

                Spacer()

                HStack(spacing: DesignSystem.Spacing.sm) {
                    stepperButton(systemName: "minus", action: onSubtract)
                        .disabled(total <= 0)
                        .opacity(total <= 0 ? 0.4 : 1)
                    stepperButton(systemName: "plus", action: onAdd)
                }
            }

            dryDayDots
        }
        .padding(DesignSystem.Spacing.md)
        .background(fill, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                .strokeBorder(tint == DesignSystem.Colors.surface ? DesignSystem.Colors.border : tint, lineWidth: 1)
        )
        .animation(DesignSystem.Motion.ring, value: total)
    }

    private var totalLabel: String {
        "\(unit.format(total)) \(unit.noun(for: total)) this week"
    }

    private var dryCount: Int {
        dayStates.filter { $0 == .dry }.count
    }

    private var dryDayDots: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(Array(dayStates.enumerated()), id: \.offset) { _, state in
                dot(for: state)
            }
            Spacer()
            Text("\(dryCount) dry \(dryCount == 1 ? "day" : "days")")
                .font(DesignSystem.Typography.labelSmall)
                .foregroundStyle(dryCount > 0 ? DesignSystem.Colors.teal : DesignSystem.Colors.textTertiary)
                .contentTransition(.numericText())
        }
        .animation(DesignSystem.Motion.ring, value: dryCount)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(dryCount) dry days this week")
    }

    @ViewBuilder
    private func dot(for state: Gamification.DayDrinkState) -> some View {
        switch state {
        case .dry:
            Circle().fill(DesignSystem.Colors.teal).frame(width: 9, height: 9)
        case .drank:
            Circle().fill(DesignSystem.Colors.amber).frame(width: 9, height: 9)
        case .today:
            Circle()
                .strokeBorder(DesignSystem.Colors.teal, lineWidth: 1.5)
                .frame(width: 9, height: 9)
        case .future:
            Circle().fill(DesignSystem.Colors.surfaceHigh).frame(width: 9, height: 9)
        }
    }

    private func stepperButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .frame(width: 40, height: 40)
                .background(DesignSystem.Colors.surfaceHigh, in: Circle())
        }
        .accessibilityLabel(systemName == "plus" ? "Add \(unit.format(unit.step)) \(unit.noun(for: unit.step))" : "Remove \(unit.format(unit.step)) \(unit.noun(for: unit.step))")
    }
}

#Preview {
    ZStack {
        DesignSystem.Colors.background.ignoresSafeArea()
        VStack {
            DrinkLogStripView(
                total: 2, budget: 8, unit: .pints,
                dayStates: [.dry, .dry, .drank, .today, .future, .future, .future],
                onAdd: {}, onSubtract: {}
            )
            DrinkLogStripView(
                total: 7, budget: 8, unit: .units,
                dayStates: [.drank, .drank, .dry, .today, .future, .future, .future],
                onAdd: {}, onSubtract: {}
            )
            DrinkLogStripView(
                total: 9, budget: 8, unit: .drinks,
                dayStates: [.drank, .drank, .drank, .today, .future, .future, .future],
                onAdd: {}, onSubtract: {}
            )
        }
        .padding()
    }
}
