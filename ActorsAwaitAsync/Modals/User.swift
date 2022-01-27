struct UserResult: Codable {
    let results: [User]
}

public struct User: Codable {
    let gender: String
    let name: NameInfo
    let location: Location
    let email: String
    let picture: PictureInfo
}

struct NameInfo: Codable {
    let title: String
    let first: String
    let last: String
}

struct Location: Codable {
    let street: Street
    let city: String
    let state: String
    let country: String
    let coordinates: Coordinates
    let timezone: Timezone
}

struct Street: Codable {
    let number: Int
    let name: String
}

struct Coordinates: Codable {
    let latitude: String
    let longitude: String
}

struct Timezone: Codable {
    let offset: String
    let description: String
}

struct PictureInfo: Codable {
    let large: String
    let medium: String
    let thumbnail: String
}
