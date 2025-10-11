import UIKit

class ThemeAwareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        ThemeManager.shared.addThemeChangeObserver(self, selector: #selector(themeChanged))
    }
    
    deinit {
        ThemeManager.shared.removeThemeChangeObserver(self)
    }
    
    @objc private func themeChanged() {
        applyTheme()
    }
    
    func applyTheme() {
        applyThemeChanges()
    }
}
