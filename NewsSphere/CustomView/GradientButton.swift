//
//  GradientButton.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 3/25/25.
//

import UIKit

class GradientButton: UIButton {
    
    private let gradient = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGradient() {
        gradient.frame = bounds
        
        gradient.colors = [UIColor.systemCyan.cgColor, UIColor.systemBlue.cgColor]
        
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)    
        
        layer.addSublayer(gradient)
    }
    
    func setGradientColors(startColor: UIColor, endColor: UIColor) {
        gradient.colors = [startColor.cgColor, endColor.cgColor]
    }
    
    func setGradientDirection(startPoint: CGPoint, endPoint: CGPoint) {
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
}
