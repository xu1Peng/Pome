import SwiftUI

// 统一的主题配置
struct AppTheme {
    // MARK: - Colors
    static let primaryColor = Color(red: 0.4, green: 0.5, blue: 0.8)  // 蓝紫色
    static let secondaryColor = Color(red: 0.9, green: 0.5, blue: 0.6)  // 粉色
    static let accentColor = Color(red: 0.95, green: 0.4, blue: 0.5)  // 红粉色
    static let backgroundColor = Color(UIColor(red: 246/255.0, green: 243/255.0, blue: 238/255.0, alpha: 1.0))
    static let cardBackground = Color.white
    static let textPrimary = Color(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0))
    static let textSecondary = Color(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0))
    static let dividerColor = Color(UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0))
    
    // MARK: - Spacing
    static let spacing_xs: CGFloat = 4
    static let spacing_sm: CGFloat = 8
    static let spacing_md: CGFloat = 12
    static let spacing_lg: CGFloat = 16
    static let spacing_xl: CGFloat = 20
    static let spacing_xxl: CGFloat = 24
    
    // MARK: - Corner Radius
    static let cornerRadius_sm: CGFloat = 8
    static let cornerRadius_md: CGFloat = 12
    static let cornerRadius_lg: CGFloat = 16
    
    // MARK: - Shadow
    static let shadowColor = Color.black.opacity(0.1)
    static let shadowRadius: CGFloat = 4
    static let shadowOffset = CGSize(width: 0, height: 2)
}

// 扩展 Color 以便快速访问主题颜色
extension Color {
    static let themePrimary = AppTheme.primaryColor
    static let themeSecondary = AppTheme.secondaryColor
    static let themeAccent = AppTheme.accentColor
    static let themeBackground = AppTheme.backgroundColor
    static let themeCard = AppTheme.cardBackground
    static let themePrimaryText = AppTheme.textPrimary
    static let themeSecondaryText = AppTheme.textSecondary
    static let themeDivider = AppTheme.dividerColor
}

