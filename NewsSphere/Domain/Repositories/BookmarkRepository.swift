import Foundation
protocol BookmarkRepositoryProtocol {
    func getSavedArticles() -> [Article]
    func isArticleSaved(link: String) -> Bool
    func saveArticle(_ article: Article) -> Result<Void, Error>
    func deleteArticle(link: String) -> Result<Void, Error>
}
class BookmarkRepository: BookmarkRepositoryProtocol {
    private let mainQueue = DispatchQueue.main
    
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
            return RealmManager.shared.getBookmarkedArticles()
        }
    }
    
    func isArticleSaved(link: String) -> Bool {
        return ensureMainThread {
            print("DEBUG - BookmarkRepository: Checking if article is bookmarked on thread: \(Thread.current)")
            return RealmManager.shared.isBookmarked(link: link)
        }
    }
    
    func saveArticle(_ article: Article) -> Result<Void, Error> {
        return ensureMainThread {
            print("DEBUG - BookmarkRepository: Saving bookmark on thread: \(Thread.current)")
            let result = RealmManager.shared.saveBookmark(article)
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
            let result = RealmManager.shared.deleteBookmark(link: link)
            switch result {
            case .success:
                return .success(())
            case .failure(let realmError):
                return .failure(realmError)
            }
        }
    }
}
