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
                VStack(alignment: .trailing) {
                    Text("Last updated:")
                    if let updatedTime = vm.updatedTime {
                        Text(updatedTime)
                    }
                }
                .padding([.leading, .top, .bottom])
                .padding(.trailing, 15)
            }
        }
        // Weird layout hacks
        .frame(height: 70)
        .padding(.bottom, 70)
    }
}

#Preview {
    VStack {
        HeaderView(vm: SpotifyViewModel())
        Spacer()
    }
}
