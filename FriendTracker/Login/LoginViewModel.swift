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
    public var onLogin: (@MainActor (_ loginToken: String) -> Void)?
    private let dataStore = WKWebsiteDataStore.nonPersistent()

    func initWebView() {
        // nonPersistant is stil persistant enough. Clear login cookie so people can actually log out.
        dataStore.httpCookieStore.getAllCookies(logoutCookiesHandler)
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
        dataStore.httpCookieStore.getAllCookies(loginCookiesHandler)
    }

    func loginCookiesHandler(cookieArray: [HTTPCookie]) {
        for cookie in cookieArray {
            if cookie.name == "sp_dc" {
                Task {
                    await onLogin?(cookie.value)
                }
            }
        }
    }

    func logoutCookiesHandler(cookieArray: [HTTPCookie]) {
        for cookie in cookieArray {
            if cookie.name == "sp_dc" {
                dataStore.httpCookieStore.delete(cookie)
            }
        }
    }
}

extension LoginViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        pageLoad(webView: webView)
    }
}
