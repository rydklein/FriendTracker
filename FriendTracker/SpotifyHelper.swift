import Foundation
import SwiftUI
import WebKit
// TODO: Replace NeedsLogin with SP_DC being null
class SpotifyHelper:SpotifyUIHelper {
    @Published var needsLogin: Bool = false
    var loginWV: LoginWebView = LoginWebView()
    private var accessToken:String?
    @MainActor override init() {
        super.init()
        doneStarting = false
        loginWV.callback = postLogin
        if (UserDefaults.standard.string(forKey:"LoginToken") == nil) {
            self.needsLogin = true
        } else {
            Task {
                await updateListeningStatuses()
            }
        }
    }
    override func logout() {
        loginWV.dataStore.httpCookieStore.getAllCookies(finalizeLogout)
    }
    @MainActor func finalizeLogout(cookieArray:[HTTPCookie]) {
        for cookie in cookieArray {
            if (cookie.name == "sp_dc") {
                loginWV.dataStore.httpCookieStore.delete(cookie)
            }
        }
        UserDefaults.standard.removeObject(forKey: "LoginToken")
        self.accessToken = nil
        _ = loginWV.viewObj.webView.load(URLRequest(url: URL(string:"https://accounts.spotify.com/en/login?continue=https%3A%2F%2Fopen.spotify.com%2F")!))
        needsLogin = true
    }
    @MainActor func postLogin(tokenCookie:String) {
        UserDefaults.standard.set(tokenCookie, forKey:"LoginToken")
        self.needsLogin = false
        Task {
            await updateListeningStatuses()
        }
    }
    struct AccessTokenJSON: Decodable {
        let clientId: String
        let accessToken: String
        let accessTokenExpirationTimestampMs: Int
        let isAnonymous: Bool
    }
    @MainActor func setAccessToken() async {
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
            if (accessToken == nil) {
                print("Error fetching new access code.")
                return
            }
            self.accessToken = accessToken!.accessToken
        } catch {
            // TODO: Add error handling
            print("Error fetching new access code.")
        }
    }
    @MainActor override func updateListeningStatuses() async {
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
            if let friendData = try? JSONDecoder().decode(SpotiStatuses.self, from: data) {
                self.friendData = friendData.friends
                self.lastUpdated = Date()
                self.doneStarting = true
            } else {
                logout()
            }
        } catch {
            // TODO: Add error handling
        }
    }
}
