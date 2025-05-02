//
//  Article.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation

struct Article: Codable {
    let articleId: String?
    let title: String?
    let link: String?
    let keywords: [String]?
    let creator: [String]?
    let videoUrl: String?
    let description: String?
    let content: String?
    let pubDate: String?
    let imageUrl: String?
    let sourceId: String?
    let sourceName: String?
    let sourceUrl: String?
    let sourceIcon: String?
    let language: String?
    let category: [String]?
    let country: [String]?
    
    func formattedDate() -> String? {
        guard let pubDate = pubDate else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = dateFormatter.date(from: pubDate) else { return pubDate }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}

struct Source: Codable {
    let id: String?
    let name: String?
    let description: String?
    let url: String?
    let category: String
    let language: String?
    let country: String?
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case description
        case url
        case category
        case language
        case country
    }
}

struct Sources: Codable {
    let status: String?
    let sources: [Source]
}
