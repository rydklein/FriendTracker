//
//  WelcomeView.swift
//  FriendTracker
//
//  Created by Ryder Klein on 9/29/23.
//

import Foundation
import SwiftUI

struct WelcomeView: View {
    @ObservedObject var vm: LoginViewModel
    var body: some View {
        LogoView()
        Text("Sign into Spotify to get started.")
        Button(action: {
            withAnimation {
                vm.welcomeDone = true
            }
        }, label: {
            Text("Continue")
                .font(.system(size: 20, weight: .semibold))
                .frame(minWidth: 0, maxWidth: 250)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.top)
        })
    }
}

#Preview {
    WelcomeView(vm: LoginViewModel())
        .ignoresSafeArea(.container)
}
