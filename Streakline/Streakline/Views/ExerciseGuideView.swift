import SwiftUI

/// Full-screen "focus mode" guide: swipe through the day's exercises,
/// read step-by-step guidance, and tick each one off as you go.
struct ExerciseGuideView: View {
    let day: WorkoutDay
    let exercises: [Exercise]
    let isDone: (Exercise) -> Bool
    let toggle: (Exercise) -> Void
    let workoutCompleted: Bool
    let onFinishWorkout: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selection: Int

    init(
        day: WorkoutDay,
        exercises: [Exercise],
        startIndex: Int,
        isDone: @escaping (Exercise) -> Bool,
        toggle: @escaping (Exercise) -> Void,
        workoutCompleted: Bool,
        onFinishWorkout: @escaping () -> Void
    ) {
        self.day = day
        self.exercises = exercises
        self.isDone = isDone
        self.toggle = toggle
        self.workoutCompleted = workoutCompleted
        self.onFinishWorkout = onFinishWorkout
        _selection = State(initialValue: startIndex)
    }

    private var allDone: Bool { exercises.allSatisfy(isDone) }
    private var doneCount: Int { exercises.filter(isDone).count }

    var body: some View {
        ZStack {
            DesignSystem.Colors.background.ignoresSafeArea()
            accentGlow

            VStack(spacing: 0) {
                header
                progressTrack

                TabView(selection: $selection) {
                    ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                        ExerciseGuidePage(exercise: exercise, accent: day.accentColor)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .safeAreaInset(edge: .bottom) { bottomBar }
        .preferredColorScheme(.dark)
    }

    private var accentGlow: some View {
        RadialGradient(
            colors: [day.accentColor.opacity(0.14), .clear],
            center: .top,
            startRadius: 0,
            endRadius: 420
        )
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(DesignSystem.Colors.surfaceHigh, in: Circle())
            }
            .accessibilityLabel("Close guide")

            Spacer()

            Text("\(doneCount) of \(exercises.count) done")
                .font(DesignSystem.Typography.labelLarge)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, DesignSystem.Spacing.sm)
    }

    private var progressTrack: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(exercises.indices, id: \.self) { index in
                Capsule()
                    .fill(segmentColor(index))
                    .frame(height: index == selection ? 6 : 4)
                    .onTapGesture {
                        withAnimation(DesignSystem.Motion.ring) { selection = index }
                    }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
        .animation(DesignSystem.Motion.ring, value: selection)
        .animation(DesignSystem.Motion.ring, value: doneCount)
    }

    private func segmentColor(_ index: Int) -> Color {
        if isDone(exercises[index]) { return day.accentColor }
        return index == selection ? DesignSystem.Colors.textTertiary : DesignSystem.Colors.surfaceHigh
    }

    // MARK: - Bottom bar

    @ViewBuilder
    private var bottomBar: some View {
        let exercise = exercises[selection]
        VStack(spacing: DesignSystem.Spacing.sm) {
            if isDone(exercise) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    Label("Done", systemImage: "checkmark.circle.fill")
                        .font(DesignSystem.Typography.headlineSmall)
                        .foregroundStyle(day.accentColor)
                    Button("Undo") { toggle(exercise) }
                        .font(DesignSystem.Typography.labelLarge)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.surfaceHigh, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
            } else {
                Button(action: complete) {
                    Label("Mark exercise done", systemImage: "checkmark")
                        .font(DesignSystem.Typography.headlineLarge)
                        .foregroundStyle(DesignSystem.Colors.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.md)
                        .background(
                            LinearGradient(
                                colors: [day.accentColor, day.accentColor.opacity(0.75)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            in: RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                        )
                        .shadow(color: day.accentColor.opacity(0.4), radius: 12, y: 4)
                }
            }

            if allDone && !workoutCompleted {
                Button(action: onFinishWorkout) {
                    Label("Finish workout", systemImage: "flag.checkered")
                        .font(DesignSystem.Typography.headlineLarge)
                        .foregroundStyle(DesignSystem.Colors.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.md)
                        .background(DesignSystem.Colors.teal, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
                        .shadow(color: DesignSystem.Colors.teal.opacity(0.5), radius: 14, y: 4)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.bottom, DesignSystem.Spacing.sm)
        .animation(DesignSystem.Motion.cardPulse, value: allDone)
        .animation(DesignSystem.Motion.cardPulse, value: isDone(exercise))
    }

    // MARK: - Actions

    private func complete() {
        let exercise = exercises[selection]
        toggle(exercise)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        // Auto-advance to the next unfinished exercise after a beat.
        if let next = nextIncompleteIndex() {
            Task {
                try? await Task.sleep(for: .milliseconds(500))
                withAnimation(DesignSystem.Motion.ring) { selection = next }
            }
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    private func nextIncompleteIndex() -> Int? {
        let after = exercises.indices.dropFirst(selection + 1).first { !isDone(exercises[$0]) }
        return after ?? exercises.indices.first { $0 != selection && !isDone(exercises[$0]) }
    }
}

// MARK: - Single exercise page

private struct ExerciseGuidePage: View {
    let exercise: Exercise
    let accent: Color

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                hero
                coachNote
                section(title: "How to do it") { stepsList }
                section(title: "Form cues") { cueChips }
                section(title: "Avoid") { mistakesList }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
    }

    private var hero: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.14))
                    .frame(width: 108, height: 108)
                Circle()
                    .strokeBorder(accent.opacity(0.35), lineWidth: 1)
                    .frame(width: 108, height: 108)
                Image(systemName: exercise.symbol)
                    .font(.system(size: 46, weight: .semibold))
                    .foregroundStyle(accent)
            }
            .shadow(color: accent.opacity(0.35), radius: 18)

            Text(exercise.name)
                .font(DesignSystem.Typography.displaySmall)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .multilineTextAlignment(.center)

            Text(exercise.prescription)
                .font(DesignSystem.Typography.labelLarge)
                .foregroundStyle(accent)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(accent.opacity(0.15), in: Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DesignSystem.Spacing.sm)
    }

    private var coachNote: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "quote.opening")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(accent)
            Text(exercise.note)
                .font(DesignSystem.Typography.bodySmall)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
    }

