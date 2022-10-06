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
                await spotifyHelper.updateListeningStatuses()
            }
        }
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
    static var previews: some View {
        let demoData:SpotiStatuses = load("DemoData.json")
        AppBody(spotifyHelper: SpotifyUIHelper(friendData: demoData.friends))
    }
}
