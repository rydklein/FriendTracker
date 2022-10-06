import SwiftUI
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
