//
//  UIViewController+Theme.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 18/5/25.
//

import UIKit

extension UIViewController {
    func applyThemeChanges() {
        view.backgroundColor = .themeBackgroundColor()
        
        updateLabelsForTheme(in: view)
        updateTextFieldsForTheme(in: view)
        updateCollectionViewsForTheme(in: view)
        updateTableViewsForTheme(in: view)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func updateLabelsForTheme(in view: UIView) {
        for subview in view.subviews {
            if let label = subview as? UILabel {
                if label.tag != 999 {
                    label.textColor = .primaryTextColor
                }
            }
            
            updateLabelsForTheme(in: subview)
        }
    }
    
    private func updateTextFieldsForTheme(in view: UIView) {
        for subview in view.subviews {
            if let textField = subview as? UITextField {
                textField.textColor = .primaryTextColor
                textField.backgroundColor = ThemeManager.shared.currentTheme.isLight ? .white : .clear
            }
            
            updateTextFieldsForTheme(in: subview)
        }
    }
    
    private func updateCollectionViewsForTheme(in view: UIView) {
        for subview in view.subviews {
            if let collectionView = subview as? UICollectionView {
                collectionView.backgroundColor = .clear
                collectionView.reloadData()
            }
            
            updateCollectionViewsForTheme(in: subview)
        }
    }
    
    private func updateTableViewsForTheme(in view: UIView) {
        for subview in view.subviews {
            if let tableView = subview as? UITableView {
                tableView.backgroundColor = .themeBackgroundColor()
                tableView.reloadData()
            }
            
            updateTableViewsForTheme(in: subview)
        }
    }
}
