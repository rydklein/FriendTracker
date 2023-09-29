//
//  PreviewHelpers.swift
//  FriendTracker
//
//  Created by Ryder Klein on 9/29/23.
//

import Foundation
import SwiftUI
import UIKit

#if DEBUG

func loadJSONFile<T: Decodable>(_ filename: String) -> T {
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

var screenshotDir: String {
    var pathArr = #filePath.split(separator: "/")
    _ = pathArr.popLast()
    _ = pathArr.popLast()
    return "/\(pathArr.joined(separator: "/").description)/screenshots/"
}

// Ancient code from somewhere on the internet to generate screenshots of SwiftUI previews. Considering getting rid of it altogether.
struct PreviewScreenshot: ViewModifier {
    struct LocatorView: UIViewRepresentable {
        let tag: Int
        func makeUIView(context: UIViewRepresentableContext<LocatorView>) -> UIView {
            return UIView()
        }

        func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LocatorView>) {
            uiView.tag = tag
        }
    }

    private let tag = Int.random(in: 0 ..< Int.max)
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
        modifier(PreviewScreenshot())
    }
}
#endif
