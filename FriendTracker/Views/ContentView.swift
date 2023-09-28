import StoreKit
import SwiftUI
import WebKit
struct AppBody: View {
    let dateFormatter: DateFormatter
    @State private var isPresentingConfirm: Bool = false
    @ObservedObject var spotifyHelper:SpotifyUIHelper
    @State var swipedDown:Bool = false
    init(spotifyHelper:SpotifyUIHelper) {
        self.spotifyHelper = spotifyHelper
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm:ss a"
    }
    var body: some View {
        VStack(spacing:0){
            Banner{
                VStack{
                    Text("Last Updated").font(.system(size: 16))
                    Text(spotifyHelper.lastUpdated, formatter: dateFormatter).font(.system(size: 18))
                }
                .padding()
            }
            if ((UserDefaults.standard.bool(forKey:"SwipedDown") != true) && !swipedDown) {
                (Text(Image(systemName:"arrow.down")) + Text(" Pull down to refresh ") + Text(Image(systemName:"arrow.down"))).padding(.top)
            }
            let timeSortedFD = spotifyHelper.friendData.sorted(by: { $0.timestamp > $1.timestamp })
            List{
                ForEach(timeSortedFD, id: \.user.uri) { friend in
                    UserInfo(friend:friend)
                }
                if (spotifyHelper.doneStarting) {
                    HStack(alignment:.center){
                        Spacer()
                        HStack {
                            Image(systemName: "x.square.fill")
                            Text("Sign Out")
                                .fontWeight(.semibold)
                        }
                        .frame(maxHeight:10)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(40)
                        .onTapGesture {
                            isPresentingConfirm = true
                        }
                        .confirmationDialog("Are you sure?",
                                            isPresented: $isPresentingConfirm) {
                            Button("Sign Out", role: .destructive) {
                                spotifyHelper.logout()
                            }
                        }
                        Spacer()
                    }
                }
            }
            .refreshable {
                UserDefaults.standard.set(true, forKey:"SwipedDown")
                swipedDown = true
                let refreshCount = UserDefaults.standard.integer(forKey: "RefreshCount")
                UserDefaults.standard.set(refreshCount + 1, forKey:"RefreshCount")
                if (refreshCount >= 49) {
                    UserDefaults.standard.set(0, forKey:"RefreshCount")
                    Task {
                        if let scene = UIApplication.shared.connectedScenes
                            .first(where: { $0.activationState == .foregroundActive })
                            as? UIWindowScene {
                            try await Task.sleep(nanoseconds: 6_000_000_000)
                            SKStoreReviewController.requestReview(in: scene)
                        }
                    }
                }
                await spotifyHelper.updateListeningStatuses()
            }
        }
        .overlay(alignment: .top, content: {
            Color(UIColor(red: 30/255, green: 215/255, blue: 96/255, alpha: 1.0))
                .edgesIgnoringSafeArea(.top)
                .frame(height: 0)
        })
    }
}
func openURL(_ url:String) {
    let friendURL = URL(string:url)!
    if (UIApplication.shared.canOpenURL(friendURL)) {
        UIApplication.shared.open(friendURL)
    }
}
@MainActor  class SpotifyUIHelper:ObservableObject {
    @Published var friendData: [Friend]
    @Published var lastUpdated: Date = Date()
    @Published var doneStarting: Bool = true
    init() {
        friendData = []
    }
    init(friendData:[Friend]){
        self.friendData = friendData
    }
    func updateListeningStatuses() async {
    }
    func logout() {
    }
}
struct ContentView_Previews: PreviewProvider {
    static let appBody = AppBody(spotifyHelper: SpotifyUIHelper(friendData: getDemoData()))
    static var previews: some View {
        appBody
        #if DEBUG
        // Generates screenshots from preview
            .screenshot()
        #endif
    }
    static func getDemoData() -> [Friend] {
        var demoData:SpotiStatuses = load("DemoData.json")
        var i = 0
        while (i < demoData.friends.count) {
            demoData.friends[i].timestamp = (Int(Date().timeIntervalSince1970 * 1000) - Int(truncating: 1000 + (pow(2, i + 5) * 1000) as NSNumber))
            i += 1
        }
        return demoData.friends
    }
}
