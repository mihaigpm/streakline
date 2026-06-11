import SwiftUI

/// A single row in the history list summarising one week.
struct WeekRowView: View {
    let week: AppWeek
    var unit: DrinkUnit = .current

    private enum Status {
        case complete, partial, overBudget

        var color: Color {
            switch self {
            case .complete: DesignSystem.Colors.teal
            case .partial: DesignSystem.Colors.amber
            case .overBudget: DesignSystem.Colors.red
            }
        }

        var symbol: String {
            switch self {
            case .complete: "checkmark.circle.fill"
            case .partial: "circle.lefthalf.filled"
            case .overBudget: "exclamationmark.triangle.fill"
            }
        }
    }

    private var status: Status {
        if week.isOverBudget { return .overBudget }
        if week.isFullyComplete { return .complete }
        return .partial
    }

    private var dateRange: String {
        let f = Date.FormatStyle.dateTime.month(.abbreviated).day()
        return "\(week.startDate.formatted(f)) – \(week.endDate.formatted(f))"
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: status.symbol)
                .font(.system(size: 24))
                .foregroundStyle(status.color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text("Week \(week.weekNumber)")
                    .font(DesignSystem.Typography.headlineSmall)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                Text(dateRange)
                    .font(DesignSystem.Typography.labelSmall)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(week.completedWorkouts)/3 workouts")
                    .font(DesignSystem.Typography.labelLarge)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                Text("\(unit.format(week.totalDrinks))/\(week.drinkBudget) \(unit.pluralNoun)")
                    .font(DesignSystem.Typography.labelSmall)
                    .foregroundStyle(week.isOverBudget ? DesignSystem.Colors.red : DesignSystem.Colors.textSecondary)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                .strokeBorder(DesignSystem.Colors.border, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
}
