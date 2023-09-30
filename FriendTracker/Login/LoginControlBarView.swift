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
                vm.goHome()
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
        .padding(.bottom, 12)
    }
}
