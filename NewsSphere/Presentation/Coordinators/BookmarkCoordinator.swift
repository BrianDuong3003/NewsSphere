import UIKit

protocol BookmarkCoordinatorProtocol: AnyObject {
    func navigateBack()
    func openArticleDetail(article: Article)
}

class BookmarkCoordinator: Coordinator, BookmarkCoordinatorProtocol {
    // MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let repository: ArticleRepositoryProtocol
    private let bookmarkRepository: BookmarkRepositoryProtocol
    
    // MARK: - Initialization
    init(navigationController: UINavigationController,
         repository: ArticleRepositoryProtocol,
         bookmarkRepository: BookmarkRepositoryProtocol) {
        self.navigationController = navigationController
        self.repository = repository
        self.bookmarkRepository = bookmarkRepository
    }
    
    // MARK: - Coordinator Methods
    func start() {
        let viewController = BookmarkViewController()
        let viewModel = BookmarkViewModel(coordinator: self, repository: bookmarkRepository)
        viewController.viewModel = viewModel
        navigationController.pushViewController(viewController, animated: true)
    }
    
    // MARK: - BookmarkCoordinatorProtocol
    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
    
    func openArticleDetail(article: Article) {
        let detailCoordinator = ArticleDetailCoordinator(
            navigationController: navigationController,
            article: article,
            repository: repository,
            bookmarkRepository: bookmarkRepository
        )
        childCoordinators.append(detailCoordinator)
        detailCoordinator.start()
    }
}
