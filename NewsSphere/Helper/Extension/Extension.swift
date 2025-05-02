//
//  Extension.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 13/3/25.
//

import Foundation
import UIKit

extension UIView {
    func addShadowMain(color: UIColor = .black,
                       opacity: Float = 0.1,
                       offset: CGSize = CGSize(width: 2, height: 2),
                       radius: CGFloat = 4) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
}
