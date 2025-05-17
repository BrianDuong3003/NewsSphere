//
//  WebViewContainer.swift
//  NewsSphere
//
//  Created by DUONG DONG QUAN on 25/4/25.
//

import UIKit
import WebKit

class WebViewContainer: UIView {
    var webView: WKWebView!
    var loadingIndicator = UIActivityIndicatorView(style: .large)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupStyle()
        setupConstraints()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeChanged),
            name: ThemeManager.themeChangedNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupStyle()
        setupConstraints()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeChanged),
            name: ThemeManager.themeChangedNotification,
            object: nil
        )
    }
    
    @objc private func themeChanged() {
        updateTheme()
    }
    
    func updateTheme() {
        backgroundColor = .themeBackgroundColor()
        webView.backgroundColor = .themeBackgroundColor()
        
        loadingIndicator.color = .primaryTextColor
    }
    
    private func setupView() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: bounds, configuration: config)
        addSubview(webView)
        addSubview(loadingIndicator)
    }
    
    private func setupStyle() {
        backgroundColor = .themeBackgroundColor()
        
        webView.navigationDelegate = self
        webView.backgroundColor = .themeBackgroundColor()
        webView.contentMode = .scaleToFill
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        loadingIndicator.color = .primaryTextColor
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = center
    }
    
    private func setupConstraints() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func loadURL(_ urlString: String) {
        loadingIndicator.startAnimating()
        guard let url = URL(string: urlString) else {
            loadingIndicator.stopAnimating()
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

// Navigation delegate
extension WebViewContainer: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
        webView.scrollView.isScrollEnabled = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
    }
}
