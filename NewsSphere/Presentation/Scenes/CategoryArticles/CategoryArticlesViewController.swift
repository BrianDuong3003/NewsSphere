//
//  PoliticsViewController.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 7/4/25.
//

import UIKit
import Stevia

class CategoryArticlesViewController: UIViewController {
    
    private lazy var mainTitleLB = UILabel()
    private lazy var contentview = UIView()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    weak var coordinator: CategoryArticlesCoordinator?
    private var viewModel: CategoryArticlesViewModel
    private var articles: [Article] = []
    
    init(category: String) {
        self.viewModel = CategoryArticlesViewModel(category: category)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        fetchArticles()
    }
    
    func config() {
        setupViews()
        setupConstraints()
        styleViews()
    }
}

// MARK: - Fetch Data
extension CategoryArticlesViewController {
    private func fetchArticles() {
        viewModel.fetchArticles { [weak self] articles in
            self?.articles = articles
            self?.collectionView.reloadData()
        }
    }
}

extension CategoryArticlesViewController {
    func setupViews() {
        view.subviews {
            mainTitleLB
            contentview
        }
        
        contentview.subviews {
            collectionView
        }
    }
    
    func setupConstraints() {
        mainTitleLB
            .top(60)
            .centerHorizontally()
        
        contentview
            .top(105)
            .left(0)
            .right(0)
            .bottom(0)
        
        collectionView
            .left(12)
            .right(12)
            .bottom(0)
            .height(>=200)
            .top(60)
    }
    
    func styleViews() {
        view.backgroundColor = UIColor.C_01_D_2_E
        
        mainTitleLB.style {
            $0.text = NewsCategoryType(rawValue: viewModel.category)?.displayName ?? viewModel.category.uppercased()
            $0.font = .systemFont(ofSize: 24, weight: .bold)
            $0.textColor = .white
            $0.textAlignment = .center
        }
        
        contentview.style {
            $0.backgroundColor = UIColor._1_B_1_B_1_B
        }
        
        collectionView.style {
            $0.backgroundColor = .clear
            $0.delegate = self
            $0.dataSource = self
            $0.showsVerticalScrollIndicator = false
            $0.register(CategoryArticlesCell.self, forCellWithReuseIdentifier:
                            "CategoryArticlesCell")
        }
    }
}

// MARK: - CollectionView Deledate, Datasource
extension CategoryArticlesViewController: UICollectionViewDelegate, UICollectionViewDataSource,
                                          UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CategoryArticlesCell", for: indexPath)
                as? CategoryArticlesCell else {
            return UICollectionViewCell()
        }
        let article = articles[indexPath.item]
        cell.configure(with: article)
        return cell
    }
    
    func collectionView(_ collectiornView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: 300)
    }
}
