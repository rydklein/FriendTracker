import Foundation
import SwiftUI

// TODO: Replace NeedsLogin with SP_DC being null
@MainActor class SpotifyHelper:SpotifyUIHelper {
    @Published var needsLogin: Bool = false
    private var loginWV: LoginWebView = LoginWebView()
    var loginWVView: LoginWebView.WebViewable
    private var accessToken:String?
    override init() {
        loginWVView = loginWV.viewObj
        super.init()
        loginWV.callback = postLogin
        if (UserDefaults.standard.string(forKey:"LoginToken") == nil) {
            self.needsLogin = true
        } else {
            refreshStatuses()
        }
    }
    override func refreshStatuses() {
        Task {
            await updateListeningStatuses()
        }
    }
    func postLogin(tokenCookie:String) {
        UserDefaults.standard.set(tokenCookie, forKey:"LoginToken")
        self.needsLogin = false
        refreshStatuses()
    }
    struct AccessTokenJSON: Decodable {
        let clientId: String
        let accessToken: String
        let accessTokenExpirationTimestampMs: Int
        let isAnonymous: Bool
    }
    func setAccessToken() async {
        let url = URL(string: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let cookie = HTTPCookie(properties: [
            .domain: ".spotify.com",
            .path: "/",
            .name: "sp_dc",
            .value: UserDefaults.standard.string(forKey:"LoginToken")!,
            .secure: true,
            .expires: NSDate(timeIntervalSinceNow: 3600)
        ])
        let urlSessCfg:URLSessionConfiguration = URLSessionConfiguration.ephemeral
        HTTPCookieStorage.shared.setCookie(cookie!)
        urlSessCfg.httpCookieStorage = HTTPCookieStorage.shared
        let urlSess:URLSession = URLSession.init(configuration: urlSessCfg)
        do {
            let (data, response) = try await urlSess.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 401) {
                    self.needsLogin = true
                    return
                }
                }
            let accessToken = try? JSONDecoder().decode(AccessTokenJSON.self, from: data)
            self.accessToken = accessToken!.accessToken
        } catch {
            // error handling later
        }
    }
    func updateListeningStatuses() async {
        if (self.accessToken == nil) {
            await setAccessToken()
        }
        if (self.accessToken == nil) {
            return
        }
        let urlSessCfg:URLSessionConfiguration = URLSessionConfiguration.ephemeral
        urlSessCfg.httpAdditionalHeaders = Dictionary()
        urlSessCfg.httpAdditionalHeaders!["Authorization"] = "Bearer \(self.accessToken!)"
        let urlSess:URLSession = URLSession.init(configuration: urlSessCfg)
        do {
            let url = URL(string:"https://spclient.wg.spotify.com/presence-view/v1/buddylist")!
            let (data, response) = try await urlSess.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode == 401) {
                    await setAccessToken()
                    await updateListeningStatuses()
                    return;
                }
            }
            let friendData = try! JSONDecoder().decode(SpotiStatuses.self, from: data)
            self.friendData = friendData.friends
            self.lastUpdated = Date()
        } catch {
            // Test
        }
        }
    }

struct SpotiStatuses: Codable {
    let friends: [Friend]
}
struct Friend: Codable {
    let timestamp: Int
    let user: User
    let track: Track
}
struct Track: Codable {
    let uri, name: String
    let imageURL: String?
    let album, artist: Album
    let context: SContext

    enum CodingKeys: String, CodingKey {
        case uri, name
        case imageURL = "imageUrl"
        case album, artist, context
    }
}
struct Album: Codable {
    let uri, name: String
}
struct SContext: Codable {
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
