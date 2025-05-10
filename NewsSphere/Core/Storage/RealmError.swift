//
//  RealmError.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 13/3/25.
//

import Foundation
import RealmSwift

// MARK: - Realm Manager Errors
enum RealmError: Error {
    case realmNotInitialized
    case invalidArticle
    case writeError(Error)
    case articleNotFound
    case maxLimitReached
    
    var localizedDescription: String {
        switch self {
        case .realmNotInitialized:
            return "Realm database not initialized"
        case .invalidArticle:
            return "Cannot save article without a valid URL"
        case .writeError(let error):
            return "Database write error: \(error.localizedDescription)"
        case .articleNotFound:
            return "Article not found in database"
        case .maxLimitReached:
            return "Maximum number of allowed items reached"
        }
    }
}
