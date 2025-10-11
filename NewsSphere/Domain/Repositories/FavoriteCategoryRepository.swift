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
    private let backgroundQueue = DispatchQueue(label: "com.newssphere.favoritecategory", qos: .userInitiated)
    private let realmManager: RealmManager
    
    init(realmManager: RealmManager? = nil) {
        // Use the provided RealmManager or get it from UserSessionManager
        if let providedRealmManager = realmManager {
            self.realmManager = providedRealmManager
        } else if let sessionRealmManager = UserSessionManager.shared.getCurrentRealmManager() {
            self.realmManager = sessionRealmManager
        } else {
            // Create a default RealmManager with a unique ID that's not user-dependent
            print("WARNING - FavoriteCategoryRepository: No RealmManager available. Creating a default one.")
            // Use "anonymous" as a guaranteed valid user ID
            if let defaultRealmManager = RealmManager(userUID: "anonymous") {
                self.realmManager = defaultRealmManager
            } else {
                // If RealmManager initialization still fails, create a basic implementation to avoid crashes
                fatalError("Failed to initialize RealmManager. This is a critical error that needs to be fixed.")
            }
        }
    }
    
    private func performRealmOperation<T>(_ operation: @escaping () -> T) -> T {
        if Thread.isMainThread {
            return operation()
        } else {
            var result: T!
            let semaphore = DispatchSemaphore(value: 0)
            mainQueue.async {
                result = operation()
                semaphore.signal()
            }
            semaphore.wait()
            return result
        }
    }
    
    func saveFavoriteCategory(_ category: NewsCategoryType) -> Result<Void, Error> {
        return performRealmOperation {
            print("DEBUG - FavoriteCategoryRepository: Saving favorite category on thread: \(Thread.current)")
            let result = self.realmManager.saveFavoriteCategory(category)
            switch result {
            case .success:
                return .success(())
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    func removeFavoriteCategory(_ category: NewsCategoryType) -> Result<Void, Error> {
        return performRealmOperation {
            print("DEBUG - FavoriteCategoryRepository: Removing favorite category on thread: \(Thread.current)")
            let result = self.realmManager.removeFavoriteCategory(category)
            switch result {
            case .success:
                return .success(())
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    func getAllFavoriteCategories() -> [NewsCategoryType] {
        return performRealmOperation {
            print("DEBUG - FavoriteCategoryRepository: Getting favorite categories on thread: \(Thread.current)")
            return self.realmManager.getAllFavoriteCategories()
        }
    }
    
    func isFavoriteCategory(_ category: NewsCategoryType) -> Bool {
        return performRealmOperation {
            print("DEBUG - FavoriteCategoryRepository: Checking if category is favorited on thread: \(Thread.current)")
            return self.realmManager.isFavoriteCategory(category)
        }
    }
    
    func clearAllFavoriteCategories() -> Result<Void, Error> {
        return performRealmOperation {
            print("DEBUG - FavoriteCategoryRepository: Clearing all favorite categories on thread: \(Thread.current)")
            let result = self.realmManager.clearAllFavoriteCategories()
            switch result {
            case .success:
                return .success(())
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    func getFavoriteCategoriesCount() -> Int {
        return performRealmOperation {
            return self.realmManager.getFavoriteCategoriesCount()
        }
    }
    
    func getMaxAllowedCategories() -> Int {
        return performRealmOperation {
            return self.realmManager.getMaxAllowedCategories()
        }
    }
}
