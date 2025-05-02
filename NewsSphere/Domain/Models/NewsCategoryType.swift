//
//  NewsCategoryType.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 27/4/25.
//


import Foundation
import UIKit

enum NewsCategoryType: String, CaseIterable {
    case latestNews
    case yourNews
    case local
    case business
    case crime
    case domestic
    case education
    case entertainment
    case environment
    case food
    case health
    case lifestyle
    case other
    case politics
    case science
    case sports
    case technology
    case top
    case tourism
    case world
    
    var displayName: String {
        switch self {
        case .latestNews:
            return "Latest News"
        case .yourNews:
            return "Your News"
        case .local:
            return "Local"
        default:
            return rawValue.capitalized
        }
    }
    
    var title: String {
        return displayName
    }
    
    var apiValue: String {
        switch self {
        case .yourNews: return "general"
        case .local: return "local"
        case .entertainment: return "entertainment"
        case .sports: return "sports"
        case .science: return "science"
        case .business: return "business"
        case .technology: return "technology"
        case .education: return "education"
        default: return rawValue
        }
    }
    
    var image: UIImage {
        switch self {
        case .latestNews:
            return .latestNew
        case .yourNews:
//            return UIImage(named: "general") ?? UIImage()
            return .yourNews
        case .local:
//            return UIImage(named: "local") ?? UIImage()
            return .localNews
        case .business:
            return .business
        case .crime:
            return .crime
        case .domestic:
            return .domestic
        case .education:
            return .education
        case .entertainment:
            return .entertainment
        case .environment:
            return .enviroment
        case .food:
            return .food
        case .health:
            return .health
        case .lifestyle:
            return .lifestyle
        case .other:
            return .lifestyle
        case .politics:
            return .politic
        case .science:
            return .science
        case .sports:
            return .sport
        case .technology:
            return .technology
        case .top:
            return .top
        case .tourism:
            return .tourism
        case .world:
            return .world
        }
    }
}
