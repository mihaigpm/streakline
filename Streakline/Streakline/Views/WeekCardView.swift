import SwiftUI

/// A fixed picture of one week. Drawn for `ImageRenderer`, not a scrolling page.
struct WeekCardView: View {
    let seal: WeekSeal
    var includeDrinks: Bool

    static let width: CGFloat = 360
    static let height: CGFloat = 450

    private var captions: [WeekSeal.CardCaption] {
        seal.cardCaptions(includeDrinks: includeDrinks)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            ForEach(captions) { caption in
                if caption.kind == .site {
                    Spacer(minLength: DesignSystem.Spacing.lg)
                }
                Text(caption.text)
                    .font(font(for: caption.kind))
                    .foregroundStyle(color(for: caption))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(width: Self.width, height: Self.height, alignment: .topLeading)
        .background(DesignSystem.Colors.background)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                .strokeBorder(DesignSystem.Colors.border, lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier("week.card")
        .accessibilityLabel(captions.map(\.text).joined(separator: "\n"))
    }

    private func font(for kind: WeekSeal.CardCaption.Kind) -> Font {
        switch kind {
        case .brand, .slots: DesignSystem.Typography.displaySmall
        case .season: DesignSystem.Typography.headlineLarge
        case .drinks: DesignSystem.Typography.headlineSmall
        case .money: DesignSystem.Typography.bodySmall
        case .outcome: DesignSystem.Typography.displayMedium
        case .site: DesignSystem.Typography.labelSmall
        }
    }

    private func color(for caption: WeekSeal.CardCaption) -> Color {
        switch caption.kind {
        case .brand, .slots: DesignSystem.Colors.teal
        case .season: DesignSystem.Colors.textPrimary
        case .drinks: drinkColor
        case .money: DesignSystem.Colors.amber
        case .outcome: outcomeColor
        case .site: DesignSystem.Colors.textTertiary
        }
    }

    private var drinkColor: Color {
        seal.drinks > Double(seal.budget) ? DesignSystem.Colors.red : DesignSystem.Colors.amber
    }

    private var outcomeColor: Color {
        switch seal.outcome {
        case .perfect, .held: DesignSystem.Colors.teal
        case .shieldUsed: DesignSystem.Colors.amber
        case .missed: DesignSystem.Colors.red
        }
    }
}

#Preview {
    let week = AppWeek(
        weekNumber: 4,
        startDate: .now,
        startingDrinkBudget: 10,
        drinkUnit: .pints,
        budgetRule: .guideline
    )
    let drink = DrinkLog(amount: 3)
    drink.week = week
    week.drinkLogs.append(drink)
    return WeekCardView(
        seal: WeekSeal(week: week, now: .now, isOpenWeek: true, shieldAvailable: false),
        includeDrinks: true
    )
    .preferredColorScheme(.dark)
}
