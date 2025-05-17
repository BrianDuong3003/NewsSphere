//
//  MainViewController.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 7/3/25.
//

import UIKit
import Stevia

class MainViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var contentView = UIView()
    private lazy var customTabbar = CustomTabbar()
    
    // MARK: - Properties
    private var viewControllers: [UIViewController] = []
    private var currentViewController: UIViewController?
    private var currentIndex: Int = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
        setupConstraints()
        showViewController(at: 0)
        
        // Add observer for theme changes
        ThemeManager.shared.addThemeChangeObserver(self, selector: #selector(themeChanged))
    }
    
    deinit {
        ThemeManager.shared.removeThemeChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Theme Handling
    @objc private func themeChanged() {
        updateThemeBasedUI()
    }
    
    private func updateThemeBasedUI() {
        view.backgroundColor = .themeBackgroundColor()
    }
    
    // MARK: - Public Methods
    func setViewControllers(_ viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
    }
    
    // MARK: - Setup
    private func setupView() {
        view.subviews {
            contentView
            customTabbar
        }
    }
    
    private func setupStyle() {
        view.backgroundColor = .themeBackgroundColor()
        customTabbar.delegate = self
    }
    
    private func setupConstraints() {
        contentView.Top == view.Top
        contentView.Leading == view.Leading
        contentView.Trailing == view.Trailing
        contentView.Bottom == customTabbar.Top
        
        customTabbar.Leading == view.Leading
        customTabbar.Trailing == view.Trailing
        customTabbar.Bottom == view.Bottom
        customTabbar.Height == 90
    }
    
    private func showViewController(at index: Int) {
        guard index < viewControllers.count else {
            return
        }
        
        // Store current index
        currentIndex = index
        
        if let currentVC = currentViewController {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
            self.currentViewController = nil
        }
        
        let newVC = viewControllers[index]
        addChild(newVC)
        newVC.view.frame = contentView.bounds
        contentView.addSubview(newVC.view)
        newVC.didMove(toParent: self)
        currentViewController = newVC
    }
}

// MARK: - CustomTabbarDelegate
extension MainViewController: CustomTabbarDelegate {
    func didSelectTab(_ tabType: TabType) {
        if let index = TabType.allCases.firstIndex(of: tabType) {
            showViewController(at: index)
        }
    }
}
