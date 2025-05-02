//
//  NewsSource.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int?
    let results: [Article]?
    let nextPage: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case totalResults
        case results
        case nextPage
    }
}
