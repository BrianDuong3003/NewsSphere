import Foundation
protocol BookmarkRepositoryProtocol {
    func getSavedArticles() -> [Article]
    func isArticleSaved(link: String) -> Bool
    func saveArticle(_ article: Article) -> Result<Void, Error>
    func deleteArticle(link: String) -> Result<Void, Error>
}
class BookmarkRepository: BookmarkRepositoryProtocol {
    func getSavedArticles() -> [Article] {
        return RealmManager.shared.getSavedArticles()
    }
    func isArticleSaved(link: String) -> Bool {
        return RealmManager.shared.isArticleSaved(link: link)
    }
    
    func saveArticle(_ article: Article) -> Result<Void, Error> {
        switch RealmManager.shared.saveArticle(article) {
        case .success:
            return .success(())
        case .failure(let realmError):
            return .failure(realmError as Error)
        }
    }
    
    func deleteArticle(link: String) -> Result<Void, Error> {
        switch RealmManager.shared.deleteArticle(link: link) {
        case .success:
            return .success(())
        case .failure(let realmError):
            return .failure(realmError as Error)
        }
    }
}

