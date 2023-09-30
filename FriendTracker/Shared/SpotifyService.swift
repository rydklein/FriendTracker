//
//  SpotifyService.swift
//  FriendTracker
//
//  Created by Ryder Klein on 9/28/23.
//

import Foundation

class SpotifyService {
    static func getAccessToken(loginToken: String) async throws -> String {
        let url = URL(string: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let cookieProperties: [HTTPCookiePropertyKey: Any] = [
            .domain: ".spotify.com",
            .path: "/",
            .name: "sp_dc",
            .value: loginToken,
            .secure: true,
            .expires: NSDate(timeIntervalSinceNow: 3600)
        ]
        let cookie = HTTPCookie(properties: cookieProperties)!
        let urlSessCfg = URLSessionConfiguration.ephemeral
        HTTPCookieStorage.shared.setCookie(cookie)
        urlSessCfg.httpCookieStorage = HTTPCookieStorage.shared
        let urlSess = URLSession(configuration: urlSessCfg)
        let (data, response) = try await urlSess.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpotifyError.networkError
        }
        if httpResponse.statusCode == 401 {
            throw SpotifyError.invalidSPDC
        }
        do {
            let accessToken = try JSONDecoder().decode(AccessTokenBody.self, from: data)
            return accessToken.accessToken
        } catch {
            throw SpotifyError.unknownError
        }
    }

    static func getListeningStatuses(accessToken: String) async throws -> [Friend] {
        let urlSessCfg = URLSessionConfiguration.ephemeral
        urlSessCfg.httpAdditionalHeaders = ["Authorization": "Bearer \(accessToken)"]
        let urlSess = URLSession(configuration: urlSessCfg)
        let url = URL(string: "https://spclient.wg.spotify.com/presence-view/v1/buddylist")!
        let (data, response) = try await urlSess.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SpotifyError.networkError
        }
        if httpResponse.statusCode == 401 {
            throw SpotifyError.invalidToken
        }
        do {
            let friendData = try JSONDecoder().decode(ListeningStatusBody.self, from: data)
            return friendData.friends
        } catch {
            throw SpotifyError.unknownError
        }
    }
}

private struct ListeningStatusBody: Codable {
    var friends: [Friend]
}

private struct AccessTokenBody: Decodable {
    let clientId: String
    let accessToken: String
    let accessTokenExpirationTimestampMs: Int
    let isAnonymous: Bool
}

struct Friend: Codable {
    var timestamp: Int
    let user: User
    let track: Track
}

struct Track: Codable {
    let uri, name: String
    let imageURL: String?
    let album, artist: Album
    let context: Context

    enum CodingKeys: String, CodingKey {
        case uri, name
        case imageURL = "imageUrl"
        case album, artist, context
    }
}

struct Album: Codable {
    let uri, name: String
}

struct Context: Codable {
    let uri, name: String
    let index: Int
}

struct User: Codable {
    let uri, name: String
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case uri, name
        case imageURL = "imageUrl"
    }
}

public enum SpotifyError: Error {
    case invalidSPDC
    case invalidToken
    case networkError
    case unknownError
}