    private func section(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(title)
                .font(DesignSystem.Typography.headlineSmall)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var stepsList: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            ForEach(Array(exercise.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                    Text("\(index + 1)")
                        .font(DesignSystem.Typography.labelLarge)
                        .foregroundStyle(accent)
                        .frame(width: 26, height: 26)
                        .background(accent.opacity(0.15), in: Circle())
                    Text(step)
                        .font(DesignSystem.Typography.bodySmall)
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var cueChips: some View {
        FlowLayout(spacing: DesignSystem.Spacing.sm) {
            ForEach(exercise.cues, id: \.self) { cue in
                Text(cue)
                    .font(DesignSystem.Typography.labelLarge)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(DesignSystem.Colors.surfaceHigh, in: Capsule())
                    .overlay(Capsule().strokeBorder(DesignSystem.Colors.border, lineWidth: 1))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mistakesList: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            ForEach(exercise.mistakes, id: \.self) { mistake in
                HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(DesignSystem.Colors.red.opacity(0.85))
                        .padding(.top, 2)
                    Text(mistake)
                        .font(DesignSystem.Typography.bodySmall)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

/// Minimal left-aligned wrapping layout for chips.
private struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let width = proposal.width ?? rows.map(\.width).max() ?? 0
        let height = rows.map(\.height).reduce(0, +) + spacing * CGFloat(max(0, rows.count - 1))
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in computeRows(proposal: proposal, subviews: subviews) {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [Row] = []
        var current = Row()
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            let needed = current.indices.isEmpty ? size.width : current.width + spacing + size.width
            if needed > maxWidth, !current.indices.isEmpty {
                rows.append(current)
                current = Row()
            }
            current.indices.append(index)
            current.width = current.indices.count == 1 ? size.width : current.width + spacing + size.width
            current.height = max(current.height, size.height)
        }
        if !current.indices.isEmpty { rows.append(current) }
        return rows
    }
}

#Preview {
    ExerciseGuideView(
        day: .dayA,
        exercises: WorkoutDay.dayAExercises,
        startIndex: 0,
        isDone: { _ in false },
        toggle: { _ in },
        workoutCompleted: false,
        onFinishWorkout: {}
    )
}
