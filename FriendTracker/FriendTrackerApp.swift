import Foundation
import SwiftUI
import WebKit
@main
struct FriendTrackerApp: App {
    @StateObject var spotifyHelper: SpotifyHelper = SpotifyHelper()
    var accessToken:String?
    var body: some Scene {
        WindowGroup {
                if (spotifyHelper.needsLogin) {
                    VStack{
                        Banner{
                            Text("Please sign into your Spotify Account to continue.")
                        }
                        spotifyHelper.loginWVView
                    }
                } else {
                    AppBody(spotifyHelper: spotifyHelper)
                }
        }
    }
    init() {
    }
    }
