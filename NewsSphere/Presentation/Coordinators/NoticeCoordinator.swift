//
//  NoticeCoorDinator.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 12/3/25.
//

import Foundation
import UIKit

class NoticeCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    let navigationController: UINavigationController
    weak var parentCoordinator: MainCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        
    }
    
    func didFinish() {
        parentCoordinator?.childDidFinish(self)
    }
}
