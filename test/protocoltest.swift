import Foundation

// FRAMEWORK

protocol Component {
    associatedtype Requirements 
}

protocol Provisions {}

protocol ComponentProvisions: Component, Provisions {}


class NilComponentProvisions: ComponentProvisions {
    typealias Requirements = NilComponentProvisions
    lazy var requirements = self
}

class ComponentObject<Dep: ComponentProvisions>: Component {
    typealias Requirements = Dep
    let requirements: Requirements
    init(requirements: Dep) {
        self.requirements = requirements
    }
}

// EXAMPLE
let fakeFileSystemResult = URL(string: "//afile.png")!
let fakeProfilePayload = ProfilePayload(avatarURL: nil)
let fakeLogOutPayload = LogOutPayload()
let fakeUpdateProfilePayload = ProfilePayload(avatarURL: URL(string: "https://s3.example.com/avatar.png")!)
let fakeURLQueryResult = Data()
let fakeIdentityToken = IdentityToken()

struct Result<T1, Error> {
    let value: T1?
    let error: Error?
}

struct URLService {
    func query(url: URL) -> Result<Data, Error> {
        return Result(value: fakeURLQueryResult, error: nil)
    }
}

struct LocalFilesystemWriter {
    func writeLocalFile(_: Data) -> URL? {
        // write the file
        return fakeFileSystemResult
    }
}

struct SystemPermissionManager {
    func requestAllPermissions() {}
}

struct IdentityToken {}

struct IdentityService {
    let urlService: URLService
    func logIn() -> IdentityToken {
        return fakeIdentityToken
    }
}

struct LogOutPayload: Codable {}

struct ProfilePayload: Codable {
    let avatarURL: URL?
}

struct AuthenticatedService {
    let token: IdentityToken
    func logOut() -> Result<LogOutPayload, Error> {
        return Result(value: fakeLogOutPayload, error: nil)
    }
    func getProfile() -> Result<ProfilePayload, Error> {
        return Result(value: fakeProfilePayload, error: nil)
    }
    func updateProfile() -> Result<ProfilePayload, Error> {
        return Result(value: fakeUpdateProfilePayload, error: nil)
    }
}

// INTERFACE

protocol RootProvisions: Provisions {
    var urlService: URLService { get }
}

protocol LoggedOutProvisions: Provisions {
    var identityService: IdentityService { get }
}

protocol LoggedInProvisions: Provisions {
    var authenticatedService: AuthenticatedService { get }
}

protocol ProfileProvisions: Provisions {
    var urlService: URLService { get }
    var avatarURL: URL { get }
    var localFilesystemWriter: LocalFilesystemWriter { get }
}

protocol SettingsProvisions: Provisions {
    var systemPermissionManager: SystemPermissionManager { get }
}

// AUTOGEN EXTENSIONS

// extension Thinking where Self: Component, Component.Requirements == Person {
//     var requirements: Person { requirements }
//     func say(_ string: String) { requirements.say(string) }
// }

// extension Thinking where Self == Test<YellingPerson> {
//     var requirements: YellingPerson { requirements }
//     func say(_ string: String) { requirements.say(string) }
// }


// IMPL


// USAGE

