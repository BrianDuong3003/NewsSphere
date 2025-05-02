//
//  ArticleContentView.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 12/3/25.
//

import UIKit
import Stevia
import Kingfisher

protocol ArticleContentViewDelegate: AnyObject {
    func seeFullContentButtonTapped()
}

class ArticleContentView: UIView {
    
    // MARK: - UI Elements
    private lazy var categoryLabel = UILabel()
    private lazy var titleLabel = UILabel()
    private lazy var articleImageView = UIImageView()
    private lazy var descriptionLabel = UILabel()
    private lazy var contentLabel = UILabel()
    private lazy var sourceLabel = UILabel()
    private lazy var seeFullContentButton = UIButton()
    
    // MARK: - Properties
    weak var delegate: ArticleContentViewDelegate?
    
    private var defaultFontSize: CGFloat = 15.0
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        setupUI()
        setupContrainsts()
    }
    
    // MARK: - Configuration
    func configure(with article: Article, selectedCategory: String? = nil) {
        categoryLabel.text = selectedCategory
        titleLabel.text = article.title
        
        // Configure description
        descriptionLabel.isHidden = article.description?.isEmpty ?? true
        descriptionLabel.text = article.description
        
        // Configure content
        configureContentLabel(with: article)
        
        // Configure source
        if let sourceText = article.sourceName {
            sourceLabel.text = "Source: \(sourceText)"
            if let date = article.formattedDate() {
                sourceLabel.text = "\(sourceLabel.text ?? "") | \(date)"
            }
        } else {
            sourceLabel.text = nil
        }
        
        // Configure image
        configureImageView(with: article.imageUrl)
        
        // Force layout update
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func updateFontSize(_ size: CGFloat) {
        defaultFontSize = size
        
        // Update fonts
        categoryLabel.font = .systemFont(ofSize: size + 3, weight: .semibold)
        titleLabel.font = .systemFont(ofSize: size + 10, weight: .bold)
        descriptionLabel.font = .systemFont(ofSize: size, weight: .medium)
        sourceLabel.font = .systemFont(ofSize: size - 3, weight: .medium)
        
        // Reapply attributed text to contentLabel with new font size
        if let text = contentLabel.text, !text.isEmpty {
            contentLabel.attributedText = createAttributedText(for: text, fontSize: size)
        }
        
        setNeedsLayout()
    }
    
    // configure content label
    private func configureContentLabel(with article: Article) {
        if let content = article.content, !content.isEmpty {
            var fullContent = content
            fullContent = fullContent.replacingOccurrences(of:
                                                            "ONLY AVAILABLE IN PAID PLANS", with: "")
            if fullContent.hasSuffix("...") {
                fullContent = String(fullContent.dropLast(3))
            }
            contentLabel.attributedText = createAttributedText(for: fullContent,
                                                               fontSize: defaultFontSize)
            contentLabel.isHidden = false
        } else if let description = article.description, !description.isEmpty {
            // Fallback to description if content is empty
            let cleanDescription = description.replacingOccurrences(of:
                                                                        "ONLY AVAILABLE IN PAID PLANS", with: "")
            contentLabel.attributedText = createAttributedText(for: description,
                                                               fontSize: defaultFontSize)
            contentLabel.isHidden = false
        } else {
            contentLabel.text = nil
            contentLabel.attributedText = nil
            contentLabel.isHidden = true
        }
    }
    
    private func createAttributedText(for text: String, fontSize: CGFloat) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        return NSAttributedString(
            string: text,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: fontSize),
                .foregroundColor: UIColor.white
            ]
        )
    }
    
    // configure image view and load image
    private func configureImageView(with urlString: String?) {
        articleImageView.image = nil
        
        guard let urlString = urlString, let url = URL(string: urlString) else {
            articleImageView.isHidden = true
            return
        }
        
        articleImageView.isHidden = false
        
        let processor = DownsamplingImageProcessor(size: articleImageView.bounds.size)
        let options: KingfisherOptionsInfo = [
            .processor(processor),
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(0.3)),
            .cacheOriginalImage,
            .backgroundDecode
        ]
        
        articleImageView.kf.indicatorType = .activity
        articleImageView.kf.setImage(
            with: url,
            placeholder: nil,
            options: options,
            completionHandler: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    break
                case .failure(_):
                    self.showPlaceholderImage()
                }
            }
        )
    }
    
    // Helper to show placeholder image
    private func showPlaceholderImage() {
        articleImageView.image = UIImage(named: "placeholder_image") ?? UIImage(systemName: "photo")
        articleImageView.contentMode = .scaleAspectFit
        articleImageView.tintColor = .gray
    }
    
    @objc private func seeFullContentTapped() {
        delegate?.seeFullContentButtonTapped()
    }
}

