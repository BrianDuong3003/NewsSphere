//
//  VerticalViewCell.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 19/3/25.
//

import UIKit
import Stevia
import SDWebImage

class VerticalViewCell: UICollectionViewCell {
    private lazy var bgView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var authorImage = UIImageView()
    private lazy var authorName = UILabel()
    private lazy var btnLike = UIButton()
    private lazy var btnComment = UIButton()
    private lazy var likeCount = UILabel()
    private lazy var cmtCount = UILabel()
    private lazy var btnEsc = UIButton()
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
        subviews(bgView,
                 authorImage,
                 authorName,
                 titleLabel,
                 likeCount,
                 btnLike,
                 cmtCount,
                 btnComment,
                 btnEsc)
    }
    
    func styleView() {
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        
        bgView.style {
            $0.image = UIImage(named: "rectangle7")
            $0.contentMode = .scaleAspectFit
        }
        
        authorImage.style {
            $0.image = UIImage(named: "ellipse1")
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = 10
            $0.clipsToBounds = true
        }
        
        authorName.style {
            $0.text = "Reuters"
            $0.textColor = .gray
            $0.font = .systemFont(ofSize: 14, weight: .medium)
        }
        
        titleLabel.style {
            $0.text = "Apple's foldable iPhone is expected to save a surprisingly declining market"
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 19, weight: .bold)
            $0.numberOfLines = 3
            $0.lineBreakMode = .byTruncatingTail
        }
        
        btnLike.style {
            $0.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            $0.tintColor = .gray
            $0.size(15)
        }
        
        likeCount.style {
            $0.text = "200"
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = .gray
        }
        cmtCount.style {
            $0.text = "2"
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = .gray
        }
        
        btnComment.style {
            $0.setImage(UIImage(named: "Vector"), for: .normal)
            $0.tintColor = .gray
            $0.size(15)
        }
        
        btnEsc.style {
            $0.setImage(UIImage(systemName: "xmark"), for: .normal)
            $0.tintColor = .gray
            $0.size(15)
        }
    }
    
    func setupConstraints() {
        bgView.height(175)
            .centerHorizontally()
        
        titleLabel.bottom(28)
            .left(8)
            .height(50)
            .width(360)
            .Top == authorImage.Bottom + 10
        
        authorImage.left(8)
            .width(28)
            .height(28)
            .Top == bgView.Bottom + 10
        
        authorName.height(15)
            .Left == authorImage.Right + 8
        align(horizontally: authorImage, authorName)
        
        likeCount.bottom(5).left(8)
        
        btnLike.bottom(6)
            .Left == likeCount.Right + 3
        
        cmtCount.bottom(5)
            .Left == btnLike.Right + 10
        
        btnComment.bottom(5)
            .Left == cmtCount.Right + 3
        
        align(horizontally: btnLike, btnEsc)
        btnEsc.right(8)
    }
    
    func configure(articles: Article) {
        titleLabel.text = articles.title
        authorName.text = articles.sourceName
        
        if let articleImg = articles.imageUrl, let url = URL(string: articleImg) {
            bgView.sd_setImage(with: url, placeholderImage: UIImage(named: "rectangle7"))
        } else {
            bgView.image = UIImage(named: "rectangle7")
        }
        
        if let authorImg = articles.sourceIcon, let url = URL(string: authorImg) {
            authorImage.sd_setImage(with: url, placeholderImage: UIImage(named: "ellipse1"))
        } else {
            authorImage.image = UIImage(named: "ellipse1")
        }
    }
}
