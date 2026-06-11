import Foundation

/// Pure, stateless gamification engine. Everything is computed from the
/// persisted `AppWeek` data — no separate XP storage that could drift.
///
/// XP events:
///   +10  per exercise ticked off
///   +50  per workout completed
///   +15  per dry day (a fully elapsed day with no drinks logged)
///   +150 per fully complete week
enum Gamification {

    // MARK: - Ranks

    struct Rank: Identifiable, Equatable {
        let name: String
        let threshold: Int

        var id: String { name }
    }

    static let ranks: [Rank] = [
        Rank(name: "Rookie", threshold: 0),
        Rank(name: "Starter", threshold: 150),
        Rank(name: "Consistent", threshold: 400),
        Rank(name: "Committed", threshold: 800),
        Rank(name: "Disciplined", threshold: 1400),
        Rank(name: "Relentless", threshold: 2200),
        Rank(name: "Machine", threshold: 3200),
        Rank(name: "Unbreakable", threshold: 4500),
        Rank(name: "Legend", threshold: 6000),
    ]

    // MARK: - Badges

    struct Badge: Identifiable {
        let id: String
        let name: String
        let detail: String
        let symbol: String
        let isUnlocked: Bool
    }

    // MARK: - Day states (for the dry-day dots)

    enum DayDrinkState {
        /// Fully elapsed day with no drinks.
        case dry
        /// Day with at least one drink logged.
        case drank
        /// Today, no drinks so far (still in progress).
        case today
        /// Day hasn't happened yet.
        case future
    }

    // MARK: - Summary

    struct Summary {
        let xp: Int
        let rankIndex: Int
        let rank: Rank
        let nextRank: Rank?
        /// 0...1 progress from the current rank to the next.
        let progressToNextRank: Double
        let totalWorkouts: Int
        let totalExercises: Int
        let totalDryDays: Int
        let bestStreak: Int
        let badges: [Badge]

        var xpToNextRank: Int? {
            guard let nextRank else { return nil }
            return nextRank.threshold - xp
        }
    }

    static func summary(for weeks: [AppWeek], now: Date = .now) -> Summary {
        let totalWorkouts = weeks.reduce(0) { $0 + $1.completedWorkouts }
        let totalExercises = weeks.reduce(0) { sum, week in
            sum + week.workoutLogs.reduce(0) { $0 + $1.completedExercises.count }
        }
        let totalDryDays = weeks.reduce(0) { $0 + dryDayCount(in: $1, now: now) }
        let completeWeeks = weeks.filter(\.isFullyComplete).count
        let bestStreak = bestStreak(in: weeks)

        let xp = totalExercises * 10
            + totalWorkouts * 50
            + totalDryDays * 15
            + completeWeeks * 150

        let rankIndex = ranks.lastIndex { xp >= $0.threshold } ?? 0
        let rank = ranks[rankIndex]
        let nextRank = rankIndex + 1 < ranks.count ? ranks[rankIndex + 1] : nil

        let progress: Double
        if let nextRank {
            let span = Double(nextRank.threshold - rank.threshold)
            progress = span > 0 ? Double(xp - rank.threshold) / span : 1
        } else {
            progress = 1
        }

        return Summary(
            xp: xp,
            rankIndex: rankIndex,
            rank: rank,
            nextRank: nextRank,
            progressToNextRank: min(1, max(0, progress)),
            totalWorkouts: totalWorkouts,
            totalExercises: totalExercises,
            totalDryDays: totalDryDays,
            bestStreak: bestStreak,
            badges: badges(
                weeks: weeks,
                totalWorkouts: totalWorkouts,
                totalExercises: totalExercises,
                bestStreak: bestStreak,
                now: now
            )
        )
    }

    // MARK: - Dry days

    /// Number of fully elapsed days in this week with no drinks logged.
    /// Today never counts — the day isn't over yet.
    static func dryDayCount(in week: AppWeek, now: Date = .now) -> Int {
        dayStates(for: week, now: now).filter { $0 == .dry }.count
    }

