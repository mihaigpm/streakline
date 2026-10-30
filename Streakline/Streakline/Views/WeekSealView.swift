import SwiftUI

/// The four facts of a `WeekSeal`. The navigation title is the season heading. No rank, badge grid, XP, confetti, or share action.
struct WeekSealView: View {
    let seal: WeekSeal

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    fact("Slots", value: seal.slotsText, color: DesignSystem.Colors.teal)
                    fact("Drinks", value: seal.drinksText, color: drinkColor)
                    if let money = seal.moneyNotSpentText {
                        fact("Estimate", value: money, color: DesignSystem.Colors.amber)
                    }
                    fact("Outcome", value: seal.outcomeText, color: outcomeColor)
                    if let note = seal.closingNote {
                        Text(note)
                            .font(DesignSystem.Typography.bodySmall)
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityLabel(note)
                    }
                }
                .padding(DesignSystem.Spacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle(seal.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: dismiss.callAsFunction)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var drinkColor: Color {
        seal.drinks > Double(seal.budget) ? DesignSystem.Colors.red : DesignSystem.Colors.amber
    }

    private var outcomeColor: Color {
        switch seal.outcome {
        case .perfect, .held: DesignSystem.Colors.teal
        case .shieldUsed: DesignSystem.Colors.amber
        case .missed: DesignSystem.Colors.red
        }
    }

    private func fact(_ title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(value)
                .font(DesignSystem.Typography.displaySmall)
                .foregroundStyle(color)
                .fixedSize(horizontal: false, vertical: true)
            Text(title)
                .font(DesignSystem.Typography.labelLarge)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let week = AppWeek(
        weekNumber: 4,
        startDate: .now,
        startingDrinkBudget: 10,
        drinkUnit: .pints,
        budgetRule: .guideline
    )
    let drink = DrinkLog(amount: 3)
    drink.week = week
    week.drinkLogs.append(drink)
    for day in [WorkoutDay.dayA, .dayB] {
        let log = WorkoutLog(workoutDay: day, isCompleted: true)
        log.week = week
        week.workoutLogs.append(log)
    }
    return WeekSealView(seal: WeekSeal(
        week: week,
        now: .now,
        isOpenWeek: true,
        shieldAvailable: false
    ))
}
