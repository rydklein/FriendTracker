import Foundation
import SwiftUI
import WebKit
class LoginWebView: ObservableObject {
    let viewObj:WebViewable
    let dataStore = WKWebsiteDataStore.nonPersistent()
    var callback:@MainActor (_ tokenCookie:String) -> Void = { _ in}
    var navDelegate: WebViewNavigationDelegate = WebViewNavigationDelegate()
    init() {
        viewObj = WebViewable(navDelegate: navDelegate, dataStore:dataStore)
        navDelegate.navCallback = onWKLoad
    }
    func onWKLoad(_ webView:WKWebView) -> Void {
        if (webView.isLoading) {
            return
        }
        if (webView.url == nil) {
            return;
        }
        if (webView.url!.absoluteString.contains("login")) {
            return;
        }
        dataStore.httpCookieStore.getAllCookies(cookiesHandler)
    }
    @MainActor func cookiesHandler(cookieArray:[HTTPCookie]) {
        for cookie in cookieArray {
            if (cookie.name == "sp_dc") {
                callback(cookie.value)
                return
            }
        }
    }
    struct WebViewable: UIViewRepresentable {
        var webView: WKWebView
        init(navDelegate:WebViewNavigationDelegate, dataStore:WKWebsiteDataStore){
            let webViewConfig = WKWebViewConfiguration()
            webViewConfig.websiteDataStore = dataStore
            self.webView = WKWebView(frame:.zero ,configuration:webViewConfig)
            webView.customUserAgent = "FriendTracker"
            webView.navigationDelegate = navDelegate
        }
        func makeUIView(context: Context) -> WKWebView {
            return webView
        }
        func updateUIView(_ webView: WKWebView, context: Context) {
            webView.load(URLRequest(url: URL(string:"https://accounts.spotify.com/en/login?continue=https%3A%2F%2Fopen.spotify.com%2F")!))
        }
    }
    class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
        var navCallback:(_ webView: WKWebView) -> Void = { _ in }
        override init() {
            super.init()
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            navCallback(webView)
        }
    }
}
