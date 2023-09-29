//
//  ContentView.swift
//  FriendTracker
//
//  Created by Ryder Klein on 9/28/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    @ObservedObject var spotifyViewModel: SpotifyViewModel
    var body: some View {
        if spotifyViewModel.needsLogin {
            LoginView(vm: loginViewModel)
        } else {
            FriendsListView(vm: spotifyViewModel)
        }
    }
}

#Preview {
    ContentView(loginViewModel: LoginViewModel(), spotifyViewModel: SpotifyViewModel())
}
