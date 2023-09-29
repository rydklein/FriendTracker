//
//  FriendView.swift
//  FriendTracker
//
//  Created by Ryder Klein on 9/29/23.
//

import SwiftUI
struct FriendView: View {
    var friend: Friend
    
    private static let specialUsers: [String] = ["sciencyscience", "mcexrs8v2q4wj5szj4hlyuj5j"]
    private static let formatter = RelativeDateTimeFormatter()
    
    @State private var currentDate = Date()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var isSpecialUser: Bool {
        let uriComponents = friend.user.uri.split(separator: ":", maxSplits: 3)
        return uriComponents.count > 2 && FriendView.specialUsers.contains(uriComponents[2].description)
    }
    
    var body: some View {
        HStack {
            ZStack {
                if let imageURL = friend.user.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure:
                            Image(systemName: "person.fill")
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .cornerRadius(10)
                } else {
                    Image(systemName: "person.fill")
                }
                if isSpecialUser {
                    HStack {
                        VStack {
                            Spacer()
                            Text(Image(systemName: "star.fill")).foregroundStyle(.yellow)
                                .padding([.bottom, .leading], -8.0)
                                .font(.system(size: 20))
                        }
                        Spacer()
                    }
                }
            }
            .frame(width: 50, height: 50)
            .onTapGesture {
                openURL(friend.user.uri)
            }
            VStack(alignment: .leading) {
                HStack {
                    Text(friend.user.name).bold()
                        .onTapGesture {
                            openURL(friend.user.uri)
                        }
                    Spacer()
                    
                    Text(Self.formatter.localizedString(for: Date(timeIntervalSince1970: TimeInterval(friend.timestamp / 1000)), relativeTo: currentDate))
                        .onReceive(timer) { _ in
                            self.currentDate = Date()
                        }
                }
                (Text(Image(systemName: "headphones")) + Text(" ") + Text(friend.track.name))
                    .onTapGesture {
                        openURL(friend.track.album.uri)
                    }
                (Text(Image(systemName: "music.mic")) + Text(" ") + Text(friend.track.artist.name))
                    .onTapGesture {
                        openURL(friend.track.artist.uri)
                    }
                HStack {
                    (Text(Image(systemName: (friend.track.context.uri.split(separator: ":")[1] != "playlist") ? "opticaldisc" : "music.quarternote.3")) + Text(" ") + Text(friend.track.context.name))
                        .onTapGesture {
                            openURL(friend.track.context.uri)
                        }
                }
            }
        }
    }

    private func openURL(_ url: String) {
        let friendURL = URL(string: url)!
        if UIApplication.shared.canOpenURL(friendURL) {
            UIApplication.shared.open(friendURL)
        }
    }
}
