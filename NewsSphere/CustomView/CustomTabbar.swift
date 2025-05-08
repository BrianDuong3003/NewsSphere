//
//  CustomTabbar.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 18/3/25.
//

import UIKit
import Stevia

// MARK: - CustomTabbarDelegate
protocol CustomTabbarDelegate: AnyObject {
    func didSelectTab(_ tabType: TabType)
}

class CustomTabbar: UIView {
    
    // MARK: - Properties
    private var selectedTab: TabType = .home
    private var tabItems: [CustomTabbarItem] = []
    weak var delegate: CustomTabbarDelegate?
    
    // MARK: - UI Elements
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        return stack
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupStyle()
        createTabItems()
        selectTab(.home)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupStyle()
        createTabItems()
        selectTab(.home)
    }
    
    // MARK: - Setup
    private func setupView() {
        subviews {
            stackView
        }
        stackView.fillContainer()
    }
    
    private func setupStyle() {
        backgroundColor = .black
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
    }
    
    private func createTabItems() {
        // Clear existing items
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tabItems.removeAll()
        
        // Create tab items
        for type in TabType.allCases {
            let tabItem = CustomTabbarItem(type: type)
            tabItems.append(tabItem)
            stackView.addArrangedSubview(tabItem.button)
            tabItem.button.addTarget(self, action: #selector(tabButtonTapped(_:)),
                                     for: .touchUpInside)
            tabItem.button.tag = TabType.allCases.firstIndex(of: type) ?? 0
        }
    }
    
    // MARK: - Actions
    @objc private func tabButtonTapped(_ sender: UIButton) {
        if let index = sender.tag as? Int,
           let tabType = TabType.allCases[safe: index] {
            selectTab(tabType)
            delegate?.didSelectTab(tabType)
        }
    }
    
    // MARK: - Public Methods
    func selectTab(_ tabType: TabType) {
        selectedTab = tabType
        
        for tabItem in tabItems {
            let isSelected = tabItem.type == selectedTab
            tabItem.setSelected(isSelected)
        }
    }
}

// MARK: - Helper Extensions
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
