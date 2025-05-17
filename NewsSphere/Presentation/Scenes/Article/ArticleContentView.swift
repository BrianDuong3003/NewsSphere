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
        setupStyle()
        setupConstraints()
        
        // Add theme change observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeChanged),
            name: ThemeManager.themeChangedNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupStyle()
        setupConstraints()
        
        // Add theme change observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeChanged),
            name: ThemeManager.themeChangedNotification,
            object: nil
        )
    }
    
    @objc private func themeChanged() {
        updateTheme()
    }
    
    func updateTheme() {
        backgroundColor = .themeBackgroundColor()
        titleLabel.textColor = .primaryTextColor
        descriptionLabel.textColor = .secondaryTextColor
        sourceLabel.textColor = .secondaryTextColor
        if let text = contentLabel.text, !text.isEmpty {
            contentLabel.attributedText = createAttributedText(for: text, fontSize: defaultFontSize)
        }
    }
    
    private func setupView() {
        subviews {
            categoryLabel
            titleLabel
            articleImageView
            descriptionLabel
            contentLabel
            sourceLabel
            seeFullContentButton
        }
    }
    
    // MARK: - Configuration
    func configure(with article: Article, selectedCategory: String? = nil) {
        categoryLabel.text = selectedCategory
        titleLabel.text = article.title
        
        descriptionLabel.isHidden = article.description?.isEmpty ?? true
        descriptionLabel.text = article.description
        
        configureContentLabel(with: article)
        
        if let sourceText = article.sourceName {
            sourceLabel.text = "Source: \(sourceText)"
            if let date = article.formattedDate() {
                sourceLabel.text = "\(sourceLabel.text ?? "") | \(date)"
            }
        } else {
            sourceLabel.text = nil
        }
        
        configureImageView(with: article.imageUrl)
        
        updateTheme()
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func updateFontSize(_ size: CGFloat) {
        defaultFontSize = size
        
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
            contentLabel.text = fullContent // Store plain text for later use
            contentLabel.attributedText = createAttributedText(for: fullContent,
                                                               fontSize: defaultFontSize)
            contentLabel.isHidden = false
        } else if let description = article.description, !description.isEmpty {
            // Fallback to description if content is empty
            let cleanDescription = description.replacingOccurrences(of:
                                                                        "ONLY AVAILABLE IN PAID PLANS", with: "")
            contentLabel.text = cleanDescription // Store plain text for later use
            contentLabel.attributedText = createAttributedText(for: cleanDescription,
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
                .foregroundColor: UIColor.primaryTextColor
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
        articleImageView.tintColor = .secondaryTextColor
    }
    
    @objc private func seeFullContentTapped() {
        delegate?.seeFullContentButtonTapped()
    }
}

// MARK: - Setup UI
extension ArticleContentView {
    private func setupStyle() {
        backgroundColor = .themeBackgroundColor()
        
        categoryLabel.text = "Phone"
        categoryLabel.textColor = UIColor(named: "hex_Orange")
        categoryLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        titleLabel.text = "Apple's foldable iPhone is expected to save a surprisingly declining market"
        titleLabel.textColor = .primaryTextColor
        titleLabel.font = .systemFont(ofSize: 25, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        
        articleImageView.image = UIImage(named: "ic_example")
        articleImageView.contentMode = .scaleAspectFill
        articleImageView.clipsToBounds = true
        articleImageView.layer.cornerRadius = 8
        
        descriptionLabel.text = "Apple's foldable iPhone"
        descriptionLabel.textColor = .secondaryTextColor
        descriptionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        
        contentLabel.text = "Foldables are still in their early days"
        contentLabel.textColor = .primaryTextColor
        contentLabel.font = .systemFont(ofSize: 17)
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping
        
        sourceLabel.text = "By Brian Duong"
        sourceLabel.textColor = .secondaryTextColor
        sourceLabel.font = .systemFont(ofSize: 14, weight: .medium)
        
        seeFullContentButton.setTitle("See Full Content", for: .normal)
        seeFullContentButton.setTitleColor(.hexDarkText, for: .normal)
        seeFullContentButton.backgroundColor = .hexSeefull
        seeFullContentButton.layer.cornerRadius = 5
        seeFullContentButton.clipsToBounds = true
        seeFullContentButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        seeFullContentButton.addTarget(self, action: #selector(seeFullContentTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
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
