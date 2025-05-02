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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        for category in NewsCategoryType.allCases {
            let label = UILabel()
            label.text = category.title
            setupLabel(selectedTitle: label)
            labelCategoryMap[label] = category
        }
    }
    
    @objc private func itemTapped(_ sender: UITapGestureRecognizer) {
        guard let selectedLabel = sender.view as? UILabel,
              let selectedCategory = labelCategoryMap[selectedLabel] else { return }
        
        labels.forEach { label in
            label.font = label == selectedLabel ? UIFont.boldSystemFont(ofSize: 21) :
            UIFont.systemFont(ofSize: 14, weight: .semibold)
            label.textColor = label == selectedLabel ? .white : .darkGray
        }
        
        UIView.animate(withDuration: 0.4) {
            let targetX = selectedLabel.frame.origin.x - (self.scrollView.frame.width / 2) +
            (selectedLabel.frame.width / 2)
            self.scrollView.setContentOffset(CGPoint(x: max(0, targetX), y: 0), animated: true)
        }
        
        delegate?.topBarView(self, didSelectCategory: selectedCategory.apiValue)
    }
}
