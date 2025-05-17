//
//  UIView+Theme.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 18/5/25.
//

import UIKit

extension UIView {
    func applyThemeChanges() {
        backgroundColor = .themeBackgroundColor()
        
        if layer.borderWidth > 0 {
            layer.borderColor = UIColor.borderColor.cgColor
        }
        
        updateLabelsForTheme()
        updateButtonsForTheme()
    }
    
    private func updateLabelsForTheme() {
        subviews.forEach { subview in
            if let label = subview as? UILabel {
                if label.tag != 999 {
                    label.textColor = .primaryTextColor
                }
            }
            
            subview.updateLabelsForTheme()
        }
    }
    
    private func updateButtonsForTheme() {
        subviews.forEach { subview in
            if let button = subview as? UIButton {
                if button.tag != 999 {
                    button.setTitleColor(.primaryTextColor, for: .normal)
                }
            }
            
            subview.updateButtonsForTheme()
        }
    }
}
