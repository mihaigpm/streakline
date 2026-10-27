import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @AppStorage(DrinkUnit.storageKey) private var drinkUnitRaw = DrinkUnit.pints.rawValue
    @AppStorage(ProgramPreferences.startingBudgetKey) private var startingBudget = 10
    @AppStorage(ProgrammePreset.storageKey) private var programmePresetRaw = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false

    @State private var notificationDenied = false

    private var unit: DrinkUnit {
        DrinkUnit(rawValue: drinkUnitRaw) ?? .pints
    }

    var body: some View {
        ZStack {
            DesignSystem.Colors.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                    header
                    setupCard
                    programmeCard
                    howItWorksCard
                    reminderCard
                    safetyNotice
                    startButton
                }
                .padding(DesignSystem.Spacing.lg)
            }
        }
        .alert("Notifications are off", isPresented: $notificationDenied) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You can enable notifications later in iOS Settings.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: DesignSystem.Spacing.md) {
                Image(systemName: "waveform.path.ecg")
                    .font(.title2)
                    .foregroundStyle(DesignSystem.Colors.teal)
                    .accessibilityHidden(true)
                Text("Build a streak that helps")
                    .font(DesignSystem.Typography.displayMedium)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
            }
            Text("Choose a realistic starting target and the kind of week you already live. Streakline keeps it to three sessions.")
                .font(DesignSystem.Typography.body)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
        }
    }

    private var setupCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Your starting target")
                .font(DesignSystem.Typography.headlineLarge)
                .foregroundStyle(DesignSystem.Colors.textPrimary)

            Picker("Drink unit", selection: $drinkUnitRaw) {
                ForEach(DrinkUnit.allCases) { choice in
                    Text(choice.displayName).tag(choice.rawValue)
                }
            }
            .tint(DesignSystem.Colors.teal)

            Stepper(
                value: $startingBudget,
                in: ProgramPreferences.minimumStartingBudget...ProgramPreferences.maximumStartingBudget
            ) {
                LabeledContent("Weekly target") {
                    Text("\(startingBudget) \(unit.noun(for: Double(startingBudget)))")
                        .foregroundStyle(DesignSystem.Colors.teal)
                }
            }
            .tint(DesignSystem.Colors.teal)
        }
        .cardStyle()
    }

    private var programmeCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Which week do you live?")
                .font(DesignSystem.Typography.headlineLarge)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            Text("Three sessions. You can swap any one of them later.")
                .font(DesignSystem.Typography.bodySmall)
                .foregroundStyle(DesignSystem.Colors.textSecondary)

            ForEach(ProgrammePreset.allCases) { preset in
                let selected = programmePresetRaw == preset.rawValue
                Button {
                    programmePresetRaw = preset.rawValue
                } label: {
                    HStack(alignment: .center, spacing: DesignSystem.Spacing.md) {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text(preset.title)
                                .font(DesignSystem.Typography.headlineSmall)
                                .foregroundStyle(DesignSystem.Colors.textPrimary)
                            Text(preset.detail)
                                .font(DesignSystem.Typography.bodySmall)
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: DesignSystem.Spacing.sm)
                        if selected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(DesignSystem.Colors.teal)
                                .accessibilityHidden(true)
                        }
                    }
                    .padding(DesignSystem.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        selected ? DesignSystem.Colors.tealDim : DesignSystem.Colors.surfaceHigh,
                        in: RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                            .strokeBorder(
                                selected ? DesignSystem.Colors.teal : DesignSystem.Colors.border,
                                lineWidth: selected ? 2 : 1
                            )
                    )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? .isSelected : AccessibilityTraits())
            }
        }
        .cardStyle()
    }

    private var howItWorksCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Label("Gradual by design", systemImage: "chart.line.downtrend.xyaxis")
                .font(DesignSystem.Typography.headlineLarge)
                .foregroundStyle(DesignSystem.Colors.amber)
            Text("Your target drops by 1 every two weeks and does not go below the guideline of \(AlcoholUnits.displayFloorLabel(for: unit)). If you start under that, it stays where you set it. This is a personal tracking target, not a medically safe limit.")
                .font(DesignSystem.Typography.body)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
        }
        .cardStyle()
    }

    private var reminderCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Toggle("Daily reminder", isOn: reminderBinding)
                .font(DesignSystem.Typography.headlineSmall)
                .tint(DesignSystem.Colors.teal)
            Text("Optional. If enabled, iOS will ask for permission and Streakline will schedule one local reminder each day.")
                .font(DesignSystem.Typography.bodySmall)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
        }
        .cardStyle()
    }

    private var reminderBinding: Binding<Bool> {
        Binding(
            get: { notificationsEnabled },
            set: { enabled in
                guard enabled else {
                    notificationsEnabled = false
                    return
                }
                Task {
                    let granted = await NotificationManager.requestAuthorization()
                    await MainActor.run {
                        notificationsEnabled = granted
                        notificationDenied = !granted
                    }
                }
            }
        )
    }

    private var safetyNotice: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Important")
                .font(DesignSystem.Typography.headlineSmall)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            Text("Streakline is for adults of legal drinking age. It is a habit and fitness tracker, not medical advice or treatment. If reducing alcohol may cause withdrawal, seek medical advice before changing your intake.")
                .font(DesignSystem.Typography.bodySmall)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var startButton: some View {
        Button(action: onComplete) {
            Text("Start my streak")
                .font(DesignSystem.Typography.headlineLarge)
                .foregroundStyle(DesignSystem.Colors.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.teal, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
        }
        .disabled(programmePresetRaw.isEmpty)
        .opacity(programmePresetRaw.isEmpty ? 0.4 : 1)
        .accessibilityHint(
            programmePresetRaw.isEmpty
                ? "Choose Running, Gym, or Home first"
                : "Saves your target and opens the home screen"
        )
    }
}

private extension View {
    func cardStyle() -> some View {
        padding(DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DesignSystem.Colors.surface, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    .strokeBorder(DesignSystem.Colors.border, lineWidth: 1)
            )
    }
}

#Preview {
    OnboardingView(onComplete: {})
        .preferredColorScheme(.dark)
}
