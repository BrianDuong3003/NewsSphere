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
        showViewController(at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Public Methods
    /// Sets pre-configured view controllers - called by MainCoordinator
    func setViewControllers(_ viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .black
        
        view.subviews {
            contentView
            customTabbar
        }
        
        contentView.Top == view.Top
        contentView.Leading == view.Leading
        contentView.Trailing == view.Trailing
        contentView.Bottom == customTabbar.Top
        
        customTabbar.Leading == view.Leading
        customTabbar.Trailing == view.Trailing
        customTabbar.Bottom == view.safeAreaLayoutGuide.Bottom
        customTabbar.Height == 90
        
        customTabbar.delegate = self
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
