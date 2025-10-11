//
//  TopBarView.swift
//  NewsSphere
//  Created by DUONG DONG QUAN on 18/3/25.
//

import UIKit
import Stevia

protocol TopBarViewDelegate: AnyObject {
    func topBarView(_ view: TopBarView, didSelectCategory category: String)
}

class TopBarView: UIView {
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    var labels = [UILabel]()
    
    weak var delegate: TopBarViewDelegate?
    private var labelCategoryMap: [UILabel: NewsCategoryType] = [:]
    private var categoryLabelMap: [String: UILabel] = [:] // map from category.apiValue to corresponding label
    private var favoriteCategoryRepository: FavoriteCategoryRepositoryProtocol
    private var currentCategory: String? // store current category
    private let backgroundQueue = DispatchQueue(label: "com.newssphere.topbar", qos: .userInitiated)
    
    init(frame: CGRect, repository: FavoriteCategoryRepositoryProtocol = FavoriteCategoryRepository()) {
        self.favoriteCategoryRepository = repository
        super.init(frame: frame)
        setupUI()
        backgroundColor = .clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: NSNotification.Name("ThemeChangedNotification"), object: nil)
    }
    
    override init(frame: CGRect) {
        self.favoriteCategoryRepository = FavoriteCategoryRepository()
        super.init(frame: frame)
        setupUI()
        backgroundColor = .clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: NSNotification.Name("ThemeChangedNotification"), object: nil)
    }
    
    required init?(coder: NSCoder) {
        self.favoriteCategoryRepository = FavoriteCategoryRepository()
        super.init(coder: coder)
        setupUI()
        backgroundColor = .clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: NSNotification.Name("ThemeChangedNotification"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func themeChanged() {
        updateLabelColors()
    }
    
    func updateLabelColors() {
        if let currentCategory = currentCategory, let selectedLabel = categoryLabelMap[currentCategory] {
            labels.forEach { label in
                if label == selectedLabel {
                    label.textColor = ThemeManager.shared.currentTheme.isLight ? 
                    UIColor(named: "hex_Red") ?? .red : .white
                } else {
                    label.textColor = ThemeManager.shared.currentTheme.isLight ? .darkGray : .darkGray
                }
            }
        } else {
            labels.forEach { label in
                label.textColor = ThemeManager.shared.currentTheme.isLight ? .darkGray : .darkGray
            }
        }
    }
    
    private func setupLabel(selectedTitle: UILabel) {
        selectedTitle.style {
            $0.font = UIFont.systemFont(ofSize: 13)
            $0.textAlignment = .center
            $0.textColor = .darkGray
            $0.isUserInteractionEnabled = true
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(itemTapped(_:)))
        selectedTitle.addGestureRecognizer(tapGesture)
        stackView.addArrangedSubview(selectedTitle)
        labels.append(selectedTitle)
    }
    
    func refreshCategories(selectCategory: String? = nil) {
        // Save the previously selected category or use a new category
        let categoryToSelect = selectCategory ?? currentCategory
        
        // delete all current label
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        labels.removeAll()
        labelCategoryMap.removeAll()
        categoryLabelMap.removeAll()
        
        // Get list of fav category on background thread
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            
            let favoriteCategories = self.favoriteCategoryRepository.getAllFavoriteCategories()
            let shouldShowYourNews = !favoriteCategories.isEmpty
            
            DispatchQueue.main.async {
                // add new label
                for category in NewsCategoryType.allCases {
                    // Skip yourNews if no favorites
                    if category == .yourNews && !shouldShowYourNews {
                        continue
                    }
                    
                    let label = UILabel()
                    label.text = category.title
                    self.setupLabel(selectedTitle: label)
                    self.labelCategoryMap[label] = category
                    self.categoryLabelMap[category.apiValue] = label
                }
                
                // If there is a category -> highlighted
                if let categoryToSelect = categoryToSelect, let labelToHighlight = self.categoryLabelMap[categoryToSelect] {
                    self.highlightLabel(labelToHighlight)
                    self.scrollToLabel(labelToHighlight)
                }
            }
        }
    }
    
    // Highlight a category
    func selectCategory(_ category: String) {
        guard currentCategory != category else { return }
        
        currentCategory = category
        
        // Find the label mapping to the category
        guard let labelToHighlight = categoryLabelMap[category] else { return }
        
        highlightLabel(labelToHighlight)
        scrollToLabel(labelToHighlight)
    }
    
    private func highlightLabel(_ selectedLabel: UILabel) {
        labels.forEach { label in
            label.font = label == selectedLabel ? UIFont.boldSystemFont(ofSize: 21) :
            UIFont.systemFont(ofSize: 14, weight: .semibold)
            
            if label == selectedLabel {
                label.textColor = ThemeManager.shared.currentTheme.isLight ? 
                UIColor(named: "hex_Red") ?? .red : .white
            } else {
                label.textColor = .darkGray
            }
        }
    }
    
    // logic scroll method
    private func scrollToLabel(_ selectedLabel: UILabel) {
        UIView.animate(withDuration: 0.4) {
            let targetX = selectedLabel.frame.origin.x - (self.scrollView.frame.width / 2) +
            (selectedLabel.frame.width / 2)
            self.scrollView.setContentOffset(CGPoint(x: max(0, targetX), y: 0), animated: true)
        }
    }
    
    private func setupUI() {
        subviews(scrollView)
        
        stackView.style {
            $0.axis = .horizontal
            $0.spacing = 20
            $0.alignment = .center
            $0.distribution = .equalSpacing
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        scrollView.style {
            $0.showsHorizontalScrollIndicator = false
            $0.fillContainer()
            $0.addSubview(stackView)
        }
        
        stackView.Top == scrollView.Top
        stackView.Bottom == scrollView.Bottom
        stackView.Left == scrollView.Left
        stackView.Right == scrollView.Right
        stackView.height(35)
        
        stackView
            .widthAnchor
            .constraint(greaterThanOrEqualTo: scrollView.widthAnchor)
            .isActive = true
        
        refreshCategories()
    }
    
    @objc private func itemTapped(_ sender: UITapGestureRecognizer) {
        guard let selectedLabel = sender.view as? UILabel,
              let selectedCategory = labelCategoryMap[selectedLabel] else { return }
        
        // update currentCategory
        currentCategory = selectedCategory.apiValue
        
        // Highlight label selected
        highlightLabel(selectedLabel)
        
        // scroll to show label selected
        scrollToLabel(selectedLabel)
        
        delegate?.topBarView(self, didSelectCategory: selectedCategory.apiValue)
    }
}
