//
//  TagCollectionViewCell.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 3/20/25.
//
import UIKit
import Stevia

class TagCell: UICollectionViewCell {
    private lazy var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupStyle()
        setupConstraints()
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
        contentView.backgroundColor = UIColor(named: "hex_B1B1B1")
        contentView.layer.cornerRadius = 5
        
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .white
    }
    
    private func setupConstraints() {
        contentView.layout(
            12,
            |-12-titleLabel-12-|,
            12
        )
    }
    
    func configure(with text: String) {
        titleLabel.text = text
    }
}
