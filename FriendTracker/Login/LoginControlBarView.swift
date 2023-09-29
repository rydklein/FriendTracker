//
//  LoginControlBarView.swift
//  FriendTracker
//
//  Created by Ryder Klein on 9/28/23.
//

import SwiftUI
import WebKit

struct LoginControlBarView: View {
    @ObservedObject var vm: LoginViewModel
    var body: some View {
        HStack(spacing: .zero) {
            Spacer()
            Button(action: {
                withAnimation {
                    vm.welcomeDone = false
                }
            }) {
                Image(systemName: "arrow.backward")
                    .font(.title)
                    .foregroundStyle(.blue)
                    .padding()
            }
            Button(action: {
                guard let webView = vm.webView else {
                    return
                }
                webView.load(URLRequest(url: URL(string: "https://accounts.spotify.com/en/login?continue=https%3A%2F%2Fopen.spotify.com%2F")!))
            }) {
                Image(systemName: "house")
                    .font(.title)
                    .foregroundStyle(.blue)
                    .padding()
            }
            Button(action: {
                guard let webView = vm.webView else {
                    return
                }
                webView.reload()
            }) {
                Image(systemName: "arrow.circlepath")
                    .font(.title)
                    .foregroundStyle(.blue)
                    .padding()
            }
            Spacer()
        }
    }
}
