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
}

class OfflineArticleRepository: OfflineArticleRepositoryProtocol {
    private let articleRepository: ArticleRepositoryProtocol
    private let realmManager: RealmManager
    
    init(
        articleRepository: ArticleRepositoryProtocol = ArticleRepository(),
        realmManager: RealmManager = RealmManager.shared
    ) {
        self.articleRepository = articleRepository
        self.realmManager = realmManager
    }
    
    func fetchLatestArticles(completion: @escaping (Result<[Article], Error>) -> Void) {
        articleRepository.fetchArticles(category: "top") { articles in
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
        
        // Chuyển việc xóa và lưu vào background thread
        DispatchQueue.global(qos: .utility).async {
            // create new instance Realm for background thread
            do {
                // Sử dụng cấu hình từ RealmManager chung
                let backgroundRealm = try Realm(configuration: self.realmManager.getConfiguration())
                
                var savedCount = 0
                var lastError: Error?
                
                // delete articles in autoreleasepool free up memory
                autoreleasepool {
                    do {
                        try backgroundRealm.write {
                            let allArticles = backgroundRealm.objects(ArticleObject.self)
                            backgroundRealm.delete(allArticles)
                        }
                    } catch let error {
                        lastError = error
                        print("DEBUG OfflineArticleRepository: Error deleting articles: \(error.localizedDescription)")
                    }
                }
                
                // Do not continue if there is an error while deletingg
                if lastError != nil {
                    DispatchQueue.main.async {
                        completion(.failure(lastError!))
                    }
                    return
                }
                
                // Save new articles in separate autoreleasepool
                autoreleasepool {
                    for article in articles {
                        do {
                            try backgroundRealm.write {
                                let articleObject = ArticleObject(article: article)
                                backgroundRealm.add(articleObject, update: .modified)
                                savedCount += 1
                            }
                        } catch let error {
                            lastError = error
                            print("DEBUG OfflineArticleRepository: Error saving article \(error.localizedDescription)")
                        }
                    }
                }
                
                // Return result to main thread
                DispatchQueue.main.async {
                    if savedCount > 0 {
                        print("DEBUG - OfflineArticleRepository: Saved \(savedCount) articles successfully")
                        completion(.success(savedCount))
                    } else if let error = lastError {
                        completion(.failure(error))
                    } else {
                        let error = NSError(
                            domain: "com.newssphere.offline",
                            code: 1002,
                            userInfo: [NSLocalizedDescriptionKey: "No articles were saved"]
                        )
                        completion(.failure(error))
                    }
                }
            } catch let error {
                // Handling errors when creating Realm instance
                print("DEBUG OfflineArticleRepository: Failed to create Realm instance: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func getAllOfflineArticles() -> [Article] {
        // Always execute on main thread
        assert(Thread.isMainThread, "Must be called from main thread")
        
        do {
            // Sử dụng cấu hình từ RealmManager chung
            let realm = try Realm(configuration: realmManager.getConfiguration())
            let articleObjects = realm.objects(ArticleObject.self)
                .sorted(byKeyPath: "savedDate", ascending: false)
                .freeze() // Ensure safety
            
            let articles = Array(articleObjects.map { $0.toArticle() })
            print("DEBUG - OfflineArticleRepository: Retrieved \(articles.count) offline articles")
            return articles
        } catch let error {
            print("DEBUG - OfflineArticleRepository: Error retrieving articles: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteAllOfflineArticles() -> Result<Void, Error> {
        assert(Thread.isMainThread, "Must be called from main thread")
        print("DEBUG - OfflineArticleRepository: Deleting all offline articles")
        
        do {
            // Sử dụng cấu hình từ RealmManager chung
            let realm = try Realm(configuration: realmManager.getConfiguration())
            try realm.write {
                let allArticles = realm.objects(ArticleObject.self)
                realm.delete(allArticles)
            }
            print("DEBUG - OfflineArticleRepository: Successfully deleted all articles")
            return .success(())
        } catch let error {
            print("DEBUG - OfflineArticleRepository: Failed to delete articles: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    func getOfflineArticlesCount() -> Int {
        do {
            // Sử dụng cấu hình từ RealmManager chung
            let realm = try Realm(configuration: realmManager.getConfiguration())
            let count = realm.objects(ArticleObject.self).count
            print("DEBUG - OfflineArticleRepository: Offline article count: \(count)")
            return count
        } catch {
            print("DEBUG - OfflineArticleRepository: Error getting article count: \(error.localizedDescription)")
            return 0
        }
    }
}
