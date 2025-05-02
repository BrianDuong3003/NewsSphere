//
//  TagCollectionViewCell.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 3/20/25.
//
import UIKit
import Stevia

class TagCell: UICollectionViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = UIColor(named: "hex_B1B1B1")
        contentView.layer.cornerRadius = 5
        
        contentView.subviews(titleLabel)
        
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
