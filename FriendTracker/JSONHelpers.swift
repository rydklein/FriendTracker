import Foundation
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
