import Foundation

protocol FavoriteCategoryRepositoryProtocol {
    func saveFavoriteCategory(_ category: NewsCategoryType) -> Result<Void, Error>
    func removeFavoriteCategory(_ category: NewsCategoryType) -> Result<Void, Error>
    func getAllFavoriteCategories() -> [NewsCategoryType]
    func isFavoriteCategory(_ category: NewsCategoryType) -> Bool
    func clearAllFavoriteCategories() -> Result<Void, Error>
    func getFavoriteCategoriesCount() -> Int
    func getMaxAllowedCategories() -> Int
}

class FavoriteCategoryRepository: FavoriteCategoryRepositoryProtocol {
    private let mainQueue = DispatchQueue.main
    private let realmManager: RealmManager
    
    init(realmManager: RealmManager? = nil) {
        self.realmManager = realmManager ?? UserSessionManager.shared.getCurrentRealmManager() ?? {
            print("ERROR - FavoriteCategoryRepository: No RealmManager available. Creating a guest one.")
            return RealmManager(userUID: "guest")!
        }()
    }
    
    // make sure execute on main thread
    private func ensureMainThread<T>(_ block: @escaping () -> T) -> T {
        if Thread.isMainThread {
            return block()
        } else {
            var result: T!
            let semaphore = DispatchSemaphore(value: 0)
            
            mainQueue.async {
                result = block()
                semaphore.signal()
            }
            
            semaphore.wait()
            return result
        }
    }
    
    func saveFavoriteCategory(_ category: NewsCategoryType) -> Result<Void, Error> {
        return ensureMainThread {
            print("DEBUG - FavoriteCategoryRepository: Saving favorite category on thread: \(Thread.current)")
            let result = self.realmManager.saveFavoriteCategory(category)
            switch result {
            case .success:
                return .success(())
            case .failure(let realmError):
                return .failure(realmError)
            }
        }
    }
    
    func removeFavoriteCategory(_ category: NewsCategoryType) -> Result<Void, Error> {
        return ensureMainThread {
            print("DEBUG - FavoriteCategoryRepository: Removing favorite category on thread: \(Thread.current)")
            let result = self.realmManager.removeFavoriteCategory(category)
            switch result {
            case .success:
                return .success(())
            case .failure(let realmError):
                return .failure(realmError)
            }
        }
    }
    
    func getAllFavoriteCategories() -> [NewsCategoryType] {
        return ensureMainThread {
            print("DEBUG - FavoriteCategoryRepository: Getting favorite categories on thread: \(Thread.current)")
            return self.realmManager.getAllFavoriteCategories()
        }
    }
    
    func isFavoriteCategory(_ category: NewsCategoryType) -> Bool {
        return ensureMainThread {
            print("DEBUG - FavoriteCategoryRepository: Checking if category is favorited on thread: \(Thread.current)")
            return self.realmManager.isFavoriteCategory(category)
        }
    }
    
    func clearAllFavoriteCategories() -> Result<Void, Error> {
        return ensureMainThread {
            print("DEBUG - FavoriteCategoryRepository: Clearing all favorite categories on thread: \(Thread.current)")
            let result = self.realmManager.clearAllFavoriteCategories()
            switch result {
            case .success:
                return .success(())
            case .failure(let realmError):
                return .failure(realmError)
            }
        }
    }
    
    func getFavoriteCategoriesCount() -> Int {
        return ensureMainThread {
            return self.realmManager.getFavoriteCategoriesCount()
        }
    }
    
    func getMaxAllowedCategories() -> Int {
        return ensureMainThread {
            return self.realmManager.getMaxAllowedCategories()
        }
    }
}
