import SwiftUI

struct AppBody: View {
    @ObservedObject var spotifyHelper:SpotifyUIHelper
    @State var swipedDown:Bool = false
    var body: some View {
        VStack(spacing:0){
            Banner{
                VStack{
                    Text("Programmed haphazardly by").font(.system(size: 9))
                    Text("@uniqueaccountname")
                }
            }
            if ((UserDefaults.standard.bool(forKey:"SwipedDown") != true) && !swipedDown) {
                (Text(Image(systemName:"arrow.down")) + Text(" Pull down to refresh ") + Text(Image(systemName:"arrow.down"))).padding(.top)
            }
            let timeSortedFD = spotifyHelper.friendData.sorted(by: { $0.timestamp > $1.timestamp })
            List(timeSortedFD, id: \.user.uri) { friend in
                UserInfo(friend:friend)
            }
            .refreshable {
                UserDefaults.standard.set(true, forKey:"SwipedDown")
                swipedDown = true
                spotifyHelper.refreshStatuses()
            }
        }
    }
}
struct Banner<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        ZStack{
            Rectangle().fill(Color(UIColor(red: 30/255, green: 215/255, blue: 96/255, alpha: 1.0))).frame(height:100)
            HStack{
                VStack(alignment:.center){
                    Image(uiImage: UIImage(named: "Logo")!)
                        .resizable()
                        .frame(width:100, height:50)
                        .aspectRatio(contentMode: .fit)
                    Text("SpotiStalker")
                }
                .padding(.leading)
                Spacer()
                VStack{
                    content
                }.frame(height:100)
                Spacer()
            }
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
                    Text(friend.user.name).bold()
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
    func refreshStatuses() {
    }
    init() {
        friendData = []
    }
    init(friendData:[Friend]){
        self.friendData = friendData
    }
    
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let demoData:SpotiStatuses = load("demodata.json")
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
