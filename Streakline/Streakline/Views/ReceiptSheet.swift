import SwiftUI

/// The week's three estimate figures, and the sentence that they are not a measure of the night.
struct ReceiptSheet: View {
    let receipt: ReceiptEstimates

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text(receipt.amountText)
                        .font(DesignSystem.Typography.headlineLarge)
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    Text(receipt.spentText)
                        .font(DesignSystem.Typography.headlineSmall)
                        .foregroundStyle(DesignSystem.Colors.amber)
                    Text(receipt.calorieText)
                        .font(DesignSystem.Typography.headlineSmall)
                        .foregroundStyle(DesignSystem.Colors.amber)
                }
                Text(ReceiptEstimates.disclaimer)
                    .font(DesignSystem.Typography.bodySmall)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(DesignSystem.Colors.background)
            .navigationTitle("Estimate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: dismiss.callAsFunction)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    let week = AppWeek(
        weekNumber: 1,
        startDate: .now,
        startingDrinkBudget: 10,
        drinkUnit: .pints,
        budgetRule: .guideline
    )
    let log = DrinkLog(amount: 3)
    log.week = week
    week.drinkLogs.append(log)
    return ReceiptSheet(receipt: ReceiptEstimates(week: week))
}
