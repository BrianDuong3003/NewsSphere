//
//  SelectCategoriesViewController.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import UIKit
import Stevia

protocol SelectCategoriesViewControllerDelegate: AnyObject {
    func didFinishSelectingCategories(didSkip: Bool)
}

class SelectCategoriesViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: SelectCategoriesViewModel
    var mode: SelectCategoriesMode = .initialSetup
    weak var delegate: SelectCategoriesViewControllerDelegate?
    
    // MARK: - UI Elements
    private lazy var scrollView = UIScrollView()
    private let contentView = UIView()
    private lazy var titleLabel = UILabel()
    private lazy var descLabel = UILabel()
    private lazy var selectedCountLabel = UILabel()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 100, height: 40)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collection
    }()
    private lazy var loginRegisterButotnDescLabel = UILabel()
    private lazy var navigateLoginRegisterButton = GradientButton(type: .system)
    private lazy var skipButton = UIButton(type: .system)
    
    private var collectionViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    init(viewModel: SelectCategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
        setupConstraints()
        setupBindings()
        updateUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        updateCollectionViewHeight()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.subviews {
            scrollView.subviews {
                contentView.subviews {
                    titleLabel
                    descLabel
                    selectedCountLabel
                    collectionView
                    loginRegisterButotnDescLabel
                    navigateLoginRegisterButton
                    skipButton
                }
            }
        }
    }
    
    private func setupStyle() {
        view.backgroundColor = .black
        
        scrollView.showsVerticalScrollIndicator = false
        
        titleLabel.text = mode == .initialSetup ? "Select favorite categories" : "Edit favorite categories"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 25, weight: .bold)
        
        descLabel.text = "These categories will be used to personalized news for you"
        descLabel.textColor = .white
        descLabel.font = .systemFont(ofSize: 14, weight: .medium)
        descLabel.numberOfLines = 0
        descLabel.lineBreakMode = .byWordWrapping
        
        selectedCountLabel.textColor = .hexGrey
        selectedCountLabel.font = .systemFont(ofSize: 12, weight: .regular)
        selectedCountLabel.textAlignment = .right
        
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.register(TagCell.self, forCellWithReuseIdentifier: "TagCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        loginRegisterButotnDescLabel.text = mode == .initialSetup 
            ? "Continue with selected categories" 
            : "Save changes"
        loginRegisterButotnDescLabel.textColor = .white
        loginRegisterButotnDescLabel.font = .systemFont(ofSize: 18, weight: .bold)
        loginRegisterButotnDescLabel.numberOfLines = 0
        loginRegisterButotnDescLabel.lineBreakMode = .byWordWrapping
        
        if let startColor = UIColor(named: "hex_Brown"),
           let endColor = UIColor(named: "hex_DarkRed") {
            navigateLoginRegisterButton.setGradientColors(startColor: startColor,
                                   endColor: endColor)
        }
        
        navigateLoginRegisterButton.setGradientDirection(startPoint: CGPoint(x: 0, y: 0),
                                  endPoint: CGPoint(x: 1, y: 0))
        
        navigateLoginRegisterButton.setTitle(mode == .initialSetup ? "Continue" : "Save", for: .normal)
        navigateLoginRegisterButton.setTitleColor(.white, for: .normal)
        navigateLoginRegisterButton.titleLabel?.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        navigateLoginRegisterButton.layer.cornerRadius = 8
        navigateLoginRegisterButton.clipsToBounds = true
        navigateLoginRegisterButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        skipButton.setTitle("Skip", for: .normal)
        skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        skipButton.setTitleColor(.black, for: .normal)
        skipButton.backgroundColor = .hexGrWhite
        skipButton.layer.cornerRadius = 8
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        
        // hidden skip button in edit mode
        skipButton.isHidden = mode == .edit
    }
    
    private func setupConstraints() {
        scrollView.fillContainer(padding: 0)
        contentView.width(UIScreen.main.bounds.width)
        
        contentView.layout(
            26,
            |-18-titleLabel-18-|,
            11,
            |-18-descLabel-18-|,
            8,
            |-18-selectedCountLabel-18-|,
            8,
            |-18-collectionView-18-|,
            79,
            |-18-loginRegisterButotnDescLabel-18-|,
            10,
            |-18-navigateLoginRegisterButton-18-|,
            18,
            |-16-skipButton-16-|,
            16
        )
        
        navigateLoginRegisterButton.height(48)
        skipButton.height(48)
        
        scrollView.Top == view.safeAreaLayoutGuide.Top
        scrollView.Bottom == view.safeAreaLayoutGuide.Bottom
        
        contentView.Top == scrollView.Top
        contentView.Bottom == scrollView.Bottom
        
        collectionViewHeightConstraint = collectionView.heightAnchor
            .constraint(equalToConstant: 200)
        collectionViewHeightConstraint?.isActive = true
    }
    
    private func setupBindings() {
        viewModel.onCategoriesUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
        
        viewModel.onErrorOccurred = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showAlert(title: "Error", message: errorMessage)
            }
        }
        
        viewModel.onMaxCategoriesReached = { [weak self] in
            DispatchQueue.main.async {
                self?.showAlert(
                    title: "Maximum Categories Reached", 
                    message: "You can select up to \(self?.viewModel.getMaxAllowedCategories() ?? 5) categories. Please deselect a category first."
                )
            }
        }
    }
    
    private func updateUI() {
        collectionView.reloadData()
        updateSelectedCountLabel()
    }
    
    private func updateSelectedCountLabel() {
        let selectedCount = viewModel.getSelectedCategoriesCount()
        let maxCount = viewModel.getMaxAllowedCategories()
        selectedCountLabel.text = "\(selectedCount)/\(maxCount) categories selected"
    }
    
    private func updateCollectionViewHeight() {
        collectionView.layoutIfNeeded()
        let contentHeight = collectionView.contentSize.height
        collectionViewHeightConstraint?.constant = contentHeight
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func continueButtonTapped() {
        // If in edit mode, update UserDefaults to mark completed
        if mode == .initialSetup {
            UserDefaults.standard.set(true, forKey: "hasSelectedCategories")
        }
        // Notify delegate that it s done
        delegate?.didFinishSelectingCategories(didSkip: false)
    }
    
    @objc private func skipButtonTapped() {
        UserDefaults.standard.set(true, forKey: "hasSkippedCategories")
        UserDefaults.standard.set(true, forKey: "hasSelectedCategories")
        
        viewModel.clearAllCategories()
        delegate?.didFinishSelectingCategories(didSkip: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension SelectCategoriesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfCategories()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell",
                                                      for: indexPath) as? TagCell,
              let category = viewModel.category(at: indexPath.item) else {
            return UICollectionViewCell()
        }
        
        cell.configure(
            with: category.displayName, 
            isSelected: viewModel.isCategorySelected(category)
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let category = viewModel.category(at: indexPath.item) {
            viewModel.toggleCategory(category)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SelectCategoriesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let category = viewModel.category(at: indexPath.item) else {
            return CGSize(width: 100, height: 36)
        }
        
        let width = category.displayName.size(withAttributes: [.font: UIFont.systemFont(ofSize: 15)]).width + 40
        return CGSize(width: width, height: 36)
    }
}
