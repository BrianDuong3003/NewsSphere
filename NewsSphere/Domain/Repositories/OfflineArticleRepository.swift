//
//  OfflineArticleRepository.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 28/4/25.
//

import Foundation
import RealmSwift

protocol OfflineArticleRepositoryProtocol {
    func fetchLatestArticles(completion: @escaping (Result<[Article], Error>) -> Void)
    func saveArticles(_ articles: [Article], completion: @escaping (Result<Int, Error>) -> Void)
    func getAllOfflineArticles() -> [Article]
    func deleteAllOfflineArticles() -> Result<Void, Error>
    func getOfflineArticlesCount() -> Int
    func cleanupUnusedArticles() -> Result<Int, Error>
}

class OfflineArticleRepository: OfflineArticleRepositoryProtocol {
    private let articleRepository: ArticleRepositoryProtocol
    private let realmManager: RealmManager
    private let mainQueue = DispatchQueue.main
    
    init(
        articleRepository: ArticleRepositoryProtocol = ArticleRepository(),
        realmManager: RealmManager? = nil
    ) {
        self.articleRepository = articleRepository
        // Use the provided RealmManager or get it from UserSessionManager
        self.realmManager = realmManager ?? UserSessionManager.shared.getCurrentRealmManager() ?? {
            print("ERROR - OfflineArticleRepository: No RealmManager available. Creating a guest one.")
            // Handle guest/error case
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
    
    func fetchLatestArticles(completion: @escaping (Result<[Article], Error>) -> Void) {
        articleRepository.fetchArticles(category: "top") { [weak self] articles in
            guard let self = self else { return }
            
            if let articles = articles {
                let articlesToSave = Array(articles.prefix(10))
                completion(.success(articlesToSave))
            } else {
                let error = NSError(
                    domain: "com.newssphere.offline",
                    code: 1001,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to fetch latest articles"]
                )
                completion(.failure(error))
            }
        }
    }
    
    func saveArticles(_ articles: [Article], completion: @escaping (Result<Int, Error>) -> Void) {
        print("DEBUG - OfflineArticleRepository: Starting to save \(articles.count) articles")
        
        // make sure execute on main thread
        mainQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Delete all current offline articles
            let deleteResult = self.realmManager.deleteAllOfflineArticles()
            if case .failure(let error) = deleteResult {
                completion(.failure(error))
                return
            }
            
            // save new articles
            let result = self.realmManager.saveOfflineArticles(articles)
            
            switch result {
            case .success(let count):
                print("DEBUG - OfflineArticleRepository: Saved \(count) articles successfully")
                completion(.success(count))
            case .failure(let error):
                print("DEBUG - OfflineArticleRepository: Failed to save articles: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    func getAllOfflineArticles() -> [Article] {
        return ensureMainThread {
            print("DEBUG - OfflineArticleRepository: Getting offline articles on thread: \(Thread.current)")
            let articles = self.realmManager.getOfflineArticles()
            print("DEBUG - OfflineArticleRepository: Retrieved \(articles.count) offline articles")
            return articles
        }
    }
    
    func deleteAllOfflineArticles() -> Result<Void, Error> {
        return ensureMainThread {
            print("DEBUG - OfflineArticleRepository: Deleting all offline articles on thread: \(Thread.current)")
            
            let result = self.realmManager.deleteAllOfflineArticles()
            
            switch result {
            case .success:
                print("DEBUG - OfflineArticleRepository: Successfully deleted all articles")
                return .success(())
            case .failure(let error):
                print("DEBUG - OfflineArticleRepository: Failed to delete articles: \(error.localizedDescription)")
                return .failure(error)
            }
        }
    }
    
    func getOfflineArticlesCount() -> Int {
        return ensureMainThread {
            return self.realmManager.getOfflineArticles().count
        }
    }
    
    func cleanupUnusedArticles() -> Result<Int, Error> {
        return ensureMainThread {
            print("DEBUG - OfflineArticleRepository: Cleaning up unused articles on thread: \(Thread.current)")
            let result = self.realmManager.cleanupUnusedArticles()
            
            switch result {
            case .success(let count):
                return .success(count)
            case .failure(let error):
                return .failure(error)
            }
        }
    }
}
