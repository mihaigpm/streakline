import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \AppWeek.weekNumber, order: .reverse) private var weeks: [AppWeek]
    @AppStorage(DrinkUnit.storageKey) private var drinkUnitRaw = DrinkUnit.pints.rawValue
    @State private var selectedWeek: AppWeek?

    private var unit: DrinkUnit { DrinkUnit(rawValue: drinkUnitRaw) ?? .pints }

    var body: some View {
        ZStack {
            DesignSystem.Colors.background.ignoresSafeArea()

            if weeks.isEmpty {
                ContentUnavailableView(
                    "No history yet",
                    systemImage: "calendar",
                    description: Text("Completed weeks will appear here.")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: DesignSystem.Spacing.md) {
                        ForEach(weeks) { week in
                            Button {
                                selectedWeek = week
                            } label: {
                                WeekRowView(week: week, unit: unit)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(DesignSystem.Spacing.lg)
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedWeek) { week in
            WeekDetailSheet(week: week, unit: unit)
                .presentationDetents([.medium, .large])
                .presentationBackground(DesignSystem.Colors.surfaceHigh)
        }
    }
}

private struct WeekDetailSheet: View {
    let week: AppWeek
    let unit: DrinkUnit

    private var completedLogs: [WorkoutLog] {
        week.workoutLogs
            .filter(\.isCompleted)
            .sorted { ($0.completedAt ?? .distantPast) < ($1.completedAt ?? .distantPast) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Week \(week.weekNumber)")
                        .font(DesignSystem.Typography.displaySmall)
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    Text(week.startDate.formatted(date: .abbreviated, time: .omitted)
                         + " – " + week.endDate.formatted(date: .abbreviated, time: .omitted))
                        .font(DesignSystem.Typography.bodySmall)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }

                HStack(spacing: DesignSystem.Spacing.md) {
                    summaryStat(value: "\(week.completedWorkouts)/3", label: "Workouts", color: DesignSystem.Colors.teal)
                    summaryStat(value: unit.format(week.totalDrinks) + "/\(week.drinkBudget)",
                                label: unit.pluralNoun.capitalized,
                                color: week.isOverBudget ? DesignSystem.Colors.red : DesignSystem.Colors.amber)
                }

                if !completedLogs.isEmpty {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Workout dates")
                            .font(DesignSystem.Typography.headlineSmall)
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                        ForEach(completedLogs) { log in
                            HStack {
                                Image(systemName: log.workoutDay.sfSymbol)
                                    .foregroundStyle(log.workoutDay.accentColor)
                                Text(log.workoutDay.title)
                                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                                Spacer()
                                if let date = log.completedAt {
                                    Text(date.formatted(date: .abbreviated, time: .shortened))
                                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                                }
                            }
                            .font(DesignSystem.Typography.bodySmall)
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func summaryStat(value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(value)
                .font(DesignSystem.Typography.displaySmall)
                .foregroundStyle(color)
            Text(label)
                .font(DesignSystem.Typography.labelLarge)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
    }
}
