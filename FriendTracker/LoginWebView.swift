import Foundation
import SwiftUI
import WebKit
class LoginWebView: ObservableObject {
    let viewObj:WebViewable
    var callback:@MainActor (_ tokenCookie:String) -> Void = { _ in}
    var navDelegate: WebViewNavigationDelegate = WebViewNavigationDelegate()
    
    init() {
        viewObj = WebViewable(navDelegate: navDelegate)
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
            // TODO: Make sure people can't click away.
        }
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies(cookiesHandler)
    }
    @MainActor func cookiesHandler(cookieArray:[HTTPCookie]) {
        for cookie in cookieArray {
            if (cookie.name == "sp_dc") {
                callback(cookie.value)
                break
            }
        }
    }
    struct WebViewable: UIViewRepresentable {
        var navDelegate: WebViewNavigationDelegate
        init(navDelegate:WebViewNavigationDelegate) {
            self.navDelegate = navDelegate
        }
        func makeUIView(context: Context) -> WKWebView {
            return WKWebView()
        }
        func updateUIView(_ webView: WKWebView, context: Context) {
            webView.navigationDelegate = navDelegate
            webView.load(URLRequest(url: URL(string:"https://accounts.spotify.com/en/login?continue=https%3A%2F%2Fopen.spotify.com%2F")!))
        }
}
    class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
        var navCallback:(_ webView: WKWebView) -> Void = { _ in}
        override init() {
            super.init()
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            navCallback(webView)
        }
    }
}
