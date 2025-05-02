//
//  UIColor+Gradient.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 25/3/25.
//
import UIKit

extension UIButton {
    func setGradientText(startColor: UIColor, endColor: UIColor) {
        guard let title = self.currentTitle else { return }
        
        let size = CGSize(width: 200, height: 30)
        let image = UIGraphicsImageRenderer(size: size).image { context in
            let gradient = CAGradientLayer()
            gradient.frame = CGRect(origin: .zero, size: size)
            gradient.colors = [startColor.cgColor, endColor.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            gradient.render(in: context.cgContext)
        }
        
        self.setTitleColor(.clear, for: .normal)
        self.setAttributedTitle(NSAttributedString(string: title, attributes: [
            .foregroundColor: UIColor(patternImage: image)
        ]), for: .normal)
    }
}
