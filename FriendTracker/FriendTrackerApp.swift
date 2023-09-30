//
//  FriendTrackerApp.swift
//  FriendTracker
//
//  Created by Ryder Klein on 9/28/23.
//

import Foundation
import SwiftUI
import WebKit
@main
struct FriendTrackerApp: App {
    @StateObject var loginViewModel = LoginViewModel()
    @StateObject var spotifyViewModel = SpotifyViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(loginViewModel: loginViewModel, spotifyViewModel: spotifyViewModel)
                .onAppear {
                    loginViewModel.onLogin = { [weak spotifyViewModel] newLoginToken in
                        spotifyViewModel?.setLoginToken(newLoginToken: newLoginToken)
                    }
                }
        }
    }
}
