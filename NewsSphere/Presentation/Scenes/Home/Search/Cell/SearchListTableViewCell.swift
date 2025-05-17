//
//  SearchListTableViewCell.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 12/3/25.
//
import UIKit
import Stevia

protocol SearchListTableViewCellDelegate: AnyObject {
    func didTapOptionButton(in cell: SearchListTableViewCell)
}

class SearchListTableViewCell: UITableViewCell {
    static let identifier = "SearchListTableViewCell"
    weak var delegate: SearchListTableViewCellDelegate?
    private lazy var iconSearch = UIImageView()
    public lazy var nameSearch = UILabel()
    private lazy var deleteButton = UIButton()
    public var keyword: String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        
        // Apply initial theme
        updateThemeBasedUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func themeChanged() {
        updateThemeBasedUI()
    }
    
    private func updateThemeBasedUI() {
        let isLightMode = ThemeManager.shared.currentTheme.isLight
        
        // Update text colors based on theme
        nameSearch.textColor = isLightMode ? .black : .white
        
        // Update icon colors
        iconSearch.tintColor = .secondaryTextColor
        deleteButton.tintColor = .secondaryTextColor
    }
    
    func configure(with keyword: String) {
        nameSearch.text = keyword
        self.keyword = keyword
        
        // Apply theme after configuration
        updateThemeBasedUI()
    }
    
    @objc private func deleteTapped() {
        delegate?.didTapOptionButton(in: self)
    }
}

extension SearchListTableViewCell {
    private func setupView() {
        contentView.subviews {
            iconSearch
            nameSearch
            deleteButton
        }
    }
    
    private func setupStyle() {
        backgroundColor = .clear 
        selectionStyle = .none
        
        iconSearch.image = UIImage(named: "ic_search")
        iconSearch.contentMode = .scaleAspectFit
        
        nameSearch.font = .systemFont(ofSize: 14, weight: .regular)
        nameSearch.numberOfLines = 1
        nameSearch.lineBreakMode = .byTruncatingTail
        nameSearch.setContentHuggingPriority(.defaultLow, for: .horizontal)
        nameSearch.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        deleteButton.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
    }
    
    private func setupConstraints() {
        iconSearch.left(16).centerVertically().width(22).height(22)
        deleteButton.right(16).centerVertically().width(18).height(18)
        
        nameSearch.centerVertically()
        nameSearch.Left == iconSearch.Right + 12
        nameSearch.Right == deleteButton.Left - 12
    }
}
