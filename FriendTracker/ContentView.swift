import SwiftUI
import WebKit
let specialUsers:[String] = ["sciencyscience"]
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
                await spotifyHelper.updateListeningStatuses()
            }
        }
    }
}
struct Banner<Content: View>: View {
    @State var showAlert:Bool = false
    @ViewBuilder var content: Content
    var body: some View {
        ZStack{
            Rectangle().fill(Color(UIColor(red: 30/255, green: 215/255, blue: 96/255, alpha: 1.0))).frame(height:100)
            HStack{
                VStack(alignment:.center, spacing:0){
                    Image(uiImage: UIImage(named: "Logo")!)
                        .resizable()
                        .frame(width:100, height:50)
                        .aspectRatio(contentMode: .fit)
                    Text("FriendTracker")
                    Text("for Spotify").font(.system(size: 9))
                }
                .padding(.leading)
                Spacer()
                VStack{
                    content
                }.frame(height:100)
                Spacer()
                VStack{
                    Image(systemName:"info.circle")
                        .padding([.top, .trailing], 8.0)
                    Spacer()
                }
                .frame(height:100)
                .onTapGesture {
                    showAlert = true
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Info"), message: Text("FriendTracker v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"))\nDesigned by Ryder Klein\nNeed to get in contact? Email me at Ryder679@live.com"), dismissButton: .default(Text("Dismiss")))
                }
            }
        }
    }
}
struct WebViewControlBar: View {
    var webView: WKWebView
    var body: some View {
        HStack(spacing:0){
            Button(action: {
                self.webView.load(URLRequest(url: URL(string:"https://accounts.spotify.com/en/login?continue=https%3A%2F%2Fopen.spotify.com%2F")!))
            }){
                Image(systemName: "arrow.backward")
                    .font(.title)
                    .foregroundColor(.blue)
                    .padding()
            }
            Button(action: {
                self.webView.reload()
            }){
                Image(systemName: "arrow.clockwise.circle")
                    .font(.title)
                    .foregroundColor(.blue)
                    .padding()
            }
            Spacer()
        }
    }
}
struct UserInfo: View {
    var friend: Friend
    var body: some View {
        let formatter = RelativeDateTimeFormatter()
        HStack{
            VStack(alignment: .leading){
                if (friend.user.imageURL == nil) {
                    Image(systemName:"person.fill").frame(width: 50, height: 50)
                } else {
                    (AsyncImage(url: URL(string: friend.user.imageURL!)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure:
                            Image(systemName: "photo")
                        @unknown default:
                            EmptyView()
                        }
                    })
                    .frame(width: 50, height: 50)
                    .cornerRadius(10)
                }
            }
            VStack(alignment:.leading){
                HStack{
                    if (specialUsers.contains(friend.user.uri.split(separator: ":", maxSplits: 3)[2].description)) {
                        Text(Image(systemName:"crown.fill")).foregroundColor(Color(.systemYellow)) + Text(" ") + Text(friend.user.name).bold()
                    } else {
                        Text(friend.user.name).bold()
                    }
                    Spacer()
                    
                    Text(formatter.localizedString(for: Date.init(timeIntervalSince1970: TimeInterval(friend.timestamp / 1000)), relativeTo: Date()))
                }
                (Text(Image(systemName:"headphones")) + Text(" ") + Text(friend.track.name))
                (Text(Image(systemName:"music.mic")) + Text(" ") +  Text(friend.track.artist.name))
                HStack(){
                    Text(Image(systemName:            ((friend.track.context.uri.split(separator: ":")[1] != "playlist") ? "opticaldisc" : "music.quarternote.3"))) + Text(" ") + Text(friend.track.context.name)
                }
            }
        }
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
    static var previews: some View {
        let demoData:SpotiStatuses = load("DemoData.json")
        AppBody(spotifyHelper: SpotifyUIHelper(friendData: demoData.friends))
    }
}
func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
