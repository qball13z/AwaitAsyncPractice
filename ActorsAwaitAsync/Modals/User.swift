struct UserResult: Codable {
    let results: [User]
}

public struct User: Codable, Equatable {
    let gender: String
    let name: NameInfo
    let location: Location
    let email: String
    let picture: PictureInfo
}

struct NameInfo: Codable, Equatable {
    let title: String
    let first: String
    let last: String
}

struct Location: Codable, Equatable {
    let street: Street
    let city: String
    let state: String
    let country: String
    let coordinates: Coordinates
    let timezone: Timezone
}

struct Street: Codable, Equatable {
    let number: Int
    let name: String
}

struct Coordinates: Codable,Equatable {
    let latitude: String
    let longitude: String
}

struct Timezone: Codable, Equatable {
    let offset: String
    let description: String
}

struct PictureInfo: Codable, Equatable {
    let large: String
    let medium: String
    let thumbnail: String
}
