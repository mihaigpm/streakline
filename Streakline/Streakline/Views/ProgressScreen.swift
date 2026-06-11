import SwiftUI
import SwiftData

/// Rank, XP, lifetime stats, and badges — the gamification hub.
struct ProgressScreen: View {
    @Query(sort: \AppWeek.weekNumber, order: .reverse) private var weeks: [AppWeek]

    private var summary: Gamification.Summary {
        Gamification.summary(for: weeks)
    }

    private let badgeColumns = [
        GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
        GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
        GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
    ]

    var body: some View {
        ZStack {
            DesignSystem.Colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    rankHero
                    statsRow
                    xpLegend
                    badgesGrid
                }
                .padding(DesignSystem.Spacing.lg)
            }
        }
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Rank hero

    private var rankHero: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .stroke(DesignSystem.Colors.surfaceHigh, lineWidth: 14)
                Circle()
                    .trim(from: 0, to: summary.progressToNextRank)
                    .stroke(
                        DesignSystem.Colors.teal,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: DesignSystem.Colors.teal.opacity(0.45), radius: 8)

                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text("\(summary.xp)")
                        .font(DesignSystem.Typography.displayMedium)
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                        .contentTransition(.numericText())
                    Text("XP")
                        .font(DesignSystem.Typography.labelLarge)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
            }
            .frame(width: 180, height: 180)
            .animation(DesignSystem.Motion.ring, value: summary.progressToNextRank)

            Text(summary.rank.name)
                .font(DesignSystem.Typography.displaySmall)
                .foregroundStyle(DesignSystem.Colors.teal)

            if let next = summary.nextRank, let remaining = summary.xpToNextRank {
                Text("\(remaining) XP to \(next.name)")
                    .font(DesignSystem.Typography.labelLarge)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            } else {
                Text("Top rank reached")
                    .font(DesignSystem.Typography.labelLarge)
                    .foregroundStyle(DesignSystem.Colors.amber)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rank \(summary.rank.name), \(summary.xp) XP")
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            statCard(value: "\(summary.totalWorkouts)", label: "Workouts", symbol: "dumbbell.fill", color: DesignSystem.Colors.teal)
            statCard(value: "\(summary.totalDryDays)", label: "Dry days", symbol: "drop.fill", color: DesignSystem.Colors.teal)
            statCard(value: "\(summary.bestStreak)", label: "Best streak", symbol: "flame.fill", color: DesignSystem.Colors.amber)
        }
    }

    private func statCard(value: String, label: String, symbol: String, color: Color) -> some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: symbol)
                .font(.system(size: 16))
                .foregroundStyle(color)
            Text(value)
                .font(DesignSystem.Typography.displaySmall)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            Text(label)
                .font(DesignSystem.Typography.labelSmall)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                .strokeBorder(DesignSystem.Colors.border, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }

    // MARK: - XP legend

    private var xpLegend: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("How you earn XP")
                .font(DesignSystem.Typography.headlineSmall)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            legendRow(symbol: "checkmark.circle.fill", text: "Tick off an exercise", xp: "+10")
            legendRow(symbol: "dumbbell.fill", text: "Complete a workout", xp: "+50")
            legendRow(symbol: "drop.fill", text: "Stay dry for a day", xp: "+15")
            legendRow(symbol: "checkmark.seal.fill", text: "Finish a perfect week", xp: "+150")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                .strokeBorder(DesignSystem.Colors.border, lineWidth: 1)
        )
    }

    private func legendRow(symbol: String, text: String, xp: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: symbol)
                .font(.system(size: 13))
                .foregroundStyle(DesignSystem.Colors.teal)
                .frame(width: 20)
            Text(text)
                .font(DesignSystem.Typography.bodySmall)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
            Spacer()
            Text(xp)
                .font(DesignSystem.Typography.labelLarge)
                .foregroundStyle(DesignSystem.Colors.teal)
        }
    }

    // MARK: - Badges

    private var badgesGrid: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(alignment: .firstTextBaseline) {
                Text("Badges")
                    .font(DesignSystem.Typography.headlineLarge)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                Spacer()
                Text("\(summary.badges.filter(\.isUnlocked).count)/\(summary.badges.count)")
                    .font(DesignSystem.Typography.labelLarge)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }

            LazyVGrid(columns: badgeColumns, spacing: DesignSystem.Spacing.md) {
                ForEach(summary.badges) { badge in
                    badgeCell(badge)
                }
            }
        }
    }

    private func badgeCell(_ badge: Gamification.Badge) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(badge.isUnlocked ? DesignSystem.Colors.tealDim : DesignSystem.Colors.surfaceHigh)
                    .frame(width: 56, height: 56)
                Image(systemName: badge.isUnlocked ? badge.symbol : "lock.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(badge.isUnlocked ? DesignSystem.Colors.teal : DesignSystem.Colors.textTertiary)
            }
            Text(badge.name)
                .font(DesignSystem.Typography.labelLarge)
                .foregroundStyle(badge.isUnlocked ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(badge.detail)
                .font(DesignSystem.Typography.labelSmall)
                .foregroundStyle(DesignSystem.Colors.textTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2, reservesSpace: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.md)
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .background(DesignSystem.Colors.surface, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                .strokeBorder(
                    badge.isUnlocked ? DesignSystem.Colors.teal.opacity(0.4) : DesignSystem.Colors.border,
                    lineWidth: 1
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityValue(badge.isUnlocked ? "Unlocked" : "Locked")
    }
}

#Preview {
    NavigationStack {
        ProgressScreen()
    }
    .modelContainer(for: [AppWeek.self, WorkoutLog.self, DrinkLog.self], inMemory: true)
    .preferredColorScheme(.dark)
}
