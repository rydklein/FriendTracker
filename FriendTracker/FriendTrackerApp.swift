import Foundation
import SwiftUI
import WebKit
@main
struct FriendTrackerApp: App {
    @StateObject var spotifyHelper: SpotifyHelper = SpotifyHelper()
    var body: some Scene {
        WindowGroup {
            if (spotifyHelper.needsLogin) {
                VStack{
                    Banner{
                        Text("Please sign into your Spotify Account to continue.")
                    }
                    spotifyHelper.loginWV.viewObj
                    WebViewControlBar(webView:spotifyHelper.loginWV.viewObj.webView)
                }
            } else {
                AppBody(spotifyHelper: spotifyHelper)
            }
        }
    }
    init() {
    }
}
