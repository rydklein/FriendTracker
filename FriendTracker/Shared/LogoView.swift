//
//  LogoView.swift
//  FriendTracker
//
//  Created by Ryder Klein on 9/29/23.
//

import SwiftUI

struct LogoView: View {
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
    }
}
