import UIKit
import Stevia

class SplashScreenViewController: UIViewController {
    
    private let logoImageView = UIImageView()
    private weak var coordinator: AppCoordinator?
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStyle()
        setupConstraints()
        
        // Set timer for splash screen duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) { [weak self] in
            self?.coordinator?.finishSplashScreen()
        }
    }
    
    private func setupView() {
        view.subviews {
            logoImageView
        }
    }
    
    private func setupStyle() {
        view.backgroundColor = .black
        logoImageView.image = UIImage(named: "Logo")
        logoImageView.contentMode = .scaleAspectFit
    }
    
    private func setupConstraints() {
        logoImageView.centerInContainer()
        logoImageView.width(140)
        logoImageView.height(140)
    }
}
