//
//  DiscoveryViewModel.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation
import UIKit

class DiscoveryViewModel {
    // MARK: - Properties
    private let categoryRepository = CategoryRepository()
    
    private var allCategories: [NewsCategoryType] = NewsCategoryType.allCases
    private var filteredCategories: [NewsCategoryType] = NewsCategoryType.allCases
    
    // MARK: - Bindings
    var onCategoriesUpdated: (() -> Void)?
    var onErrorOccurred: ((String) -> Void)?
    
    private weak var coordinator: DiscoveryCoordinator?
    
    // MARK: - Initialization
    init(coordinator: DiscoveryCoordinator? = nil) {
        self.coordinator = coordinator
    }
    
    // MARK: - Public Methods
    // get numberOfCategories to show
    func numberOfCategories() -> Int {
        return filteredCategories.count
    }
    
    // get category at spec index
    func category(at index: Int) -> NewsCategoryType? {
        guard index >= 0 && index < filteredCategories.count else { return nil }
        return filteredCategories[index]
    }
    
    func filterCategories(with searchText: String) {
        guard !searchText.isEmpty else {
            filteredCategories = allCategories
            onCategoriesUpdated?()
            return
        }
        
        filteredCategories = allCategories.filter { category in
            category.displayName.lowercased().contains(searchText.lowercased())
        }
        
        onCategoriesUpdated?()
    }
    
    func didSelectCategory(at index: Int) {
        guard let category = category(at: index) else { return }
        coordinator?.showArticles(for: category.apiValue)
    }
    
    func resetFilter() {
        filteredCategories = allCategories
        onCategoriesUpdated?()
    }
}
