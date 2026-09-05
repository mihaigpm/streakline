import SwiftUI

/// Central design tokens: colors, typography, spacing, and corner radii.
enum DesignSystem {

    // MARK: - Colors

    enum Colors {
        static let background = Color(hex: 0x0A0A0F)
        static let surface = Color(hex: 0x13131A)
        static let surfaceHigh = Color(hex: 0x1C1C26)
        static let border = Color(hex: 0x2A2A38)

        /// Brand colors are sourced from the asset catalog (single source of truth).
        static let teal = Color("BrandTeal")
        static let tealDim = teal.opacity(0.15)

        static let amber = Color("BrandAmber")
        static let amberDim = amber.opacity(0.15)

        static let red = Color(hex: 0xFF4D4D)

        static let textPrimary = Color(hex: 0xFFFFFF)
        static let textSecondary = Color(hex: 0x8888A0)
        static let textTertiary = Color(hex: 0x555568)
    }

    // MARK: - Typography

    enum Typography {
        static let displayLarge = Font.system(.largeTitle, design: .rounded, weight: .black)
        static let displayMedium = Font.system(.largeTitle, design: .rounded, weight: .black)
        static let displaySmall = Font.system(.title, design: .rounded, weight: .bold)
        static let headlineLarge = Font.system(.title3, design: .rounded, weight: .bold)
        static let headlineSmall = Font.system(.headline, design: .rounded, weight: .semibold)
        static let labelLarge = Font.system(.subheadline, design: .rounded, weight: .semibold)
        static let labelSmall = Font.system(.caption, design: .rounded, weight: .medium)
        static let body = Font.body
        static let bodySmall = Font.subheadline
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner radius

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 14
        static let lg: CGFloat = 20
        static let xl: CGFloat = 28
    }

    // MARK: - Animation

    enum Motion {
        static let ring = Animation.spring(response: 0.5, dampingFraction: 0.7)
        static let cardPulse = Animation.spring(response: 0.35, dampingFraction: 0.6)
    }
}

extension Color {
    /// Build a fully opaque color from a 0xRRGGBB integer.
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
