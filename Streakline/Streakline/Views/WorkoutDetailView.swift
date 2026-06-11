import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    let day: WorkoutDay
    let week: AppWeek

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var notes: String = ""
    @State private var guideContext: GuideContext?
    @State private var celebrating = false

    private struct GuideContext: Identifiable {
        let id = UUID()
        let startIndex: Int
    }

    private var log: WorkoutLog? { week.log(for: day) }
    private var isCompleted: Bool { log?.isCompleted ?? false }

    /// Day C alternates run/circuit based on the week flag.
    private var dayCIsRun: Bool { week.dayC_wasRun }

    private var exercises: [Exercise] { day.exercises(dayCIsRun: dayCIsRun) }

    private var doneCount: Int {
        guard let log else { return 0 }
        return exercises.filter(log.isExerciseDone).count
    }

    private var allExercisesDone: Bool { doneCount == exercises.count }

    private var variantLabel: String? {
        guard day == .dayC else { return nil }
        return dayCIsRun ? "Run week" : "Circuit week"
    }

    var body: some View {
        ZStack {
            DesignSystem.Colors.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    header
                    exerciseProgress
                    notesField
                    exerciseList
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.sm)
                .padding(.bottom, 120)
            }

            if celebrating {
                ConfettiView()
                    .ignoresSafeArea()
            }
        }
        .navigationTitle(day.title)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { bottomBar }
        .onAppear {
            notes = log?.notes ?? ""
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-open-guide"), guideContext == nil {
                guideContext = GuideContext(startIndex: 0)
            }
            #endif
        }
        .fullScreenCover(item: $guideContext) { context in
            ExerciseGuideView(
                day: day,
                exercises: exercises,
                startIndex: context.startIndex,
                isDone: { log?.isExerciseDone($0) ?? false },
                toggle: toggleExercise,
                workoutCompleted: isCompleted,
                onFinishWorkout: finishFromGuide
            )
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: day.sfSymbol)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(day.accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(day.title)
                        .font(DesignSystem.Typography.displaySmall)
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    Text(day.subtitle)
                        .font(DesignSystem.Typography.bodySmall)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
            }

            HStack(spacing: DesignSystem.Spacing.sm) {
                metaPill(systemName: "clock", text: day.estimatedDuration)
                if let variantLabel {
                    metaPill(systemName: "arrow.triangle.2.circlepath", text: variantLabel)
                }
                if isCompleted {
                    completedBadge
                }
            }
        }
    }

    private func metaPill(systemName: String, text: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: systemName)
            Text(text)
        }
        .font(DesignSystem.Typography.labelLarge)
        .foregroundStyle(DesignSystem.Colors.textSecondary)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(DesignSystem.Colors.surfaceHigh, in: Capsule())
    }

    private var completedBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "checkmark.seal.fill")
            Text("Completed")
        }
        .font(DesignSystem.Typography.labelLarge)
        .foregroundStyle(DesignSystem.Colors.teal)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(DesignSystem.Colors.tealDim, in: Capsule())
    }

    // MARK: - Exercise progress

    private var exerciseProgress: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text(allExercisesDone ? "All exercises done" : "Exercise progress")
                    .font(DesignSystem.Typography.labelLarge)
                    .foregroundStyle(allExercisesDone ? day.accentColor : DesignSystem.Colors.textSecondary)
                Spacer()
                Text("\(doneCount)/\(exercises.count)")
                    .font(DesignSystem.Typography.labelLarge)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                    .contentTransition(.numericText())
            }
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(exercises) { exercise in
                    Capsule()
                        .fill(log?.isExerciseDone(exercise) == true ? day.accentColor : DesignSystem.Colors.surfaceHigh)
                        .frame(height: 5)
                }
            }
        }
        .animation(DesignSystem.Motion.ring, value: doneCount)
    }

    // MARK: - Notes

    private var notesField: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Notes")
                .font(DesignSystem.Typography.labelLarge)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
            TextField("How did it go?", text: $notes)
                .font(DesignSystem.Typography.bodySmall)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .padding(DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.surface, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                        .strokeBorder(DesignSystem.Colors.border, lineWidth: 1)
                )
                .onChange(of: notes) { _, newValue in
                    log?.notes = newValue
                    try? context.save()
                }
        }
    }

    // MARK: - Exercise list

    private var exerciseList: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(alignment: .firstTextBaseline) {
                Text("Exercises")
                    .font(DesignSystem.Typography.headlineLarge)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                Spacer()
                Text("Tap for guidance")
                    .font(DesignSystem.Typography.labelSmall)
                    .foregroundStyle(DesignSystem.Colors.textTertiary)
            }
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                    exerciseRow(exercise, index: index)
                }
            }
        }
    }

    private func exerciseRow(_ exercise: Exercise, index: Int) -> some View {
        let done = log?.isExerciseDone(exercise) ?? false
        return HStack(spacing: DesignSystem.Spacing.md) {
            Button {
                toggleExercise(exercise)
            } label: {
                Image(systemName: done ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 26))
                    .foregroundStyle(done ? day.accentColor : DesignSystem.Colors.textTertiary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(done ? "Mark \(exercise.name) as not done" : "Mark \(exercise.name) as done")

            Button {
                guideContext = GuideContext(startIndex: index)
            } label: {
                HStack(spacing: DesignSystem.Spacing.md) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text(exercise.name)
                            .font(DesignSystem.Typography.headlineSmall)
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                        Text(exercise.note)
                            .font(DesignSystem.Typography.bodySmall)
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    Text(exercise.prescription)
                        .font(DesignSystem.Typography.labelLarge)
                        .foregroundStyle(day.accentColor)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens step-by-step guidance")
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            done ? day.accentColor.opacity(0.08) : DesignSystem.Colors.surface,
            in: RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                .strokeBorder(done ? day.accentColor.opacity(0.5) : DesignSystem.Colors.border, lineWidth: 1)
        )
        .opacity(done ? 0.82 : 1)
        .animation(DesignSystem.Motion.cardPulse, value: done)
    }

    // MARK: - Bottom bar

    @ViewBuilder
    private var bottomBar: some View {
        if isCompleted {
            Button(action: undo) {
                Text("Undo")
                    .font(DesignSystem.Typography.headlineSmall)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.md)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.sm)
        } else {
            Button(action: markDone) {
                Text(allExercisesDone ? "Finish workout" : "Mark as done")
                    .font(DesignSystem.Typography.headlineLarge)
                    .foregroundStyle(DesignSystem.Colors.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.teal, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
                    .shadow(
                        color: DesignSystem.Colors.teal.opacity(allExercisesDone ? 0.55 : 0),
                        radius: 14, y: 4
                    )
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.sm)
            .animation(DesignSystem.Motion.cardPulse, value: allExercisesDone)
        }
    }

    // MARK: - Actions

    private func ensureLog() -> WorkoutLog {
        if let log { return log }
        let new = WorkoutLog(workoutDay: day)
        new.week = week
        week.workoutLogs.append(new)
        context.insert(new)
        return new
    }

    private func toggleExercise(_ exercise: Exercise) {
        let target = ensureLog()
        target.setExercise(exercise, done: !target.isExerciseDone(exercise))
        try? context.save()
    }

    private func finishFromGuide() {
        guideContext = nil
        markDone()
    }

    private func markDone() {
        let target = ensureLog()
        target.notes = notes
        target.markCompleted()

        // Day C: flip the run/circuit flag for next time.
        if day == .dayC {
            week.dayC_wasRun.toggle()
        }

        try? context.save()
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        if reduceMotion {
            dismiss()
        } else {
            celebrating = true
            Task {
                try? await Task.sleep(for: .milliseconds(1400))
                dismiss()
            }
        }
    }

    private func undo() {
        log?.undoCompletion()
        if day == .dayC {
            week.dayC_wasRun.toggle()
        }
        try? context.save()
    }
}
