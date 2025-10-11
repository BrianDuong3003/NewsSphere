import Foundation
protocol BookmarkRepositoryProtocol {
    func getSavedArticles() -> [Article]
    func isArticleSaved(link: String) -> Bool
    func saveArticle(_ article: Article) -> Result<Void, Error>
    func deleteArticle(link: String) -> Result<Void, Error>
}
class BookmarkRepository: BookmarkRepositoryProtocol {
    private let mainQueue = DispatchQueue.main
    private let realmManager: RealmManager
    
    init(realmManager: RealmManager? = nil) {
        // Use the provided RealmManager or get it from UserSessionManager
        if let providedRealmManager = realmManager {
            self.realmManager = providedRealmManager
        } else if let sessionRealmManager = UserSessionManager.shared.getCurrentRealmManager() {
            self.realmManager = sessionRealmManager
        } else {
            // Create a default RealmManager with a unique ID that's not user-dependent
            print("WARNING - BookmarkRepository: No RealmManager available. Creating a default one.")
            // Use "anonymous" as a guaranteed valid user ID
            if let defaultRealmManager = RealmManager(userUID: "anonymous") {
                self.realmManager = defaultRealmManager
            } else {
                // If RealmManager initialization still fails, create a basic implementation to avoid crashes
                fatalError("Failed to initialize RealmManager. This is a critical error that needs to be fixed.")
            }
        }
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
    
    func getSavedArticles() -> [Article] {
        return ensureMainThread {
            print("DEBUG - BookmarkRepository: Getting bookmarked articles on thread: \(Thread.current)")
            return self.realmManager.getBookmarkedArticles()
        }
    }
    
    func isArticleSaved(link: String) -> Bool {
        return ensureMainThread {
            print("DEBUG - BookmarkRepository: Checking if article is bookmarked on thread: \(Thread.current)")
            return self.realmManager.isBookmarked(link: link)
        }
    }
    
    func saveArticle(_ article: Article) -> Result<Void, Error> {
        return ensureMainThread {
            print("DEBUG - BookmarkRepository: Saving bookmark on thread: \(Thread.current)")
            let result = self.realmManager.saveBookmark(article)
            switch result {
            case .success:
                return .success(())
            case .failure(let realmError):
                return .failure(realmError)
            }
        }
    }
    
    func deleteArticle(link: String) -> Result<Void, Error> {
        return ensureMainThread {
            print("DEBUG - BookmarkRepository: Deleting bookmark on thread: \(Thread.current)")
            let result = self.realmManager.deleteBookmark(link: link)
            switch result {
            case .success:
                return .success(())
            case .failure(let realmError):
                return .failure(realmError)
            }
        }
    }
}
