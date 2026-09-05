import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.openURL) private var openURL
    @Query(sort: \AppWeek.weekNumber, order: .reverse) private var weeks: [AppWeek]

    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("reminderTime") private var reminderTimeInterval: Double = SettingsView.defaultReminderInterval
    @AppStorage(DrinkUnit.storageKey) private var drinkUnitRaw = DrinkUnit.pints.rawValue
    @AppStorage(ProgramPreferences.onboardingCompletedKey) private var hasCompletedOnboarding = true

    @State private var showResetConfirm = false
    @State private var showEraseConfirm = false
    @State private var showNotificationDenied = false
    @State private var saveErrorMessage: String?

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
                Text("Unit changes apply from the next week, so existing history keeps its original meaning. Your target started at \(ProgramPreferences.startingBudget) and drops by 1 every two weeks to 5.")
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

            Section("Legal & Support") {
                Link("Privacy Policy", destination: URL(string: "https://streakline.fit/privacy/")!)
                Link("Support", destination: URL(string: "https://streakline.fit/support/")!)
                Link("Email Support", destination: URL(string: "mailto:support@streakline.fit")!)
            }

            Section {
                Button("Erase all data", role: .destructive) {
                    showEraseConfirm = true
                }
            } header: {
                Text("Data")
            } footer: {
                Text("Permanently deletes all workout, drink, note, streak, and preference data stored by Streakline on this iPhone.")
            }

            Section("Health notice") {
                Text("Streakline is for adults of legal drinking age. It is a habit and fitness tracker, not medical advice or treatment. If reducing alcohol may cause withdrawal, seek medical advice first.")
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
        .confirmationDialog("Erase all Streakline data?", isPresented: $showEraseConfirm, titleVisibility: .visible) {
            Button("Erase all data", role: .destructive, action: eraseAllData)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes your entire history and returns Streakline to setup.")
        }
        .alert("Notifications are disabled", isPresented: $showNotificationDenied) {
            Button("Open iOS Settings") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                openURL(url)
            }
            Button("Not now", role: .cancel) {}
        } message: {
            Text("Allow notifications in iOS Settings to use daily reminders.")
        }
        .alert("Your changes couldn't be saved", isPresented: saveErrorBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveErrorMessage ?? "Please try again.")
        }
    }

    // MARK: - Actions

    private func handleToggle(_ enabled: Bool) async {
        if enabled {
            let granted = await NotificationManager.requestAuthorization()
            if !granted {
                await MainActor.run {
                    notificationsEnabled = false
                    showNotificationDenied = true
                }
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
            drinkBudget: week.drinkBudget,
            drinkUnit: week.drinkUnit
        )
    }

    private func resetWeek() {
        let week = WeekManager.currentWeek(in: context)
        do {
            try AppDataManager.resetCurrentWeek(week, in: context)
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }

    private func eraseAllData() {
        do {
            try AppDataManager.eraseAll(weeks, in: context)
            notificationsEnabled = false
            reminderTimeInterval = SettingsView.defaultReminderInterval
            drinkUnitRaw = DrinkUnit.pints.rawValue
            UserDefaults.standard.removeObject(forKey: ProgramPreferences.startingBudgetKey)
            UserDefaults.standard.removeObject(forKey: "lastCelebratedRankIndex")
            NotificationManager.cancelDailyReminder()
            hasCompletedOnboarding = false
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }

    private var saveErrorBinding: Binding<Bool> {
        Binding(
            get: { saveErrorMessage != nil },
            set: { if !$0 { saveErrorMessage = nil } }
        )
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: [AppWeek.self, WorkoutLog.self, DrinkLog.self], inMemory: true)
    .preferredColorScheme(.dark)
}
