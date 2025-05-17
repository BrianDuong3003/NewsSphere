//
//  TagCell.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 20/3/25.
//
import UIKit
import Stevia

class TagCell: UICollectionViewCell {
    private lazy var titleLabel = UILabel()
    private var isTagSelected = false
    
    // MARK: - Constants for Styling
    private let selectedBorderColor = UIColor.white.cgColor
    private let unselectedBorderColor = UIColor(white: 0.7, alpha: 1.0).cgColor
    private let borderWidth: CGFloat = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupStyle()
        setupConstraints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: NSNotification.Name("ThemeChangedNotification"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.subviews {
            titleLabel
        }
    }
    
    private func setupStyle() {
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = borderWidth
        
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = ThemeManager.shared.currentTheme.isLight ? .black : .white
        titleLabel.textAlignment = .center
    }
    
    private func setupConstraints() {
        contentView.layout(
            10,
            |-10-titleLabel-10-|,
            10
        )
    }
    
    func configure(with text: String, isSelected: Bool = false) {
        titleLabel.text = text
        self.isTagSelected = isSelected
        updateAppearance()
    }
    
    @objc private func themeChanged() {
        updateAppearance()
    }
    
    private func updateAppearance() {
        let isLightMode = ThemeManager.shared.currentTheme.isLight
        
        if isTagSelected {
            if let startColor = UIColor(named: "hex_Brown"),
               let endColor = UIColor(named: "hex_DarkRed") {
                setGradientBackground(startColor: startColor, endColor: endColor)
            }
            titleLabel.textColor = .white
            contentView.layer.borderColor = selectedBorderColor
        } else {
            // Interface when not selected
            contentView.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
            contentView.backgroundColor = .themeBackgroundColor()
            titleLabel.textColor = isLightMode ? .black : .white
            contentView.layer.borderColor = isLightMode ? UIColor.lightGray.cgColor : unselectedBorderColor
        }
    }
    
    private func setGradientBackground(startColor: UIColor, endColor: UIColor) {
        contentView.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = contentView.bounds
        gradientLayer.cornerRadius = contentView.layer.cornerRadius
        
        contentView.layer.insertSublayer(gradientLayer, at: 0)
        contentView.backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = contentView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            gradientLayer.frame = contentView.bounds
        }
    }
}
