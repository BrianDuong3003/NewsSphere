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
    private lazy var title = UILabel()
    private lazy var bottomView = UIView()
    private lazy var countLikeLB = UILabel()
    private lazy var countCommentLB = UILabel()
    private lazy var likeImage = UIImageView()
    private lazy var commentImage = UIImageView()
    private lazy var categoryLB = UILabel()
    private lazy var deleteBtn = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        styleView()
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
        title.text = article.title
        sourceName.text = article.sourceName
        categoryLB.text = article.category?.first?.capitalized ?? "Unknown"
        
        countLikeLB.text = "200"
        countCommentLB.text = "2"
        
        if let imageUrl = article.imageUrl, let url = URL(string: imageUrl) {
            downloadImage(from: url) { image in
                DispatchQueue.main.async {
                    self.picture.image = image ?? UIImage(named: "placeholder_image")
                }
            }
        } else {
            picture.image = UIImage(named: "placeholder_image")
        }
        
        if let iconUrl = article.sourceIcon, let url = URL(string: iconUrl) {
            downloadImage(from: url) { image in
                DispatchQueue.main.async {
                    self.sourceIcon.image = image ?? UIImage(named: "placeholder_icon")
                }
            }
        } else {
            sourceIcon.image = UIImage(named: "placeholder_icon")
        }
    }
    
    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }
        task.resume()
    }
}

extension CategoryArticlesCell {
    func setupView() {
        subviews {
            picture
            sourceIcon
            sourceName
            title
            bottomView
        }
        
        bottomView.subviews {
            countLikeLB
            likeImage
            countCommentLB
            commentImage
            categoryLB
        }
    }
    
    func styleView() {
        picture.style {
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
        }
        
        sourceName.style {
            $0.textColor = .hexGrey
            $0.font = .systemFont(ofSize: 14, weight: .regular)
        }
        
        title.style {
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 18, weight: .bold)
            $0.numberOfLines = 0
        }
        
        countLikeLB.style {
            $0.text = "200"
            $0.textColor = .gray
            $0.font = .systemFont(ofSize: 12)
        }
        
        countCommentLB.style {
            $0.text = "2"
            $0.textColor = .gray
            $0.font = .systemFont(ofSize: 12)
        }
        
        likeImage.style {
            $0.image = .like
        }
        
        commentImage.style {
            $0.image = .comment
        }
        
        categoryLB.style {
            $0.textColor = .red
            $0.font = .systemFont(ofSize: 14, weight: .medium)
        }
    }
    
    func setupConstraints() {
        picture
            .top(0)
            .fillHorizontally()
            .height(175)
        
        sourceIcon
            .left(0)
            .width(23)
            .height(23)
            .Top == picture.Bottom + 10
        
        sourceName
            .top(13)
            .Left == sourceIcon.Right + 9
        
        title
            .fillHorizontally()
            .Top == sourceIcon.Bottom + 10
        
        bottomView
            .height(20)
            .fillHorizontally()
            .Top == title.Bottom + 2
        
        countLikeLB
            .left(0)
            .fillVertically()
        
        likeImage
            .width(15)
            .height(15)
            .Left == countLikeLB.Right
        
        countCommentLB
            .Left == likeImage.Right + 2
        commentImage
            .width(15)
            .height(15)
            .Left == countCommentLB.Right + 2
        
        categoryLB.Left == commentImage.Right + 20
    }
}
