//
//  DiscoveryCell.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 13/3/25.
//

import UIKit
import Stevia

class DiscoveryCell: UICollectionViewCell {
    private lazy var imageView = UIImageView()
    private lazy var bgView = UIView()
    private lazy var titleLabel = UILabel()
    private lazy var horizontalDivider = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupStyle()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String, image: UIImage) {
        titleLabel.text = title
        imageView.image = image
    }
}

extension DiscoveryCell {
    private func setupView() {
        subviews {
            imageView
            bgView
            titleLabel
            horizontalDivider
        }
    }
    
    private func setupConstraints() {
        imageView.fillContainer()
        bgView.fillContainer()
        titleLabel.centerInContainer()
        
        horizontalDivider.left(15).right(15).height(1)
        horizontalDivider.Top == titleLabel.Bottom + 10
    }
    
    
    private func setupStyle() {
        roundCorners([.allCorners], radius: 10)
        
        bgView.backgroundColor = .black.withAlphaComponent(0.1)
        
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .gray
        
        horizontalDivider.backgroundColor = .white
    }
}