    /// The 7 day states for a week, Monday-first.
    static func dayStates(for week: AppWeek, now: Date = .now) -> [DayDrinkState] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        return (0..<7).map { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: week.startDate) else {
                return .future
            }
            let dayStart = calendar.startOfDay(for: day)
            let hasDrinks = week.drinkLogs.contains {
                calendar.isDate($0.date, inSameDayAs: dayStart) && $0.amount > 0
            }
            if hasDrinks { return .drank }
            if dayStart > today { return .future }
            if dayStart == today { return .today }
            return .dry
        }
    }

    // MARK: - Streaks

    /// Longest run of consecutive fully-complete weeks.
    static func bestStreak(in weeks: [AppWeek]) -> Int {
        let sorted = weeks.sorted { $0.weekNumber < $1.weekNumber }
        var best = 0
        var run = 0
        var lastNumber: Int?
        for week in sorted {
            let consecutive = lastNumber.map { week.weekNumber == $0 + 1 } ?? true
            run = week.isFullyComplete ? (consecutive ? run + 1 : 1) : 0
            best = max(best, run)
            lastNumber = week.weekNumber
        }
        return best
    }

    // MARK: - Badge evaluation

    private static func badges(
        weeks: [AppWeek],
        totalWorkouts: Int,
        totalExercises: Int,
        bestStreak: Int,
        now: Date
    ) -> [Badge] {
        let calendar = Calendar.current
        let hasPerfectWeek = weeks.contains(where: \.isFullyComplete)
        let hasHatTrick = weeks.contains { $0.completedWorkouts >= 3 }
        let hasDrySpell = weeks.contains { dryDayCount(in: $0, now: now) >= 4 }
        let hasBudgetBoss = weeks.contains { week in
            week.endDate < calendar.startOfDay(for: now)
                && week.totalDrinks <= Double(week.drinkBudget) / 2
        }
        let reachedFloor = weeks.contains { $0.drinkBudget == 5 }

        return [
            Badge(
                id: "first-workout", name: "First Steps",
                detail: "Complete your first workout",
                symbol: "figure.walk", isUnlocked: totalWorkouts >= 1
            ),
            Badge(
                id: "hat-trick", name: "Hat-Trick",
                detail: "All 3 workouts in one week",
                symbol: "trophy.fill", isUnlocked: hasHatTrick
            ),
            Badge(
                id: "perfect-week", name: "Perfect Week",
                detail: "3 workouts and under budget",
                symbol: "checkmark.seal.fill", isUnlocked: hasPerfectWeek
            ),
            Badge(
                id: "streak-2", name: "Back to Back",
                detail: "2 perfect weeks in a row",
                symbol: "flame", isUnlocked: bestStreak >= 2
            ),
            Badge(
                id: "streak-4", name: "Month Strong",
                detail: "4 perfect weeks in a row",
                symbol: "flame.fill", isUnlocked: bestStreak >= 4
            ),
            Badge(
                id: "dry-spell", name: "Dry Spell",
                detail: "4 dry days in one week",
                symbol: "drop.fill", isUnlocked: hasDrySpell
            ),
            Badge(
                id: "budget-boss", name: "Budget Boss",
                detail: "Finish a week at half budget or less",
                symbol: "chart.line.downtrend.xyaxis", isUnlocked: hasBudgetBoss
            ),
            Badge(
                id: "the-floor", name: "The Long Game",
                detail: "Reach the minimum drink budget",
                symbol: "mountain.2.fill", isUnlocked: reachedFloor
            ),
            Badge(
                id: "workouts-10", name: "Iron Will",
                detail: "10 workouts completed",
                symbol: "dumbbell.fill", isUnlocked: totalWorkouts >= 10
            ),
            Badge(
                id: "workouts-25", name: "Machine",
                detail: "25 workouts completed",
                symbol: "bolt.fill", isUnlocked: totalWorkouts >= 25
            ),
            Badge(
                id: "exercises-50", name: "Half Century",
                detail: "50 exercises ticked off",
                symbol: "star.fill", isUnlocked: totalExercises >= 50
            ),
            Badge(
                id: "exercises-100", name: "Century Club",
                detail: "100 exercises ticked off",
                symbol: "star.circle.fill", isUnlocked: totalExercises >= 100
            ),
        ]
    }
}
