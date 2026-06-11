import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \AppWeek.weekNumber, order: .reverse) private var weeks: [AppWeek]

    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("reminderTime") private var reminderTimeInterval: Double = SettingsView.defaultReminderInterval
    @AppStorage(DrinkUnit.storageKey) private var drinkUnitRaw = DrinkUnit.pints.rawValue

    @State private var showResetConfirm = false

    private static let defaultReminderInterval: Double = {
        var comps = DateComponents()
        comps.hour = 8
        comps.minute = 0
        return Calendar.current.date(from: comps)?.timeIntervalSinceReferenceDate ?? 0
    }()

    private var reminderTime: Binding<Date> {
        Binding(
            get: { Date(timeIntervalSinceReferenceDate: reminderTimeInterval) },
            set: { reminderTimeInterval = $0.timeIntervalSinceReferenceDate }
        )
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(v) (\(b))"
    }

    var body: some View {
        Form {
            Section {
                Picker("Drink unit", selection: $drinkUnitRaw) {
                    ForEach(DrinkUnit.allCases) { unit in
                        Text(unit.displayName).tag(unit.rawValue)
                    }
                }
                .tint(DesignSystem.Colors.teal)
            } header: {
                Text("Tracking")
            } footer: {
                Text("How you count drinks. The weekly budget (10 down to 5) is in this unit.")
            }

            Section("Reminders") {
                Toggle("Daily reminder", isOn: $notificationsEnabled)
                    .tint(DesignSystem.Colors.teal)
                    .onChange(of: notificationsEnabled) { _, enabled in
                        Task { await handleToggle(enabled) }
                    }
                if notificationsEnabled {
                    DatePicker("Reminder time", selection: reminderTime, displayedComponents: .hourAndMinute)
                        .onChange(of: reminderTimeInterval) { _, _ in
                            Task { await reschedule() }
                        }
                }
            }

            Section {
                Button(role: .destructive) {
                    showResetConfirm = true
                } label: {
                    Text("Reset current week")
                }
            } footer: {
                Text("Clears this week's workout completions and logged drinks. History is kept.")
            }

            Section {
                HStack {
                    Spacer()
                    Text(appVersion)
                        .font(DesignSystem.Typography.labelSmall)
                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .background(DesignSystem.Colors.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .confirmationDialog("Reset this week?", isPresented: $showResetConfirm, titleVisibility: .visible) {
            Button("Reset week", role: .destructive, action: resetWeek)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This can't be undone.")
        }
    }

    // MARK: - Actions

    private func handleToggle(_ enabled: Bool) async {
        if enabled {
            let granted = await NotificationManager.requestAuthorization()
            if !granted {
                await MainActor.run { notificationsEnabled = false }
                return
            }
        }
        await reschedule()
    }

    private func reschedule() async {
        let state = currentWeekState()
        let gamification = NotificationManager.GamificationContext(
            summary: Gamification.summary(for: weeks)
        )
        await NotificationManager.scheduleDailyReminder(
            enabled: notificationsEnabled,
            at: reminderTime.wrappedValue,
            state: state,
            gamification: gamification
        )
    }

    private func currentWeekState() -> NotificationManager.WeekState {
        let week = WeekManager.currentWeek(in: context)
        return .init(
            completedWorkouts: week.completedWorkouts,
            totalDrinks: week.totalDrinks,
            drinkBudget: week.drinkBudget
        )
    }

    private func resetWeek() {
        let week = WeekManager.currentWeek(in: context)
        for log in week.workoutLogs {
            log.undoCompletion()
            log.notes = ""
        }
        for drink in week.drinkLogs {
            context.delete(drink)
        }
        week.drinkLogs.removeAll()
        try? context.save()
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: [AppWeek.self, WorkoutLog.self, DrinkLog.self], inMemory: true)
    .preferredColorScheme(.dark)
}
