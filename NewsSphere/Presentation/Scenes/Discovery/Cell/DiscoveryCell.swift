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
        config()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config() {
        setupViews()
        setupConstraints()
        styleViews()
    }
    
    func configure(with title: String, image: UIImage) {
        titleLabel.text = title
        imageView.image = image
    }
}

extension DiscoveryCell {
    func setupViews() {
        subviews {
            imageView
            bgView
            titleLabel
            horizontalDivider
        }
    }
    
    func setupConstraints() {
        imageView.fillContainer()
        
        bgView.fillContainer()
        
        titleLabel.centerInContainer()
        horizontalDivider
            .left(15)
            .right(15)
            .height(1)
            .Top == titleLabel.Bottom + 10
    }
    
    func styleViews() {
        roundCorners([.allCorners], radius: 10)
        
        bgView.style {
            $0.backgroundColor = .black.withAlphaComponent(0.1)
        }
        titleLabel.style {
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 18, weight: .bold)
        }
        
        imageView.style {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.backgroundColor = .gray
        }
        
        horizontalDivider.style {
            $0.backgroundColor = .white
        }
    }
}
