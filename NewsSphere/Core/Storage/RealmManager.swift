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
        configuration = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    print("DEBUG - RealmManager: Performing migration from schema version \(oldSchemaVersion) to 2")
                    
                }
            },
            deleteRealmIfMigrationNeeded: true
        )
        
        do {
            realm = try Realm(configuration: configuration)
            print("DEBUG - RealmManager: Realm initialized successfully at: \(String(describing: configuration.fileURL))")
        } catch {
            print("DEBUG - RealmManager: Failed to initialize Realm: \(error.localizedDescription)")
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
    
    // Saves an article to the database
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
    
    // Retrieves all saved articles
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
    
    // Checks if an article is already saved
    func isArticleSaved(link: String) -> Bool {
        return queue.sync {
            guard let realm = realm else { return false }
            return realm.object(ofType: ArticleObject.self, forPrimaryKey: link) != nil
        }
    }
    
    // Deletes a specific article
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
    
    // Deletes all saved articles
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
    
    // Gets the count of saved articles
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
    
    // MARK: - Public Access to Configuration
    func getConfiguration() -> Realm.Configuration {
        return configuration
    }
    
    // MARK: - Helper Methods for Creating Realm Instances
    func getRealm() -> Realm? {
        if let existingRealm = realm {
            return existingRealm
        }
        
        do {
            let newRealm = try Realm(configuration: configuration)
            print("DEBUG - RealmManager: Created a new Realm instance")
            return newRealm
        } catch {
            print("DEBUG - RealmManager: Failed to create a new Realm instance: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - User Management
    
    func saveUser(email: String, firstName: String, lastName: String) {
        print("DEBUG - RealmManager: Attempting to save user with email: \(email)")

        do {
            guard let realm = realm else {
                print("DEBUG - RealmManager: Realm still not initialized after re-initialization attempt")
                return
            }
            
            let userObject = UserObject(email: email, firstName: firstName, lastName: lastName)
            
            try realm.write {
                realm.add(userObject, update: .modified)
                print("DEBUG - RealmManager: User saved successfully: \(firstName) \(lastName)")
            }
        } catch {
            print("DEBUG - RealmManager: Failed to save user: \(error.localizedDescription)")
        }
    }
    
    func getUser(email: String) -> UserObject? {
        guard let realm = realm else {
            print("DEBUG - RealmManager: Realm not initialized when getting user")
            return nil
        }
        
        let user = realm.object(ofType: UserObject.self, forPrimaryKey: email)
        print("DEBUG - RealmManager: Retrieved user: \(user?.firstName ?? "not found") \(user?.lastName ?? "")")
        return user
    }
    
    // MARK: - Bookmark Methods
    
    // Lưu bookmark
    func saveBookmark(_ article: Article) -> Result<Void, RealmError> {
        guard let link = article.link, !link.isEmpty else {
            return .failure(.invalidArticle)
        }
        
        return queue.sync {
            do {
                // save article if it s not exist
                let articleObject = ArticleObject(article: article)
                try safeWrite { realm in
                    realm.add(articleObject, update: .modified)
                }
                
                // save bookmark link
                let bookmarkLink = BookmarkLinkObject(link: link)
                try safeWrite { realm in
                    realm.add(bookmarkLink, update: .modified)
                }
                
                return .success(())
            } catch let error as RealmError {
                return .failure(error)
            } catch {
                return .failure(.writeError(error))
            }
        }
    }
    
    func isBookmarked(link: String) -> Bool {
        return queue.sync {
            guard let realm = realm else { return false }
            return realm.object(ofType: BookmarkLinkObject.self, forPrimaryKey: link) != nil
        }
    }
    
    func getBookmarkedArticles() -> [Article] {
        return queue.sync {
            guard let realm = realm else { return [] }
            
            // get bookmark links
            let bookmarkLinks = realm.objects(BookmarkLinkObject.self)
                .sorted(byKeyPath: "bookmarkedDate", ascending: false)
                .freeze()
            
            var articles: [Article] = []
            
            for bookmarkLink in bookmarkLinks {
                if let articleObject = realm.object(ofType: ArticleObject.self, 
                                                   forPrimaryKey: bookmarkLink.link)?.freeze() {
                    articles.append(articleObject.toArticle())
                }
            }
            
            return articles
        }
    }
    
    func deleteBookmark(link: String) -> Result<Void, RealmError> {
        return queue.sync {
            guard let realm = realm else {
                return .failure(.realmNotInitialized)
            }
            
            guard let bookmarkObject = realm.object(ofType: BookmarkLinkObject.self,
                                                  forPrimaryKey: link) else {
                return .failure(.articleNotFound)
            }
            
            do {
                try safeWrite { realm in
                    realm.delete(bookmarkObject)
                }
                return .success(())
            } catch let error as RealmError {
                return .failure(error)
            } catch {
                return .failure(.writeError(error))
            }
        }
    }
    
    func deleteAllBookmarks() -> Result<Void, RealmError> {
        return queue.sync {
            guard let realm = realm else {
                return .failure(.realmNotInitialized)
            }
            
            do {
                let bookmarkObjects = realm.objects(BookmarkLinkObject.self)
                try safeWrite { realm in
                    realm.delete(bookmarkObjects)
                }
                return .success(())
            } catch let error as RealmError {
                return .failure(error)
            } catch {
                return .failure(.writeError(error))
            }
        }
    }
    
    // MARK: - Offline Article Methods
    
    func saveOfflineArticle(_ article: Article) -> Result<Void, RealmError> {
        guard let link = article.link, !link.isEmpty else {
            return .failure(.invalidArticle)
        }
        
        return queue.sync {
            do {
                let articleObject = ArticleObject(article: article)
                try safeWrite { realm in
                    realm.add(articleObject, update: .modified)
                }
                
                let offlineLink = OfflineLinkObject(link: link)
                try safeWrite { realm in
                    realm.add(offlineLink, update: .modified)
                }
                
                return .success(())
            } catch let error as RealmError {
                return .failure(error)
            } catch {
                return .failure(.writeError(error))
            }
        }
    }
    
    func isOfflineSaved(link: String) -> Bool {
        return queue.sync {
            guard let realm = realm else { return false }
            return realm.object(ofType: OfflineLinkObject.self, forPrimaryKey: link) != nil
        }
    }
    
    func getOfflineArticles() -> [Article] {
        return queue.sync {
            guard let realm = realm else { return [] }
            
            let offlineLinks = realm.objects(OfflineLinkObject.self)
                .sorted(byKeyPath: "savedOfflineDate", ascending: false)
                .freeze()
            
            var articles: [Article] = []
            
            for offlineLink in offlineLinks {
                if let articleObject = realm.object(ofType: ArticleObject.self, 
                                                   forPrimaryKey: offlineLink.link)?.freeze() {
                    articles.append(articleObject.toArticle())
                }
            }
            
            return articles
        }
    }
    
    func saveOfflineArticles(_ articles: [Article]) -> Result<Int, RealmError> {
        return queue.sync {
            guard let realm = realm else {
                return .failure(.realmNotInitialized)
            }
            
            var savedCount = 0
            
            do {
                try safeWrite { realm in
                    for article in articles {
                        guard let link = article.link, !link.isEmpty else { continue }
                        
                        let articleObject = ArticleObject(article: article)
                        realm.add(articleObject, update: .modified)
                        
                        let offlineLink = OfflineLinkObject(link: link)
                        realm.add(offlineLink, update: .modified)
                        
                        savedCount += 1
                    }
                }
                
                return .success(savedCount)
            } catch let error as RealmError {
                return .failure(error)
            } catch {
                return .failure(.writeError(error))
            }
        }
    }
    
    func deleteOfflineArticle(link: String) -> Result<Void, RealmError> {
        return queue.sync {
            guard let realm = realm else {
                return .failure(.realmNotInitialized)
            }
            
            guard let offlineObject = realm.object(ofType: OfflineLinkObject.self,
                                                 forPrimaryKey: link) else {
                return .failure(.articleNotFound)
            }
            
            do {
                try safeWrite { realm in
                    realm.delete(offlineObject)
                }
                return .success(())
            } catch let error as RealmError {
                return .failure(error)
            } catch {
                return .failure(.writeError(error))
            }
        }
    }
    
    func deleteAllOfflineArticles() -> Result<Void, RealmError> {
        return queue.sync {
            guard let realm = realm else {
                return .failure(.realmNotInitialized)
            }
            
            do {
                let offlineObjects = realm.objects(OfflineLinkObject.self)
                try safeWrite { realm in
                    realm.delete(offlineObjects)
                }
                return .success(())
            } catch let error as RealmError {
                return .failure(error)
            } catch {
                return .failure(.writeError(error))
            }
        }
    }
    
    // MARK: - Dọn dẹp dữ liệu (Garbage Collection)
    
    // Delete articles which used by bookmark or offline
    func cleanupUnusedArticles() -> Result<Int, RealmError> {
        return queue.sync {
            guard let realm = realm else {
                return .failure(.realmNotInitialized)
            }
            
            do {
                let allArticles = realm.objects(ArticleObject.self)
                let bookmarkLinks = realm.objects(BookmarkLinkObject.self)
                let offlineLinks = realm.objects(OfflineLinkObject.self)
                
                var usedLinks = Set<String>()
                
                for bookmark in bookmarkLinks {
                    usedLinks.insert(bookmark.link)
                }
                
                for offline in offlineLinks {
                    usedLinks.insert(offline.link)
                }
                
                var articlesToDelete: [ArticleObject] = []
                
                for article in allArticles {
                    if !usedLinks.contains(article.link) {
                        articlesToDelete.append(article)
                    }
                }
                
                let deleteCount = articlesToDelete.count
                
                if deleteCount > 0 {
                    try safeWrite { realm in
                        for article in articlesToDelete {
                            realm.delete(article)
                        }
                    }
                }
                
                return .success(deleteCount)
            } catch let error as RealmError {
                return .failure(error)
            } catch {
                return .failure(.writeError(error))
            }
        }
    }
}
