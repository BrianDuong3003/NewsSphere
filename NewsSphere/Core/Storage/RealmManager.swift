//
//  RealmManager.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation
import RealmSwift
import FirebaseAuth

// MARK: - Realm Manager
final class RealmManager {
    // MARK: - Properties
    private let queue = DispatchQueue(label: "com.newssphere.realmQueue",
                                      qos: .userInitiated, attributes: .concurrent)
    private var realm: Realm?
    private let configuration: Realm.Configuration
    private let userUID: String?
    
    // MARK: - Initialization
    init?(userUID: String?) {
        guard let uid = userUID, !uid.isEmpty else {
            print("DEBUG - RealmManager: Cannot initialize without a valid user UID.")
            return nil
        }
        
        self.userUID = uid
        
        // Create configuration specific to the user
        self.configuration = Self.createConfiguration(forUser: uid)
        
        do {
            realm = try Realm(configuration: configuration)
            print("DEBUG - RealmManager: Realm initialized successfully for user \(uid) at: \(String(describing: configuration.fileURL))")
        } catch {
            print("DEBUG - RealmManager: Failed to initialize Realm: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Static method to create Realm configuration for a specific user
    private static func createConfiguration(forUser uid: String) -> Realm.Configuration {
        var config = Realm.Configuration.defaultConfiguration
        
        // Create a unique file path for this user's Realm database
        var fileURL = config.fileURL!
        fileURL.deleteLastPathComponent() // Remove "default.realm"
        
        // Create "user_realms" directory if it doesn't exist
        let userRealmsURL = fileURL.appendingPathComponent("user_realms", isDirectory: true)
        if !FileManager.default.fileExists(atPath: userRealmsURL.path) {
            try? FileManager.default.createDirectory(at: userRealmsURL, 
                                                    withIntermediateDirectories: true, 
                                                    attributes: nil)
        }
        
        // Set the file URL to user-specific path
        fileURL = userRealmsURL.appendingPathComponent("\(uid).realm") 
        config.fileURL = fileURL
        
        // Keep existing migration settings
        config.schemaVersion = 2
        config.migrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < 2 {
                print("DEBUG - RealmManager: Performing migration from schema version \(oldSchemaVersion) to 2 for user \(uid)")
            }
        }
        
        return config
    }
    
    // MARK: - Private Methods
    private func safeWrite(_ block: @escaping (Realm) -> Void) throws {
        guard let realm = realm else {
            throw RealmError.realmNotInitialized
        }
        
        try queue.sync {
            if realm.isInWriteTransaction {
                block(realm)
            } else {
                try realm.write {
                    block(realm)
                }
            }
        }
    }
    
    // MARK: - Public Methods
    
    // Saves an article to the database
    func saveArticle(_ article: Article) -> Result<Void, RealmError> {
        guard let link = article.link, !link.isEmpty else {
            return .failure(.invalidArticle)
        }
        
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
    
    // Retrieves all saved articles
    func getSavedArticles() -> [Article] {
        guard let realm = realm else { return [] }
        
        return queue.sync {
            // Use frozen objects to avoid threading issues
            let articleObjects = realm.objects(ArticleObject.self)
                .sorted(byKeyPath: "savedDate", ascending: false)
                .freeze()
            
            return articleObjects.map { $0.toArticle() }
        }
    }
    
    // Checks if an article is already saved
    func isArticleSaved(link: String) -> Bool {
        guard let realm = realm else { return false }
        
        return queue.sync {
            return realm.object(ofType: ArticleObject.self, forPrimaryKey: link) != nil
        }
    }
    
    // Deletes a specific article
    func deleteArticle(link: String) -> Result<Void, RealmError> {
        guard let realm = realm else {
            return .failure(.realmNotInitialized)
        }
        
        guard let articleObject = queue.sync(execute: { realm.object(ofType: ArticleObject.self, forPrimaryKey: link) }) else {
            return .failure(.articleNotFound)
        }
        
        do {
            try safeWrite { realm in
                if let objectToDelete = realm.object(ofType: ArticleObject.self, forPrimaryKey: link) {
                    realm.delete(objectToDelete)
                }
            }
            return .success(())
        } catch let error as RealmError {
            return .failure(error)
        } catch {
            return .failure(.writeError(error))
        }
    }
    
    // Deletes all saved articles
    func deleteAllArticles() -> Result<Void, RealmError> {
        guard let realm = realm else {
            return .failure(.realmNotInitialized)
        }
        
        do {
            try safeWrite { realm in
                let articleObjects = realm.objects(ArticleObject.self)
                realm.delete(articleObjects)
            }
            return .success(())
        } catch let error as RealmError {
            return .failure(error)
        } catch {
            return .failure(.writeError(error))
        }
    }
    
    // Gets the count of saved articles
    func getSavedArticlesCount() -> Int {
        guard let realm = realm else { return 0 }
        
        return queue.sync {
            return realm.objects(ArticleObject.self).count
        }
    }
    
    func saveSearchHistory(keyword: String) {
        guard let realm = realm else { return }
        
        let searchHistory = SearchHistoryObject()
        searchHistory.keyword = keyword
        searchHistory.searchDate = Date()
        
        do {
            try safeWrite { realm in
                realm.add(searchHistory, update: .modified)
            }
        } catch {
            print("Error saving search history: \(error)")
        }
    }
    
    func getSearchHistory() -> [SearchHistoryObject] {
        guard let realm = realm else { return [] }
        
        return queue.sync {
            let results = realm.objects(SearchHistoryObject.self).sorted(
                byKeyPath: "searchDate", ascending: false)
                .freeze()
            return Array(results)
        }
    }
    
    func deleteSearchHistory(keyword: String) {
        guard let realm = realm else { return }
        
        do {
            try safeWrite { realm in
                let results = realm.objects(SearchHistoryObject.self).filter("keyword == %@", keyword)
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
            
            try safeWrite { realm in
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
        
        return queue.sync {
            let user = realm.object(ofType: UserObject.self, forPrimaryKey: email)?.freeze()
            print("DEBUG - RealmManager: Retrieved user: \(user?.firstName ?? "not found") \(user?.lastName ?? "")")
            return user
        }
    }
    
    // MARK: - Bookmark Methods
    
    // Save bookmark
    func saveBookmark(_ article: Article) -> Result<Void, RealmError> {
        guard let link = article.link, !link.isEmpty else {
            return .failure(.invalidArticle)
        }
        
        do {
            // save article if it doesn't exist
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
    
    func isBookmarked(link: String) -> Bool {
        guard let realm = realm else { return false }
        
        return queue.sync {
            return realm.object(ofType: BookmarkLinkObject.self, forPrimaryKey: link) != nil
        }
    }
    
    func getBookmarkedArticles() -> [Article] {
        guard let realm = realm else { return [] }
        
        return queue.sync {
            // get bookmark links
            let bookmarkLinks = realm.objects(BookmarkLinkObject.self)
                .sorted(byKeyPath: "bookmarkedDate", ascending: false)
                .freeze()
            
            var articles: [Article] = []
            
            // Open a new Realm instance on the current thread to access frozen objects
            let currentRealm = try! Realm(configuration: self.configuration)
            
            for bookmarkLink in bookmarkLinks {
                if let articleObject = currentRealm.object(ofType: ArticleObject.self, 
                                                  forPrimaryKey: bookmarkLink.link)?.freeze() {
                    articles.append(articleObject.toArticle())
                }
            }
            
            return articles
        }
    }
    
    func deleteBookmark(link: String) -> Result<Void, RealmError> {
        guard let realm = realm else {
            return .failure(.realmNotInitialized)
        }
        
        guard let bookmarkObject = queue.sync(execute: { realm.object(ofType: BookmarkLinkObject.self, forPrimaryKey: link) }) else {
            return .failure(.articleNotFound)
        }
        
        do {
            try safeWrite { realm in
                if let objectToDelete = realm.object(ofType: BookmarkLinkObject.self, forPrimaryKey: link) {
                    realm.delete(objectToDelete)
                }
            }
            return .success(())
        } catch let error as RealmError {
            return .failure(error)
        } catch {
            return .failure(.writeError(error))
        }
    }
    
    func deleteAllBookmarks() -> Result<Void, RealmError> {
        guard let realm = realm else {
            return .failure(.realmNotInitialized)
        }
        
        do {
            try safeWrite { realm in
                let bookmarkObjects = realm.objects(BookmarkLinkObject.self)
                realm.delete(bookmarkObjects)
            }
            return .success(())
        } catch let error as RealmError {
            return .failure(error)
        } catch {
            return .failure(.writeError(error))
        }
    }
    
    // MARK: - Offline Article Methods
    
    func saveOfflineArticle(_ article: Article) -> Result<Void, RealmError> {
        guard let link = article.link, !link.isEmpty else {
            return .failure(.invalidArticle)
        }
        
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
    
    func isOfflineSaved(link: String) -> Bool {
        guard let realm = realm else { return false }
        
        return queue.sync {
            return realm.object(ofType: OfflineLinkObject.self, forPrimaryKey: link) != nil
        }
    }
    
    func getOfflineArticles() -> [Article] {
        guard let realm = realm else { return [] }
        
        return queue.sync {
            let offlineLinks = realm.objects(OfflineLinkObject.self)
                .sorted(byKeyPath: "savedOfflineDate", ascending: false)
                .freeze()
            
            var articles: [Article] = []
            
            // Open a new Realm instance on the current thread to access frozen objects
            let currentRealm = try! Realm(configuration: self.configuration)
            
            for offlineLink in offlineLinks {
                if let articleObject = currentRealm.object(ofType: ArticleObject.self, 
                                                 forPrimaryKey: offlineLink.link)?.freeze() {
                    articles.append(articleObject.toArticle())
                }
            }
            
            return articles
        }
    }
    
    func saveOfflineArticles(_ articles: [Article]) -> Result<Int, RealmError> {
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
    
    func deleteOfflineArticle(link: String) -> Result<Void, RealmError> {
        guard let realm = realm else {
            return .failure(.realmNotInitialized)
        }
        
        guard let offlineObject = queue.sync(execute: { realm.object(ofType: OfflineLinkObject.self, forPrimaryKey: link) }) else {
            return .failure(.articleNotFound)
        }
        
        do {
            try safeWrite { realm in
                if let objectToDelete = realm.object(ofType: OfflineLinkObject.self, forPrimaryKey: link) {
                    realm.delete(objectToDelete)
                }
            }
            return .success(())
        } catch let error as RealmError {
            return .failure(error)
        } catch {
            return .failure(.writeError(error))
        }
    }
    
    func deleteAllOfflineArticles() -> Result<Void, RealmError> {
        guard let realm = realm else {
            return .failure(.realmNotInitialized)
        }
        
        do {
            try safeWrite { realm in
                let offlineObjects = realm.objects(OfflineLinkObject.self)
                realm.delete(offlineObjects)
            }
            return .success(())
        } catch let error as RealmError {
            return .failure(error)
        } catch {
            return .failure(.writeError(error))
        }
    }
    
    // MARK: - Garbage Collection
    
    // Delete articles which are not used by bookmark or offline
    func cleanupUnusedArticles() -> Result<Int, RealmError> {
        guard let realm = realm else {
            return .failure(.realmNotInitialized)
        }
        
        do {
            var usedLinks = Set<String>()
            var deleteCount = 0
            
            try safeWrite { realm in
                // Perform all operations in a single transaction for consistency
                let bookmarkLinks = realm.objects(BookmarkLinkObject.self)
                let offlineLinks = realm.objects(OfflineLinkObject.self)
                
                for bookmark in bookmarkLinks {
                    usedLinks.insert(bookmark.link)
                }
                
                for offline in offlineLinks {
                    usedLinks.insert(offline.link)
                }
                
                let allArticles = realm.objects(ArticleObject.self)
                var articlesToDelete: [ArticleObject] = []
                
                for article in allArticles {
                    if !usedLinks.contains(article.link) {
                        articlesToDelete.append(article)
                    }
                }
                
                deleteCount = articlesToDelete.count
                
                if deleteCount > 0 {
                    print("DEBUG - RealmManager: Deleting \(deleteCount) unused articles")
                    realm.delete(articlesToDelete)
                }
            }
            
            return .success(deleteCount)
        } catch let error as RealmError {
            return .failure(error)
        } catch {
            return .failure(.writeError(error))
        }
    }
    
    // MARK: - Favorite Category Management
    
    // Save Fav Category
    func saveFavoriteCategory(_ category: NewsCategoryType) -> Result<Void, RealmError> {
        guard let realm = realm else {
            return .failure(.realmNotInitialized)
        }
        
        // limit the number of category
        let maxCategories = 3
        let currentCount = getFavoriteCategoriesCount()
        
        if currentCount >= maxCategories {
            return .failure(.maxLimitReached)
        }
        
        do {
            let categoryObject = FavoriteCategoryObject(category: category)
            try safeWrite { realm in
                realm.add(categoryObject, update: .modified)
            }
            return .success(())
        } catch let error as RealmError {
            return .failure(error)
        } catch {
            return .failure(.writeError(error))
        }
    }
    
    // remove fav category
    func removeFavoriteCategory(_ category: NewsCategoryType) -> Result<Void, RealmError> {
        guard let realm = realm else {
            return .failure(.realmNotInitialized)
        }
        
        do {
            try safeWrite { realm in
                if let objectToDelete = realm.object(ofType: FavoriteCategoryObject.self, forPrimaryKey: category.apiValue) {
                    realm.delete(objectToDelete)
                }
            }
            return .success(())
        } catch let error as RealmError {
            return .failure(error)
        } catch {
            return .failure(.writeError(error))
        }
    }
    
    // save all fav category
    func getAllFavoriteCategories() -> [NewsCategoryType] {
        guard let realm = realm else { return [] }
        
        return queue.sync {
            let categoryObjects = realm.objects(FavoriteCategoryObject.self)
                .sorted(byKeyPath: "savedDate", ascending: false)
                .freeze()
            
            return categoryObjects.compactMap { $0.toNewsCategoryType() }
        }
    }
    
    // check if the category has been chosen or not
    func isFavoriteCategory(_ category: NewsCategoryType) -> Bool {
        guard let realm = realm else { return false }
        
        return queue.sync {
            return realm.object(ofType: FavoriteCategoryObject.self, forPrimaryKey: category.apiValue) != nil
        }
    }
    
    // delete all fav category
    func clearAllFavoriteCategories() -> Result<Void, RealmError> {
        guard let realm = realm else {
            return .failure(.realmNotInitialized)
        }
        
        do {
            try safeWrite { realm in
                let categoryObjects = realm.objects(FavoriteCategoryObject.self)
                realm.delete(categoryObjects)
            }
            return .success(())
        } catch let error as RealmError {
            return .failure(error)
        } catch {
            return .failure(.writeError(error))
        }
    }
    
    // get the number of fav category
    func getFavoriteCategoriesCount() -> Int {
        guard let realm = realm else { return 0 }
        
        return queue.sync {
            return realm.objects(FavoriteCategoryObject.self).count
        }
    }
    
    // get max allowed category
    func getMaxAllowedCategories() -> Int {
        return 3
    }
}
