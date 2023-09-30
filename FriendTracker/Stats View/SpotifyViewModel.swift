//
//  SpotifyViewModel.swift
//  FriendTracker
//
//  Created by Ryder Klein on 9/29/23.
//

import Foundation
import StoreKit
import SwiftUI

class SpotifyViewModel: ObservableObject {
    // Token to log into Spotify
    @Published var loginToken: String? = nil
    @Published var updatedTime: String? = nil
    @Published var listeningStatuses: [Friend] = []
    @Published var showSignOutConfirm = false
    @Published var showRefreshPrompt = UserDefaults.standard.integer(forKey: "RefreshCount") > 0
    // Token to fetch listening statuses
    var accessToken: String? = nil
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ss a"
        return formatter
    }

    init(demo: Bool = false) {
        // Migrate from insecure UserDefaults
        if let oldLoginToken = UserDefaults.standard.string(forKey: "LoginToken") {
            UserDefaults.standard.removeObject(forKey: "LoginToken")
            setLoginToken(newLoginToken: oldLoginToken)
        } else {
            loginToken = KeychainService.getLoginToken()
        }
        // Simulator preview, screenshots
        if demo {
            loginToken = ""
            var demoData = loadDemoData()
            var i = 0
            while i < demoData.count {
                demoData[i].timestamp = (Int(Date().timeIntervalSince1970 * 1000) - Int(truncating: 1000 + (pow(2, i + 5) * 1000) as NSNumber))
                i += 1
            }
            listeningStatuses = demoData
            updatedTime = SpotifyViewModel.dateFormatter.string(from: Date())
        } else {
            Task {
                await updateListeningStatuses()
            }
        }
    }

    @MainActor func friendListRefreshed() async {
        showRefreshPrompt = false
        // Prompt for review after 50 refreshes
        let refreshCount = UserDefaults.standard.integer(forKey: "RefreshCount")
        UserDefaults.standard.set(refreshCount + 1, forKey: "RefreshCount")
        if refreshCount >= 51 {
            // Keep refresh count >= 1 after the firs
            UserDefaults.standard.set(1, forKey: "RefreshCount")
            Task {
                if let scene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive })
                    as? UIWindowScene
                {
                    try await Task.sleep(nanoseconds: 6000000000)
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
        await updateListeningStatuses()
    }

    func setLoginToken(newLoginToken: String?) {
        KeychainService.setLoginToken(loginToken: newLoginToken)
        loginToken = newLoginToken
        if newLoginToken == nil {
            accessToken = nil
        }
    }

    @MainActor func updateListeningStatuses(retry: Bool = false) async {
        guard let loginToken = loginToken else {
            return
        }
        if accessToken == nil {
            do {
                accessToken = try await SpotifyService.getAccessToken(loginToken: loginToken)
            } catch SpotifyError.invalidSPDC {
                setLoginToken(newLoginToken: nil)
                return
            } catch {
                print("Error fetching access token: \(error).")
                return
            }
        }
        guard let accessToken = accessToken else {
            return
        }
        do {
            listeningStatuses = try await SpotifyService.getListeningStatuses(accessToken: accessToken).sorted { lhs, rhs in
                lhs.timestamp >= rhs.timestamp
            }
            updatedTime = SpotifyViewModel.dateFormatter.string(from: Date())
        } catch SpotifyError.invalidToken {
            // Retry once if access token is invalid
            self.accessToken = nil
            if !retry {
                return await updateListeningStatuses(retry: true)
            }
        } catch {
            print("Error fetching listening statuses: \(error).")
        }
    }
}
