//
//  WebViewRepresentable.swift
//  FriendTracker
//
//  Created by Ryder Klein on 9/28/23.
//

import SwiftUI
import UIKit
import WebKit

struct WebViewRepresentable: UIViewRepresentable {
    var vm: LoginViewModel

    func makeUIView(context: UIViewRepresentableContext<WebViewRepresentable>) -> WKWebView {
        if vm.webView == nil {
            vm.initWebView()
        }
        return vm.webView!
    }

    func dismantleUIView(_ uiView: WKWebView, context: Context) {
        vm.releaseWebView()
    }

    func updateUIView(_ webView: WKWebView, context: UIViewRepresentableContext<WebViewRepresentable>) {}
}
