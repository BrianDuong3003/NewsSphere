//
//  HorizontalViewCell.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 19/3/25.
//

import UIKit
import Stevia

class HorizontalViewCell: UICollectionViewCell {
    private lazy var bgImage = UIImageView()
    private lazy var title = UILabel()
    private lazy var authorImage = UIImageView()
    private lazy var authorName = UILabel()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        styleView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        styleView()
        setupConstraints()
    }
    
    // MARK: - Setup View
    private func setupView() {
        subviews(bgImage, title, authorImage, authorName)
    }
    
    func styleView() {
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = .brown
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.clipsToBounds = true
        
        bgImage.style {
            $0.contentMode = .scaleAspectFill
            $0.image = UIImage(named: "rectangle5")
        }
        
        authorImage.style {
            $0.image = UIImage(named: "ellipse1")
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = 10
            $0.clipsToBounds = true
        }
        
        authorName.style {
            $0.text = "U.S.News"
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 15, weight: .medium)
        }
        
        title.style {
            $0.text = "Political Storms Hit Florida Before Hurricane Milton Makes Landfall"
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.numberOfLines = 3
            $0.lineBreakMode = .byTruncatingTail
        }
    }
    
    func setupConstraints() {
        bgImage.height(200)
            .centerHorizontally()
        
        authorImage.left(20)
            .width(30)
            .height(30)
        
        align(horizontally: authorImage, authorName)
        authorName.Left == authorImage.Right + 8
        title.bottom(20)
            .left(40)
            .right(15)
            .width(340)
            .height(40)
            .Top == authorImage.Bottom + 15
    }
    
    func configure(articles: Article) {
        title.text = articles.title
        authorName.text = articles.sourceName
        
        if let articleImg = articles.imageUrl, let url = URL(string: articleImg) {
            bgImage.sd_setImage(with: url, placeholderImage: UIImage(named: "rectangle5"))
        } else {
            bgImage.image = UIImage(named: "rectangle5")
        }
        
        if let authorImg = articles.sourceIcon, let url = URL(string: authorImg) {
            authorImage.sd_setImage(with: url, placeholderImage: UIImage(named: "ellipse1"))
        } else {
            authorImage.image = UIImage(named: "ellipse1")
        }
    }
}
