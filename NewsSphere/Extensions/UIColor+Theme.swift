//
//  UIColor+Theme.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 18/5/25.
//

import UIKit

extension UIColor {
    static func themeBackgroundColor() -> UIColor {
        return ThemeManager.shared.currentTheme.isLight ? .white : UIColor(named: "hex_BackGround") ?? .black
    }
    
    // For text colors
    static var primaryTextColor: UIColor {
        return ThemeManager.shared.currentTheme.isLight ? .black : .white
    }
    
    static var secondaryTextColor: UIColor {
        return ThemeManager.shared.currentTheme.isLight ? .darkGray : UIColor(named: "hex_Grey") ?? .lightGray
    }
    
    // For selected categories in light mode
    static var selectedCategoryColor: UIColor {
        return ThemeManager.shared.currentTheme.isLight ? UIColor(named: "hex_Red") ?? .red : UIColor(named: "hex_Orange") ?? .orange
    }
    
    // Convenience accessor for hex colors
    static func hexColor(_ named: String) -> UIColor {
        return UIColor(named: "hex_\(named)") ?? .gray
    }
    
    // Other colors that should adapt to theme changes
    static var cardBackgroundColor: UIColor {
        return ThemeManager.shared.currentTheme.isLight ? .white : UIColor(named: "hex_BackGround") ?? .black
    }
    
    static var borderColor: UIColor {
        return ThemeManager.shared.currentTheme.isLight ? .lightGray : UIColor(named: "hex_Grey") ?? .darkGray
    }
}
