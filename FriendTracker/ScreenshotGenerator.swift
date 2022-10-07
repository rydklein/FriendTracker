#if DEBUG
import SwiftUI
var screenshotDir:String {
    var pathArr = #filePath.split(separator:"/")
    _ = pathArr.popLast()
    _ = pathArr.popLast()
    return "/\(pathArr.joined(separator: "/").description)/screenshots/"
}
struct PreviewScreenshot: ViewModifier {
    struct LocatorView: UIViewRepresentable {
        let tag: Int
        func makeUIView(context: Context) -> UIView {
            return UIView()
        }
        func updateUIView(_ uiView: UIView, context: Context) {
            uiView.tag = tag
        }
    }
    private let tag = Int.random(in: 0..<Int.max)
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            LocatorView(tag: tag).frame(width: 0, height: 0)
            content
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                (UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive })
                as? UIWindowScene)!.windows.forEach { window in
                    guard window.viewWithTag(self.tag) != nil else { return }

                    UIGraphicsBeginImageContextWithOptions(window.bounds.size, window.isOpaque, 0.0)
                    window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
                    let image = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                    try? image.pngData()?.write(to: URL(fileURLWithPath: "\(screenshotDir)\(UIDevice.current.name).png"))
                }
            }
        }
    }
}

extension View {
    func screenshot() -> some View {
        self.modifier(PreviewScreenshot())
    }
}
#endif
