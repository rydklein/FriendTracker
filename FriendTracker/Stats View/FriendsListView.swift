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
        VStack(spacing: .zero) {
            HeaderView(vm: vm)
            VStack(spacing: .zero) {
                if vm.showRefreshPrompt {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                        Text("Pull down to refresh")
                    }
                    .padding([.top, .bottom])
                }
                if vm.updatedTime == nil {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                List {
                    if vm.updatedTime != nil {
                        // TODO: Add transition to list
                        ForEach(vm.listeningStatuses, id: \.user.uri) { friend in
                            FriendView(friend: friend)
                        }
                    }
                    VStack {
                        HStack(alignment: .center) {
                            Spacer()
                            HStack {
                                Image(systemName: "x.square.fill")
                                Text("Sign Out")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxHeight: 10)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(40)
                            .onTapGesture {
                                vm.showSignOutConfirm = true
                            }
                            .confirmationDialog("Are you sure?", isPresented: $vm.showSignOutConfirm) {
                                Button("Sign Out", role: .destructive) {
                                    vm.setLoginToken(newLoginToken: nil)
                                }
                            }
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            VStack(alignment: .center) {
                                Text("FriendTracker v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"))")
                                Text("Designed by Ryder Klein")
                                Text("Need to get in contact? Email me at Ryder679@live.com")
                            }
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                            Spacer()
                        }
                    }
                }
            }
            // See HeaderView for justification
            .padding(.top, -20)
            .refreshable {
                await vm.friendListRefreshed()
            }
        }
        .ignoresSafeArea(edges: [.bottom])
        .transition(.move(edge: .trailing))
        .zIndex(2)
    }
}

#Preview {
    FriendsListView(vm: SpotifyViewModel(demo: true))
}
