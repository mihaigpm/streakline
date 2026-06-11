import SwiftUI

/// Full-screen celebration shown when the user crosses a rank threshold.
struct RankUpView: View {
    let rank: Gamification.Rank

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealed = false

    var body: some View {
        ZStack {
            DesignSystem.Colors.background.ignoresSafeArea()

            RadialGradient(
                colors: [DesignSystem.Colors.teal.opacity(0.18), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 380
            )
            .ignoresSafeArea()

            if !reduceMotion {
                ConfettiView()
                    .ignoresSafeArea()
            }

            VStack(spacing: DesignSystem.Spacing.lg) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.tealDim)
                        .frame(width: 132, height: 132)
                    Circle()
                        .strokeBorder(DesignSystem.Colors.teal.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 132, height: 132)
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 54, weight: .bold))
                        .foregroundStyle(DesignSystem.Colors.teal)
                }
                .shadow(color: DesignSystem.Colors.teal.opacity(0.5), radius: 24)
                .scaleEffect(revealed ? 1 : 0.6)

                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("RANK UP")
                        .font(DesignSystem.Typography.labelLarge)
                        .kerning(3)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                    Text(rank.name)
                        .font(DesignSystem.Typography.displayLarge)
                        .kerning(-1)
                        .foregroundStyle(DesignSystem.Colors.teal)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    Text("Discipline pays. Keep stacking wins.")
                        .font(DesignSystem.Typography.bodySmall)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
                .opacity(revealed ? 1 : 0)
                .offset(y: revealed ? 0 : 12)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Keep going")
                        .font(DesignSystem.Typography.headlineLarge)
                        .foregroundStyle(DesignSystem.Colors.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.md)
                        .background(DesignSystem.Colors.teal, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .onAppear {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.spring(response: 0.55, dampingFraction: 0.65)) {
                revealed = true
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Rank up. You reached \(rank.name).")
    }
}

#Preview {
    RankUpView(rank: Gamification.ranks[3])
}
