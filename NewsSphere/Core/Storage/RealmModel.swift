//
//  RealmModel.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 13/3/25.
//

import Foundation
import RealmSwift

// MARK: - Realm Article Model
final class ArticleObject: Object {
    @Persisted(primaryKey: true) var link: String = ""
    @Persisted var title: String = ""
    @Persisted var articleDescription: String = ""
    @Persisted var creator: String = ""
    @Persisted var imageUrl: String = ""
    @Persisted var pubDate: String = ""
    @Persisted var content: String = ""
    @Persisted var sourceId: String = ""
    @Persisted var sourceName: String = ""
    @Persisted var savedDate: Date = Date()
    
    convenience init(article: Article) {
        self.init()
        self.link = article.link ?? ""
        self.title = article.title ?? ""
        self.articleDescription = article.description ?? ""
        self.creator = article.creator?.first ?? ""
        self.imageUrl = article.imageUrl ?? ""
        self.pubDate = article.pubDate ?? ""
        self.content = article.content ?? ""
        self.sourceId = article.sourceId ?? ""
        self.sourceName = article.sourceName ?? ""
        self.savedDate = Date()
    }
    
    func toArticle() -> Article {
        return Article(
            articleId: nil,
            title: title,
            link: link,
            keywords: nil,
            creator: [creator],
            videoUrl: nil,
            description: articleDescription,
            content: content,
            pubDate: pubDate,
            imageUrl: imageUrl,
            sourceId: sourceId,
            sourceName: sourceName,
            sourceUrl: nil,
            sourceIcon: nil,
            language: nil,
            category: nil,
            country: nil
        )
    }
}

class SearchHistoryObject: Object {
    @objc dynamic var keyword: String = ""
    @objc dynamic var searchDate: Date = Date()
    
    override static func primaryKey() -> String? {
        return "keyword" 
    }
}
