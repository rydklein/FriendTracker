//
//  LoginViewModel.swift
//  FriendTracker
//
//  Created by Ryder Klein on 9/28/23.
//

import SwiftUI
import WebKit

class LoginViewModel: NSObject, ObservableObject {
    var webView: WKWebView?
    @Published var welcomeDone: Bool = false
    public var onLogin: (@MainActor (_ tokenCookie: String) -> Void)?
    private let dataStore = WKWebsiteDataStore.nonPersistent()

    func initWebView() {
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.websiteDataStore = dataStore
        webView = WKWebView(frame: .zero, configuration: webViewConfig)
        webView!.customUserAgent = "FriendTracker"
        webView!.navigationDelegate = self
        webView!.load(URLRequest(url: URL(string: "https://accounts.spotify.com/en/login?continue=https%3A%2F%2Fopen.spotify.com%2F")!))
    }

    func releaseWebView() {
        webView = nil
    }

    func pageLoad(webView: WKWebView) {
        if webView.isLoading {
            return
        }
        if webView.url == nil {
            return
        }
        if webView.url!.absoluteString.contains("login") {
            return
        }
        dataStore.httpCookieStore.getAllCookies(cookiesHandler)
    }

    func cookiesHandler(cookieArray: [HTTPCookie]) {
        for cookie in cookieArray {
            if cookie.name == "sp_dc" {
                if let onLogin = onLogin {
                    Task {
                        await onLogin(cookie.value)
                    }
                }
                return
            }
        }
    }
}

extension LoginViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        pageLoad(webView: webView)
    }
}
