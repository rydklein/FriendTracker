import SwiftUI
let specialUsers:[String] = ["sciencyscience", "mcexrs8v2q4wj5szj4hlyuj5j"]
struct UserInfo: View {
    var friend: Friend
    var body: some View {
        let formatter = RelativeDateTimeFormatter()
        HStack{
            ZStack{
                if (friend.user.imageURL == nil) {
                    Image(systemName:"person.fill")
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
                    .cornerRadius(10)
                }
                if (specialUsers.contains(friend.user.uri.split(separator: ":", maxSplits: 3)[2].description)) {
                    HStack{
                        VStack{
                            Spacer()
                            Text(Image(systemName:"star.fill")).foregroundColor(Color(.systemYellow))
                                .padding([.bottom, .leading], -8.0)
                                .font(.system(size: 20))
                        }
                        Spacer()
                    }
                }
            }
            .frame(width: 50, height: 50)
            .onTapGesture {
                openURL(friend.user.uri)
            }
            VStack(alignment:.leading){
                HStack{
                    Text(friend.user.name).bold()
                        .onTapGesture {
                            openURL(friend.user.uri)
                        }
                    Spacer()
                    
                    Text(formatter.localizedString(for: Date.init(timeIntervalSince1970: TimeInterval(friend.timestamp / 1000)), relativeTo: Date()))
                }
                (Text(Image(systemName:"headphones")) + Text(" ") + Text(friend.track.name))
                    .onTapGesture {
                        openURL(friend.track.album.uri)
                    }
                (Text(Image(systemName:"music.mic")) + Text(" ") +  Text(friend.track.artist.name))
                    .onTapGesture {
                        openURL(friend.track.artist.uri)
                    }
                HStack(){
                    (Text(Image(systemName:            ((friend.track.context.uri.split(separator: ":")[1] != "playlist") ? "opticaldisc" : "music.quarternote.3"))) + Text(" ") + Text(friend.track.context.name))
                        .onTapGesture {
                            openURL(friend.track.context.uri)
                        }
                }
            }
        }
    }
}
