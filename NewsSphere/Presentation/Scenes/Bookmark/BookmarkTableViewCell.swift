import UIKit
import Stevia
import SDWebImage
class BookmarkTableViewCell: UITableViewCell {
    static let identifier = "BookmarkTableViewCell"
    
    private lazy var articleTitle = UILabel()
    private lazy var articleImage = UIImageView()
    private lazy var likeButton = UIButton()
    private lazy var numberOfLike = UILabel()
    private lazy var timeLabel = UILabel()
    private lazy var sourceName = UILabel()
    private lazy var indicatorView = UIView()
    
    private var like: Int = 0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with article: Article) {
        articleTitle.text = article.title
        timeLabel.text = timeAgoString(from: article.pubDate ?? "")
        sourceName.text = article.sourceName
        if let articleImg = article.imageUrl, let url = URL(string: articleImg) {
            articleImage.sd_setImage(with: url, placeholderImage: UIImage(named: "rectangle7"))
        } else {
            articleImage.image = UIImage(named: "rectangle7")
        }
        
    }
    
    private func timeAgoString(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let day = components.day, day > 0 {
            return "\(day * 24 + (components.hour ?? 0)) giờ trước"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour) giờ trước"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute) phút trước"
        } else {
            return "Vừa xong"
        }
    }
    
    
    private func setupUI() {
        
        articleTitle.style {
            $0.text = """
                    Trump suggests Canada become 51st state after Trudeau said tariff would kill economy: sources
                    """
            $0.font = .systemFont(ofSize: 15, weight: .medium)
            $0.numberOfLines = 0
            $0.textColor = .white
        }
        
        articleImage.style {
            $0.image = UIImage(named: "image")
            $0.contentMode = .scaleAspectFill
        }
        
        likeButton.style {
            $0.setImage(UIImage(named: "ic_like"), for: .normal)
            $0.setImage(UIImage(named: "ic_like_selected"), for: .selected)
            $0.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        }
        
        numberOfLike.style {
            $0.text = "0"
            $0.font = .systemFont(ofSize: 13, weight: .medium)
            $0.textColor = .hexGrey
        }
        
        timeLabel.style {
            $0.text = "3h"
            $0.font = .systemFont(ofSize: 13, weight: .medium)
            $0.textColor = .hexGrey
        }
        
        sourceName.style {
            $0.text = "Fox News"
            $0.font = .systemFont(ofSize: 13, weight: .medium)
            $0.textColor = .hexGrey
        }
        
        indicatorView.style {
            $0.backgroundColor = .hexDarkGrey
        }
    }
    
    private func setupConstraints() {
        subviews {
            articleTitle
            articleImage
            likeButton
            numberOfLike
            timeLabel
            sourceName
            indicatorView
        }
        
        articleImage.Top == contentView.Top + 10
        articleImage.Trailing == contentView.Trailing - 10
        articleImage.Width == 120
        articleImage.Height == 80
        articleImage.layer.cornerRadius = 8
        articleImage.clipsToBounds = true
        
        articleTitle.Top == contentView.Top + 10
        articleTitle.Leading == contentView.Leading + 10
        articleTitle.Trailing == articleImage.Leading - 10
        
        likeButton.Top == articleTitle.Bottom + 10
        likeButton.Leading == contentView.Leading + 12
        likeButton.Bottom == indicatorView.Top - 10
        
        numberOfLike.CenterY == likeButton.CenterY
        numberOfLike.Leading == likeButton.Trailing + 5
        
        timeLabel.CenterY == likeButton.CenterY
        timeLabel.Leading == numberOfLike.Trailing + 15
        
        sourceName.CenterY == likeButton.CenterY
        sourceName.Leading == timeLabel.Trailing + 15
        
        indicatorView.Leading == contentView.Leading + 10
        indicatorView.Trailing == contentView.Trailing - 10
        indicatorView.Top >= articleImage.Bottom + 10
        indicatorView.Bottom == contentView.Bottom
        indicatorView.Height == 1
    }
    
    @objc private func likeButtonTapped() {
        likeButton.isSelected.toggle()
        if likeButton.isSelected {
            like += 1
        } else {
            like -= 1
        }
        numberOfLike.text = "\(like)"
    }
}
