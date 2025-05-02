//
//  DiscoveryViewModel.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 6/3/25.
//

import Foundation

class DiscoveryViewModel {
    private let categoryRepository = CategoryRepository()
    private var categories: [String] = []
        
//    func fetchCategories(completion: @escaping ([String]) -> Void) {
//        categoryRepository.fetchCategories { [weak self] result in
//            switch result {
//            case .success(let categories):
//                self?.categories = categories
//                DispatchQueue.main.async {
//                    completion(categories)
//                }
//            case .failure(let error):
//                print("Failed to fetch categories: \(error)")
//                DispatchQueue.main.async {
//                    completion([])
//                }
//            }
//        }
//    }
}
