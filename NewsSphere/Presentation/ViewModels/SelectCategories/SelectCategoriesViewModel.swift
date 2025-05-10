import Foundation

enum SelectCategoriesMode {
    case initialSetup
    case edit
}

class SelectCategoriesViewModel {
    // MARK: - Properties
    private let repository: FavoriteCategoryRepositoryProtocol
    private var allCategories: [NewsCategoryType] = NewsCategoryType.allCases.filter { 
        // remove yourNews
         $0 != .yourNews
    }
    
    // MARK: - Bindings
    var onCategoriesUpdated: (() -> Void)?
    var onErrorOccurred: ((String) -> Void)?
    var onMaxCategoriesReached: (() -> Void)?
    
    // MARK: - Initialization
    init(repository: FavoriteCategoryRepositoryProtocol = FavoriteCategoryRepository()) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    func numberOfCategories() -> Int {
        return allCategories.count
    }
    
    func category(at index: Int) -> NewsCategoryType? {
        guard index >= 0 && index < allCategories.count else { return nil }
        return allCategories[index]
    }
    
    func isCategorySelected(_ category: NewsCategoryType) -> Bool {
        return repository.isFavoriteCategory(category)
    }
    
    func toggleCategory(_ category: NewsCategoryType) {
        if isCategorySelected(category) {
            let result = repository.removeFavoriteCategory(category)
            
            switch result {
            case .success:
                print("DEBUG - SelectCategoriesViewModel: Successfully removed category: \(category.displayName)")
            case .failure(let error):
                let errorMessage = "Failed to remove category: \(error.localizedDescription)"
                print("ERROR - SelectCategoriesViewModel: \(errorMessage)")
                onErrorOccurred?(errorMessage)
            }
        } else {
            if repository.getFavoriteCategoriesCount() >= repository.getMaxAllowedCategories() {
                print("DEBUG - SelectCategoriesViewModel: Maximum categories limit reached")
                onMaxCategoriesReached?()
                return
            }
            
            let result = repository.saveFavoriteCategory(category)
            
            switch result {
            case .success:
                print("DEBUG - SelectCategoriesViewModel: Successfully added category: \(category.displayName)")
            case .failure(let error):
                let errorMessage = "Failed to add category: \(error.localizedDescription)"
                print("ERROR - SelectCategoriesViewModel: \(errorMessage)")
                onErrorOccurred?(errorMessage)
            }
        }
        
        onCategoriesUpdated?()
    }
    
    func getSelectedCategories() -> [NewsCategoryType] {
        return repository.getAllFavoriteCategories()
    }
    
    func getSelectedCategoriesCount() -> Int {
        return repository.getFavoriteCategoriesCount()
    }
    
    func getMaxAllowedCategories() -> Int {
        return repository.getMaxAllowedCategories()
    }
    
    func hasSelectedAnyCategory() -> Bool {
        return getSelectedCategoriesCount() > 0
    }
    
    func clearAllCategories() {
        let result = repository.clearAllFavoriteCategories()
        
        switch result {
        case .success:
            print("DEBUG - SelectCategoriesViewModel: Successfully cleared all categories")
            onCategoriesUpdated?()
        case .failure(let error):
            let errorMessage = "Failed to clear categories: \(error.localizedDescription)"
            print("ERROR - SelectCategoriesViewModel: \(errorMessage)")
            onErrorOccurred?(errorMessage)
        }
    }
} 
