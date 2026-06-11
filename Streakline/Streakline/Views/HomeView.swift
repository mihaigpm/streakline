import SwiftUI
import SwiftData

/// Non-workout destinations reachable from the home screen.
enum HomeRoute: Hashable {
    case progress
}

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \AppWeek.weekNumber, order: .reverse) private var weeks: [AppWeek]

    @AppStorage(DrinkUnit.storageKey) private var drinkUnitRaw = DrinkUnit.pints.rawValue
    /// Highest rank index already celebrated; -1 until first launch initialises it.
    @AppStorage("lastCelebratedRankIndex") private var lastCelebratedRankIndex = -1
    @State private var currentWeek: AppWeek?
    @State private var path = NavigationPath()
    @State private var rankUpToShow: Gamification.Rank?
    @State private var rankUpPending = false

    private var unit: DrinkUnit { DrinkUnit(rawValue: drinkUnitRaw) ?? .pints }
    private var rankIndex: Int { Gamification.summary(for: weeks).rankIndex }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                DesignSystem.Colors.background.ignoresSafeArea()

                if let week = currentWeek {
                    content(for: week)
                } else {
                    ProgressView()
                        .tint(DesignSystem.Colors.teal)
                }
            }
            .navigationDestination(for: WorkoutDay.self) { day in
                if let week = currentWeek {
                    WorkoutDetailView(day: day, week: week)
                }
            }
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .progress: ProgressScreen()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Image(systemName: "calendar")
                    }
                    .tint(DesignSystem.Colors.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .tint(DesignSystem.Colors.textSecondary)
                }
            }
        }
        .tint(DesignSystem.Colors.teal)
        .onAppear(perform: refreshWeek)
        .onChange(of: rankIndex) { _, newIndex in
            handleRankChange(to: newIndex)
        }
        .onChange(of: path.count) { _, count in
            if count == 0, rankUpPending {
                rankUpPending = false
                rankUpToShow = Gamification.ranks[rankIndex]
            }
        }
        .fullScreenCover(item: $rankUpToShow, onDismiss: {
            lastCelebratedRankIndex = rankIndex
        }) { rank in
            RankUpView(rank: rank)
        }
    }

    // MARK: - Rank-up celebration

    private func handleRankChange(to newIndex: Int) {
        // First observation ever: baseline without celebrating.
        guard lastCelebratedRankIndex >= 0 else {
            lastCelebratedRankIndex = newIndex
            return
        }
        if newIndex > lastCelebratedRankIndex {
            if path.isEmpty {
                rankUpToShow = Gamification.ranks[newIndex]
            } else {
                // Mid-workout: defer until the user is back home.
                rankUpPending = true
            }
        } else if newIndex < lastCelebratedRankIndex {
            // XP went down (undo) — quietly lower the baseline so a
            // re-earned rank celebrates again only once.
            lastCelebratedRankIndex = newIndex
        }
    }

    private func content(for week: AppWeek) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                weekHeader(week)
                ring(week)
                workoutCards(week)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, DesignSystem.Spacing.sm)
            .padding(.bottom, 120)
        }
        .safeAreaInset(edge: .bottom) {
            DrinkLogStripView(
                total: week.totalDrinks,
                budget: week.drinkBudget,
                unit: unit,
                dayStates: Gamification.dayStates(for: week),
                onAdd: { addDrink(to: week) },
                onSubtract: { subtractDrink(from: week) }
            )
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.sm)
            .background(.clear)
        }
    }

    // MARK: - Zone 1: Week header

    private func weekHeader(_ week: AppWeek) -> some View {
        let streak = WeekManager.streak(in: context, currentWeekNumber: week.weekNumber)
        return VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(alignment: .top) {
                Text("Week \(week.weekNumber)")
                    .font(DesignSystem.Typography.displayMedium)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                    .kerning(-1)
                Spacer()
                drinkBudgetBadge(week)
            }
            HStack(spacing: DesignSystem.Spacing.sm) {
                rankPill
                if streak > 0 {
                    streakPill(streak)
                }
            }
        }
    }

    private var rankPill: some View {
        NavigationLink(value: HomeRoute.progress) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(DesignSystem.Colors.teal)
                Text(Gamification.summary(for: weeks).rank.name)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(DesignSystem.Colors.textTertiary)
            }
            .font(DesignSystem.Typography.labelLarge)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(DesignSystem.Colors.tealDim, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Rank: \(Gamification.summary(for: weeks).rank.name). Opens progress.")
    }

    private func drinkBudgetBadge(_ week: AppWeek) -> some View {
        let remaining = week.drinksRemaining
        return Text("\(unit.format(remaining)) \(unit.noun(for: remaining)) left")
            .font(DesignSystem.Typography.labelLarge)
            .foregroundStyle(week.isOverBudget ? DesignSystem.Colors.red : DesignSystem.Colors.amber)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                (week.isOverBudget ? DesignSystem.Colors.red.opacity(0.15) : DesignSystem.Colors.amberDim),
                in: Capsule()
            )
    }

    private func streakPill(_ streak: Int) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "flame.fill")
                .foregroundStyle(DesignSystem.Colors.amber)
            Text("\(streak) week streak")
                .foregroundStyle(DesignSystem.Colors.textPrimary)
        }
        .font(DesignSystem.Typography.labelLarge)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(DesignSystem.Colors.surfaceHigh, in: Capsule())
    }

    // MARK: - Zone 2: Progress ring

    private func ring(_ week: AppWeek) -> some View {
        ProgressRingView(
            workoutsCompleted: week.completedWorkouts,
            workoutTarget: 3,
            drinkFraction: week.drinkFraction,
            isOverBudget: week.isOverBudget
        )
        .frame(width: 220, height: 220)
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }

    // MARK: - Zone 3: Workout cards

    private func workoutCards(_ week: AppWeek) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("This week's workouts")
                .font(DesignSystem.Typography.headlineSmall)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(WorkoutDay.allCases) { day in
                        NavigationLink(value: day) {
                            WorkoutCardView(day: day, isCompleted: week.log(for: day)?.isCompleted ?? false)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.xs)
            }
        }
    }

    // MARK: - Logic

    private func refreshWeek() {
        currentWeek = WeekManager.currentWeek(in: context)

        // Catch a rank-up that was earned but never celebrated
        // (e.g. the app was quit mid-workout).
        if lastCelebratedRankIndex >= 0, rankIndex > lastCelebratedRankIndex, path.isEmpty {
            rankUpToShow = Gamification.ranks[rankIndex]
        } else if lastCelebratedRankIndex < 0 {
            lastCelebratedRankIndex = rankIndex
        }

        #if DEBUG
        handleLaunchArguments()
        #endif
    }

    #if DEBUG
    /// Deep-launch support for UI verification, e.g. `-open-day "Day A" -open-guide`.
    private func handleLaunchArguments() {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-show-rankup") {
            rankUpToShow = Gamification.ranks[4]
            return
        }
        guard path.isEmpty else { return }
        if args.contains("-open-progress") {
            path.append(HomeRoute.progress)
        } else if let index = args.firstIndex(of: "-open-day"), index + 1 < args.count,
                  let day = WorkoutDay(rawValue: args[index + 1]) {
            path.append(day)
        }
    }
    #endif

    private func addDrink(to week: AppWeek) {
        let step = unit.step
        let calendar = Calendar.current
        if let todays = week.drinkLogs.first(where: { calendar.isDateInToday($0.date) }) {
            todays.amount += step
        } else {
            let log = DrinkLog(amount: step)
            log.week = week
            week.drinkLogs.append(log)
            context.insert(log)
        }
        try? context.save()
    }

    private func subtractDrink(from week: AppWeek) {
        guard let recent = week.drinkLogs.sorted(by: { $0.date > $1.date }).first else { return }
        recent.amount -= unit.step
        if recent.amount <= 0 {
            week.drinkLogs.removeAll { $0.persistentModelID == recent.persistentModelID }
            context.delete(recent)
        }
        try? context.save()
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [AppWeek.self, WorkoutLog.self, DrinkLog.self], inMemory: true)
        .preferredColorScheme(.dark)
}
