//
//  ThemeManager.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 18/5/25.
//
import UIKit

enum ThemeMode: String {
    case dark
    case light
    
    var isLight: Bool {
        return self == .light
    }
}

class ThemeManager {
    // MARK: - Singleton
    static let shared = ThemeManager()
    
    // MARK: - Properties
    private let themeKey = "appThemeMode"
    static let themeChangedNotification = NSNotification.Name("com.newssphere.ThemeChangedNotification")
    
    // avoid recursive loops
    private var _currentTheme: ThemeMode = .dark
    
    // flag in order to avoid recursive loops
    private var isUpdating = false
    
    private init() {
        // Read theme value from UserDefaults when init
        if let storedTheme = UserDefaults.standard.string(forKey: themeKey),
           let theme = ThemeMode(rawValue: storedTheme) {
            _currentTheme = theme
        } else {
            _currentTheme = .dark
        }
    }
    
    // MARK: - Computed Properties
    var currentTheme: ThemeMode {
        get {
            return _currentTheme
        }
        set {
            guard !isUpdating else { return }
            isUpdating = true
            
            _currentTheme = newValue
            UserDefaults.standard.setValue(newValue.rawValue, forKey: themeKey)
            
            applyThemeToWindows()
            
            // send noti
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                NotificationCenter.default.post(name: ThemeManager.themeChangedNotification, object: nil)
                self.isUpdating = false
            }
        }
    }
    
    // MARK: - Public Methods
    func toggleTheme() {
        currentTheme = currentTheme == .dark ? .light : .dark
    }
    
    func applyTheme() {
        guard !isUpdating else { return }
        isUpdating = true
        
        applyThemeToWindows()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            NotificationCenter.default.post(name: ThemeManager.themeChangedNotification, object: nil)
            self.isUpdating = false
        }
    }
    
    private func applyThemeToWindows() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.compactMap { $0 as? UIWindowScene }
        
        for windowScene in windowScenes {
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = _currentTheme == .dark ? .dark : .light
            }
        }
    }
    
    // MARK: - Observer Methods
    func addThemeChangeObserver(_ observer: Any, selector: Selector) {
        removeThemeChangeObserver(observer)
        
        NotificationCenter.default.addObserver(
            observer,
            selector: selector,
            name: ThemeManager.themeChangedNotification,
            object: nil
        )
    }
    
    func removeThemeChangeObserver(_ observer: Any) {
        NotificationCenter.default.removeObserver(
            observer,
            name: ThemeManager.themeChangedNotification,
            object: nil
        )
    }
}