// MARK: - Setup UI
extension ArticleContentView {
    private func setupUI() {
        backgroundColor = UIColor.hexBackGround
        
        categoryLabel.style {
            $0.text = "Phone"
            $0.textColor = UIColor(named: "hex_Orange")
            $0.font = .systemFont(ofSize: 18, weight: .semibold)
        }
        
        titleLabel.style {
            $0.text = "Apple's foldable iPhone is expected to save a surprisingly declining market"
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 25, weight: .bold)
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
        }
        
        articleImageView.style {
            $0.image = UIImage(named: "ic_example")
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
        }
        
        descriptionLabel.style {
            $0.text = "Apple's foldable iPhone"
            $0.textColor = UIColor(named: "hex_Grey") ?? .lightGray
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
        }
        
        contentLabel.style {
            $0.text = "Foldables are still in their early days"
            $0.textColor = .white
            $0.font = .systemFont(ofSize: 17)
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
        }
        
        sourceLabel.style {
            $0.text = "By Brian Duong"
            $0.textColor = UIColor(named: "hex_Grey") ?? .lightGray
            $0.font = .systemFont(ofSize: 14, weight: .medium)
        }
        
        seeFullContentButton.style {
            $0.setTitle("See Full Content", for: .normal)
            $0.setTitleColor(.hexDarkText, for: .normal)
            $0.backgroundColor = .hexSeefull
            $0.layer.cornerRadius = 5
            $0.clipsToBounds = true
            $0.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
            $0.addTarget(self, action: #selector(seeFullContentTapped), for: .touchUpInside)
        }
    }
    
    private func setupContrainsts() {
        subviews {
            categoryLabel
            titleLabel
            articleImageView
            descriptionLabel
            contentLabel
            sourceLabel
            seeFullContentButton
        }
        
        // Content constraints
        categoryLabel.Top == Top + 15
        categoryLabel.Leading == Leading + 16
        categoryLabel.Trailing == Trailing - 16
        
        titleLabel.Top == categoryLabel.Bottom + 12
        titleLabel.Leading == Leading + 16
        titleLabel.Trailing == Trailing - 16
        
        articleImageView.Top == titleLabel.Bottom + 16
        articleImageView.Leading == Leading + 16
        articleImageView.Trailing == Trailing - 16
        articleImageView.Height == 200
        
        descriptionLabel.Top == articleImageView.Bottom + 20
        descriptionLabel.Leading == Leading + 16
        descriptionLabel.Trailing == Trailing - 16
        
        contentLabel.Top == descriptionLabel.Bottom + 20
        contentLabel.Leading == Leading + 16
        contentLabel.Trailing == Trailing - 16
        
        sourceLabel.Top == contentLabel.Bottom + 20
        sourceLabel.Leading == Leading + 16
        sourceLabel.Trailing == Trailing - 16
        
        seeFullContentButton.Top == sourceLabel.Bottom + 20
        seeFullContentButton.centerHorizontally()
        seeFullContentButton.Width == 140
        seeFullContentButton.Height == 35
        seeFullContentButton.Bottom == Bottom - 20
    }
    
    private func createActionButton(image: UIImage?, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: action, for: .touchUpInside)
        
        // Set button size
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        return button
    }
    
}
