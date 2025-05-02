//
//  RealmManager.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation
import RealmSwift

// MARK: - Realm Manager
final class RealmManager {
    // MARK: - Properties
    static let shared = RealmManager()
    private let queue = DispatchQueue(label: "com.newssphere.realmQueue",
                                      qos: .userInitiated, attributes: .concurrent)
    private var realm: Realm?
    private let configuration: Realm.Configuration
    
    // MARK: - Initialization
    private init() {
        // Create a configuration with a higher schema version when model changes
        configuration = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                // Handle future schema migrations here
                if oldSchemaVersion < 1 {
                    // Nothing to do for now
                }
            }
        )
        
        do {
            realm = try Realm(configuration: configuration)
#if DEBUG
            print("Realm database location: \(String(describing: configuration.fileURL))")
#endif
        } catch {
            print("Failed to initialize Realm: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    private func safeWrite(_ block: @escaping (Realm) -> Void) throws {
        guard let realm = realm else {
            throw RealmError.realmNotInitialized
        }
        
        if realm.isInWriteTransaction {
            block(realm)
        } else {
            try realm.write {
                block(realm)
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Saves an article to the database
    /// - Parameter article: The article to save
    /// - Returns: Result with success or error
    func saveArticle(_ article: Article) -> Result<Void, RealmError> {
        guard let link = article.link, !link.isEmpty else {
            return .failure(.invalidArticle)
        }
        
        return queue.sync {
            do {
                let articleObject = ArticleObject(article: article)
                try safeWrite { realm in
                    realm.add(articleObject, update: .modified)
                }
                return .success(())
            } catch let error as RealmError {
                return .failure(error)
            } catch {
                return .failure(.writeError(error))
            }
        }
    }
    
    /// Retrieves all saved articles
    /// - Returns: Array of Articles sorted by save date (newest first)
    func getSavedArticles() -> [Article] {
        return queue.sync {
            guard let realm = realm else { return [] }
            
            // Use frozen objects to avoid threading issues
            let articleObjects = realm.objects(ArticleObject.self)
                .sorted(byKeyPath: "savedDate", ascending: false)
                .freeze()
            
            return articleObjects.map { $0.toArticle() }
        }
    }
    
    /// Checks if an article is already saved
    /// - Parameter link: The URL of the article to check
    /// - Returns: Boolean indicating if the article exists
    func isArticleSaved(link: String) -> Bool {
        return queue.sync {
            guard let realm = realm else { return false }
            return realm.object(ofType: ArticleObject.self, forPrimaryKey: link) != nil
        }
    }
    
    /// Deletes a specific article
    /// - Parameter link: The URL of the article to delete
    /// - Returns: Result with success or error
    func deleteArticle(link: String) -> Result<Void, RealmError> {
        return queue.sync {
            guard let realm = realm else {
                return .failure(.realmNotInitialized)
            }
            
            guard let articleObject = realm.object(ofType: ArticleObject.self,
                                                   forPrimaryKey: link) else {
                return .failure(.articleNotFound)
            }
            
            do {
                try safeWrite { realm in
                    realm.delete(articleObject)
                }
                return .success(())
            } catch let error as RealmError {
                return .failure(error)
            } catch {
                return .failure(.writeError(error))
            }
        }
    }
    
    /// Deletes all saved articles
    /// - Returns: Result with success or error
    func deleteAllArticles() -> Result<Void, RealmError> {
        return queue.sync {
            guard let realm = realm else {
                return .failure(.realmNotInitialized)
            }
            
            do {
                let articleObjects = realm.objects(ArticleObject.self)
                try safeWrite { realm in
                    realm.delete(articleObjects)
                }
                return .success(())
            } catch let error as RealmError {
                return .failure(error)
            } catch {
                return .failure(.writeError(error))
            }
        }
    }
    
    /// Gets the count of saved articles
    /// - Returns: Number of saved articles
    func getSavedArticlesCount() -> Int {
        return queue.sync {
            guard let realm = realm else { return 0 }
            return realm.objects(ArticleObject.self).count
        }
    }
    func saveSearchHistory(keyword: String) {
        guard let realm = realm else { return }
        let searchHistory = SearchHistoryObject()
        searchHistory.keyword = keyword
        searchHistory.searchDate = Date()  
        
        do {
            try realm.write {
                realm.add(searchHistory, update: .modified)
            }
        } catch {
            print("Error saving search history: \(error)")
        }
    }
    func getSearchHistory() -> [SearchHistoryObject] {
        guard let realm = realm else { return [] }
        let results = realm.objects(SearchHistoryObject.self).sorted(
            byKeyPath: "searchDate", ascending: false)
        return Array(results)
    }
    func deleteSearchHistory(keyword: String) {
        guard let realm = realm else { return }
        
        let results = realm.objects(SearchHistoryObject.self).filter("keyword == %@", keyword)
        do {
            try realm.write {
                realm.delete(results)
            }
        } catch {
            print("Error deleting search history: \(error)")
        }
    }
    
}
