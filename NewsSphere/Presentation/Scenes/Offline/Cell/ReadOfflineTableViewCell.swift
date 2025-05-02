//
//  ReadOfflineTableViewCell.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 14/3/25.
//

import UIKit
import Stevia
import Kingfisher

class ReadOfflineTableViewCell: UITableViewCell {
    static let identifier = "ReadOfflineTableViewCell"
    
    private lazy var articleTitle = UILabel()
    private lazy var articleImage = UIImageView()
    private lazy var timeLabel = UILabel()
    private lazy var sourceName = UILabel()
    private lazy var indicatorView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        setupUI()
        setupContrainsts()
    }
    
    // Configure cell with article data
    func configure(with article: Article, timeAgo: String) {
        articleTitle.text = article.title
        
        if let imageUrlString = article.imageUrl, let url = URL(string: imageUrlString) {
            articleImage.kf.setImage(with: url, placeholder: UIImage(named: "ic_example"))
        } else {
            articleImage.image = UIImage(named: "ic_example")
        }
        
        timeLabel.text = timeAgo
        sourceName.text = article.sourceName
    }
}

// MARK: - Setup UI
extension ReadOfflineTableViewCell {
    private func setupUI() {
        articleTitle.style {
            $0.font = .systemFont(ofSize: 15, weight: .medium)
            $0.numberOfLines = 0
            $0.textColor = .white
        }
        
        articleImage.style {
            $0.image = UIImage(named: "ic_example")
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 5
        }
        
        timeLabel.style {
            $0.text = "15h"
            $0.font = .systemFont(ofSize: 13, weight: .medium)
            $0.textColor = UIColor.hexGrey
        }
        
        sourceName.style {
            $0.text = "ABC News"
            $0.font = .systemFont(ofSize: 13, weight: .medium)
            $0.textColor = UIColor.hexGrey
        }
        
        indicatorView.style {
            $0.backgroundColor = .lightGray
        }
    }
    
    private func setupContrainsts() {
        subviews {
            articleTitle
            articleImage
            timeLabel
            sourceName
            indicatorView
        }
        
        articleTitle.Top == contentView.Top + 5
        articleTitle.Leading == contentView.Leading + 10
        articleTitle.Trailing == articleImage.Leading - 5
        
        articleImage.CenterY == articleTitle.CenterY
        articleImage.Trailing == contentView.Trailing - 10
        articleImage.width(70).height(70)

        timeLabel.Top == articleTitle.Bottom + 20
        timeLabel.Leading == contentView.Leading + 10
        
        sourceName.CenterY == timeLabel.CenterY
        sourceName.Leading == timeLabel.Trailing + 20
        
        indicatorView.Top == timeLabel.Bottom + 15
        indicatorView.Leading == contentView.Leading + 10
        indicatorView.Trailing == contentView.Trailing - 10
        indicatorView.Bottom == contentView.Bottom - 20
        indicatorView.Height == 1
    }
}
