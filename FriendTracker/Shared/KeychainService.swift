//
//  KeychainService.swift
//  FriendTracker
//
//  Created by Ryder Klein on 9/29/23.
//

import Foundation
import KeychainAccess

class KeychainService {
    private static let keychain = Keychain(service: Bundle.main.bundleIdentifier!)

    public static func setLoginToken(loginToken: String?) {
        if let loginToken = loginToken {
            _ = try? keychain.set(loginToken, key: "loginToken")
        } else {
            _ = try? keychain.remove("loginToken")
        }
    }

    public static func getLoginToken() -> String? {
        return try? keychain.get("loginToken")
    }
}
