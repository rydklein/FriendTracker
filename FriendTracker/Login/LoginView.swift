//
//  LoginView.swift
//  FriendTracker
//
//  Created by Ryder Klein on 9/29/23.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @ObservedObject var vm: LoginViewModel
    init(vm: LoginViewModel) {
        self.vm = vm
        // Preload Spotify login page for smoother user experience
        if vm.webView == nil {
            vm.initWebView()
        }
    }

    var body: some View {
        Group {
            if !vm.welcomeDone {
                WelcomeView(vm: vm)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
            } else {
                VStack {
                    WebViewRepresentable(vm: vm)
                        .onAppear {
                            vm.logout()
                        }
                    LoginControlBarView(vm: vm)
                }
                .transition(.move(edge: .trailing))
                .zIndex(2)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LoginView(vm: LoginViewModel())
}
