//
//  BannerView.swift
//  FriendTracker
//
//  Created by Ryder Klein on 9/29/23.
//

import SwiftUI

struct HeaderView: View {
    @ObservedObject var vm: SpotifyViewModel
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color(UIColor.secondarySystemBackground))
                .ignoresSafeArea(edges: .top)
            HStack(alignment: .center, spacing: .zero) {
                LogoView()
                Spacer()
                HStack(alignment: .center, spacing: .zero) {
                    Spacer()
                    VStack(alignment: .center) {
                        Text("Last updated:")
                        Group {
                            if let updatedTime = vm.updatedTime {
                                Text(updatedTime)
                            } else {
                                ProgressView()
                            }
                        }
                        .transition(.opacity)
                    }
                    .padding([.leading, .top, .bottom])
                    .padding(.trailing, 15)
                    Spacer()
                }
            }
        }
        // Weird layout hacks
        .frame(height: 75)
        .padding(.bottom, 70)
    }
}

#Preview {
    VStack {
        HeaderView(vm: SpotifyViewModel(demo: true))
        Spacer()
    }
}
