//
//  FriendsListView.swift
//  FriendTracker
//
//  Created by Ryder Klein on 9/29/23.
//

import SwiftUI

struct FriendsListView: View {
    @ObservedObject var vm: SpotifyViewModel
    var body: some View {
        EmptyView()
    }
}

// HStack(alignment: .center) {
//    Spacer()
//    HStack {
//        Image(systemName: "x.square.fill")
//        Text("Sign Out")
//            .fontWeight(.semibold)
//    }
//    .frame(maxHeight: 10)
//    .padding()
//    .foregroundColor(.white)
//    .background(Color.red)
//    .cornerRadius(40)
//    .onTapGesture {
//        isPresentingConfirm = true
//    }
//    .confirmationDialog("Are you sure?",
//                        isPresented: $isPresentingConfirm)
//    {
//        Button("Sign Out", role: .destructive) {
//            spotifyHelper.logout()
//        }
//    }
//    Spacer()
// }

// func openURL(_ url: String) {
//    let friendURL = URL(string: url)!
//    if UIApplication.shared.canOpenURL(friendURL) {
//        UIApplication.shared.open(friendURL)
//    }
// }

// static func getDemoData() -> [Friend] {
//    var demoData: SpotiStatuses = load("DemoData.json")
//    var i = 0
//    while i < demoData.friends.count {
//        demoData.friends[i].timestamp = (Int(Date().timeIntervalSince1970 * 1000) - Int(truncating: 1000 + (pow(2, i + 5) * 1000) as NSNumber))
//        i += 1
//    }
//    return demoData.friends
// }
// }

// struct ContentView_Previews: PreviewProvider {
//    static let appBody = AppBody(spotifyHelper: SpotifyUIHelper(friendData: getDemoData()))
//    static var previews: some View {
//        appBody
//        #if DEBUG
//            // Generates screenshots from preview
//            .screenshot()
//        #endif
//    }

//    .refreshable {
//        UserDefaults.standard.set(true, forKey: "SwipedDown")
//        swipedDown = true
//        let refreshCount = UserDefaults.standard.integer(forKey: "RefreshCount")
//        UserDefaults.standard.set(refreshCount + 1, forKey: "RefreshCount")
//        if refreshCount >= 49 {
//            UserDefaults.standard.set(0, forKey: "RefreshCount")
//            Task {
//                if let scene = UIApplication.shared.connectedScenes
//                    .first(where: { $0.activationState == .foregroundActive })
//                    as? UIWindowScene
//                {
//                    try await Task.sleep(nanoseconds: 6000000000)
//                    SKStoreReviewController.requestReview(in: scene)
//                }
//            }
//        }
//        await spotifyHelper.updateListeningStatuses()
//    }
// }
