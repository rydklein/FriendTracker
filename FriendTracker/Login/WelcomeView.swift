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
        VStack {
            VStack {
                Image(uiImage: UIImage(named: "Logo")!)
                    .resizable()
                    .frame(width: 100, height: 50)
                    .aspectRatio(contentMode: .fit)
                Text("FriendTracker")
                Text("for Spotify").font(.system(size: 9))
            }
            .padding(.all, 10)
        }
        Text("Sign into Spotify to get started.")
        Button(action: {
            withAnimation {
                vm.welcomeDone = true
            }
        }, label: {
            Text("Continue")
                .font(.system(size: 20, weight: .semibold))
                .frame(minWidth: 0, maxWidth: .infinity)
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
