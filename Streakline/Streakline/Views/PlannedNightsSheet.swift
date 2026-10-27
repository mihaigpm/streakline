import SwiftUI

/// Places this week's drink budget on nights. A saved plan is a placement, not a lock on logging.
struct PlannedNightsSheet: View {
    let week: AppWeek
    let onPersist: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var amounts: [Double]
    @State private var refusal: String?

    init(week: AppWeek, onPersist: @escaping () -> Void) {
        self.week = week
        self.onPersist = onPersist
        _amounts = State(initialValue: week.plannedAmounts)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    header
                    nights
                    Button("Reset to weekend", action: reset)
                        .font(DesignSystem.Typography.labelLarge)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, DesignSystem.Spacing.sm)
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Plan nights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: dismiss.callAsFunction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(leftToPlace)
                .font(DesignSystem.Typography.headlineSmall)
                .foregroundStyle(DesignSystem.Colors.amber)
            Text("Place the budget on the nights you drink. A drink still logs on any night.")
                .font(DesignSystem.Typography.bodySmall)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            if let refusal {
                Text(refusal)
                    .font(DesignSystem.Typography.labelLarge)
                    .foregroundStyle(DesignSystem.Colors.amber)
                    .accessibilityAddTraits(.updatesFrequently)
            }
        }
    }

    private var nights: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(0..<7, id: \.self) { index in
                PlannedNightRow(
                    name: dayName(offset: index),
                    amount: amounts[index],
                    unit: week.drinkUnit,
                    onDecrease: { change(night: index, by: -week.drinkUnit.step) },
                    onIncrease: { change(night: index, by: week.drinkUnit.step) }
                )
            }
        }
    }

    private var leftToPlace: String {
        let left = max(0, Double(week.drinkBudget) - amounts.reduce(0, +))
        return week.planLimitMessage(unplaced: left)
    }

    private func dayName(offset: Int) -> String {
        let day = Calendar.current.date(byAdding: .day, value: offset, to: week.startDate) ?? week.startDate
        return day.formatted(.dateTime.weekday(.wide))
    }

    private func change(night: Int, by delta: Double) {
        let adjustment = week.adjusting(amounts, by: delta, onNight: night)
        if let unplaced = adjustment.refusedUnplaced {
            let message = "That's the whole budget. \(week.planLimitMessage(unplaced: unplaced))"
            refusal = message
            AccessibilityNotification.Announcement(message).post()
            return
        }
        refusal = nil
        amounts = adjustment.amounts
    }

    private func save() {
        week.saveCustomPlan(amounts)
        let saved = week.planCustomized && zip(week.plannedAmounts, amounts).allSatisfy { abs($0 - $1) < 0.000_001 }
        guard saved else {
            let left = max(0, Double(week.drinkBudget) - amounts.reduce(0, +))
            let message = "That's the whole budget. \(week.planLimitMessage(unplaced: left))"
            refusal = message
            AccessibilityNotification.Announcement(message).post()
            return
        }
        onPersist()
        dismiss()
    }

    private func reset() {
        week.resetPlanToWeekend()
        amounts = week.plannedAmounts
        refusal = nil
        onPersist()
    }
}

/// One night in the plan sheet. Minus stops at zero. Plus refuses a step past the weekly budget.
private struct PlannedNightRow: View {
    let name: String
    let amount: Double
    let unit: DrinkUnit
    let onDecrease: () -> Void
    let onIncrease: () -> Void

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Text(name)
                .font(DesignSystem.Typography.labelLarge)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            Spacer()
            stepButton(systemName: "minus", label: "Remove \(stepLabel) on \(name)", action: onDecrease)
                .disabled(amount <= 0)
                .opacity(amount <= 0 ? 0.4 : 1)
            Text("\(unit.format(amount)) \(unit.noun(for: amount))")
                .font(DesignSystem.Typography.labelLarge)
                .foregroundStyle(amount > 0 ? DesignSystem.Colors.amber : DesignSystem.Colors.textSecondary)
                .frame(minWidth: 88)
            stepButton(systemName: "plus", label: "Add \(stepLabel) on \(name)", action: onIncrease)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(DesignSystem.Colors.surface, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
        .accessibilityElement(children: .contain)
    }

    private var stepLabel: String {
        "\(unit.format(unit.step)) \(unit.noun(for: unit.step))"
    }

    private func stepButton(systemName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .frame(width: 44, height: 44)
                .background(DesignSystem.Colors.surfaceHigh, in: Circle())
        }
        .accessibilityLabel(label)
    }
}

#Preview {
    PlannedNightsSheet(
        week: AppWeek(
            weekNumber: 1,
            startDate: .now,
            startingDrinkBudget: 7,
            drinkUnit: .pints,
            budgetRule: .guideline
        ),
        onPersist: {}
    )
}
