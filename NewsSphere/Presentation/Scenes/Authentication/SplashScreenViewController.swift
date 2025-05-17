import UIKit
import Stevia

class SplashScreenViewController: UIViewController {
    
    let logoImageView = UIImageView()
    let appLabel = UILabel()
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
            appLabel
        }
    }
    
    private func setupStyle() {
        view.backgroundColor = .themeBackgroundColor()
        logoImageView.image = UIImage(named: "Logo")
        logoImageView.contentMode = .scaleAspectFit
        
        appLabel.text = "NewsSphere"
        appLabel.textColor = .primaryTextColor
        appLabel.font = .systemFont(ofSize: 30, weight: .bold)
    }
    
    private func setupConstraints() {
        logoImageView.top(281).width(150).height(150).centerHorizontally()
        
        appLabel.Top == logoImageView.Bottom 
        appLabel.CenterX == logoImageView.CenterX
    }
}
