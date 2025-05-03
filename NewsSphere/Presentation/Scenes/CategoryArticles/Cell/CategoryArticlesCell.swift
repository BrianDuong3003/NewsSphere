//
//  PoliticsCell.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 7/4/25.
//

import UIKit
import Stevia

class CategoryArticlesCell: UICollectionViewCell {
    private lazy var picture = UIImageView()
    private lazy var sourceIcon = UIImageView()
    private lazy var sourceName = UILabel()
    private lazy var titleLabel = UILabel()
    private lazy var bottomView = UIView()
    private lazy var countLikeLB = UILabel()
    private lazy var countCommentLB = UILabel()
    private lazy var likeImage = UIImageView()
    private lazy var commentImage = UIImageView()
    private lazy var categoryLB = UILabel()
    private lazy var deleteButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupStyle()
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sourceIcon.layer.cornerRadius = sourceIcon.frame.width / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with article: Article) {
        titleLabel.text = article.title
        sourceName.text = article.sourceName
        categoryLB.text = article.category?.first?.capitalized ?? "Unknown"
        
        countLikeLB.text = "200"
        countCommentLB.text = "2"
        
        if let imageUrl = article.imageUrl, let url = URL(string: imageUrl) {
            picture.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder_image"))
        } else {
            picture.image = UIImage(named: "placeholder_image")
        }
        
        if let iconUrl = article.sourceIcon, let url = URL(string: iconUrl) {
            sourceIcon.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder_icon"))
        } else {
            sourceIcon.image = UIImage(named: "placeholder_icon")
        }
    }
}

extension CategoryArticlesCell {
    private func setupView() {
        subviews {
            picture
            sourceIcon
            sourceName
            titleLabel
            bottomView.subviews {
                countLikeLB
                likeImage
                countCommentLB
                commentImage
                categoryLB
            }
        }
    }
    
    private func setupStyle() {
        picture.layer.cornerRadius = 8
        picture.clipsToBounds = true
        
        sourceName.textColor = .hexGrey
        sourceName.font = .systemFont(ofSize: 14, weight: .regular)
        
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.numberOfLines = 0
        
        countLikeLB.text = "200"
        countLikeLB.textColor = .gray
        countLikeLB.font = .systemFont(ofSize: 12)
        
        countCommentLB.text = "2"
        countCommentLB.textColor = .gray
        countCommentLB.font = .systemFont(ofSize: 12)
        
        likeImage.image = .like
        
        commentImage.image = .comment
        
        categoryLB.textColor = .red
        categoryLB.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    private func setupConstraints() {
        picture.top(0).fillHorizontally().height(175)
        sourceIcon.left(0).width(23).height(23)
        bottomView.height(20).fillHorizontally()
        countLikeLB.left(0).fillVertically()
        likeImage.width(15).height(15)
        commentImage.width(15).height(15)
        
        sourceIcon.Top == picture.Bottom + 10
        
        sourceName.top(13)
        sourceName.Left == sourceIcon.Right + 9
        
        titleLabel.fillHorizontally()
        titleLabel.Top == sourceIcon.Bottom + 10
        
        bottomView.Top == titleLabel.Bottom + 2
        
        likeImage.Left == countLikeLB.Right
        
        countCommentLB.Left == likeImage.Right + 2
        commentImage.Left == countCommentLB.Right + 2
        
        categoryLB.Left == commentImage.Right + 20
    }
}
