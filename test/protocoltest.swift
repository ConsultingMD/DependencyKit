import Foundation

// FRAMEWORK

protocol Component {
    associatedtype Requirements
    var requirements: Requirements { get }
}

protocol Provisions: Component {}

protocol NilProvisions: Provisions {}

class NilComponentProvisions: NilProvisions {
    lazy var requirements = self
}

class ComponentObject<Dep>: Provisions where Dep: Provisions {
    typealias Requirements = Dep
    let requirements: Dep
    init(requirements: Dep) {
        self.requirements = requirements
    }
}

// EXAMPLE
let fakeProfilePayload = ProfilePayload(avatarURL: nil)
let fakeFileSystemResult = "http://afile.png"
let fakeLogOutPayload = LogOutPayload()
let fakeUpdateProfilePayload = ProfilePayload(avatarURL: "https://s3.example.com/avatar.png")
let fakeURLQueryResult = Data()
let fakeIdentityToken = IdentityToken()

struct BadResultTypeError: Error {}
struct Result<T1> {
    let value: T1?
    let error: Error?
    init(value: T1) {
        self.value = value
        self.error = nil
    }

    init(error: Error) {
        self.error = error
        self.value = nil
    }

    private init(value: T1?, error: Error?) {
        fatalError()
    }

    init<T0>(result: Result<T0>) {
        if let value = result.value, let t1Value = value as? T1 {
            self.value = t1Value
            self.error = nil
        } else if let error = result.error {
            self.error = error
            self.value = nil
        } else {
            // assumes all Results are properly constructed
            self.error = BadResultTypeError()
            self.value = nil
        }
    }
}

enum NetworkProtocol: String {
    case http
    case https
}
protocol URLService {
    var networkProtocol: NetworkProtocol { get }
}
extension URLService {
    func query(url: String) -> Result<Data> {
        let fullURL = networkProtocol.rawValue + url
        print("query: \(fullURL)")
        return Result(value: fakeURLQueryResult)
    }
}
struct UnsecuredService: URLService {
    let networkProtocol = NetworkProtocol.http
}
struct SecuredService: URLService {
    let networkProtocol = NetworkProtocol.https
}

struct LocalFileSystemWriter {
    func writeLocalFile(_: Data) -> String? {
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

struct LogOutPayload {}

struct ProfilePayload {
    let avatarURL: String?
}

struct AuthenticatedService {
    let token: IdentityToken
    let urlService: URLService
    func logOut() -> Result<LogOutPayload> {
        return Result<LogOutPayload>(result: urlService.query(url: "/logout"))
    }
    func getProfile() -> Result<ProfilePayload> {
        return Result(value: fakeProfilePayload)
    }
    func updateProfile() -> Result<ProfilePayload> {
        return Result(value: fakeUpdateProfilePayload)
    }
}

// INTERFACE

protocol LoggedOutProvisions: Provisions {
    var urlService: URLService { get }
    var identityService: IdentityService { get }
}

protocol LoggedInProvisions: Provisions {
    var authenticatedService: AuthenticatedService { get }
}

protocol ProfileProvisions: Provisions {
    var urlService: URLService { get }
    var localFileSystemWriter: LocalFileSystemWriter { get }
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

extension LoggedInProvisions {
    // fundamentally if we want to write code w/ extensions it *will* have to have this as an autogen step.
    var urlService: URLService {
        // is there a way to get this from parent?
        UnsecuredService()
    }
}


// IMPL

class DevelopmentRootComponent<Requirements: NilProvisions>: ComponentObject<Requirements>,
                                                             LoggedOutProvisions {
    let urlService: URLService = UnsecuredService()
    lazy var identityService = IdentityService(urlService: urlService)
}

class ProductionRootComponent<Requirements: NilProvisions>: ComponentObject<Requirements>,
                                                            LoggedOutProvisions {
    let urlService: URLService = SecuredService()
    lazy var identityService = IdentityService(urlService: urlService)
}

class LoggedOutComponent<Requirements: LoggedOutProvisions>: ComponentObject<Requirements>,
                                                             LoggedInProvisions {
    lazy var authenticatedService = AuthenticatedService(token: IdentityToken(), urlService: requirements.urlService)
}

class LoggedInComponent<Requirements: LoggedInProvisions>: ComponentObject<Requirements>,
                                                           ProfileProvisions, SettingsProvisions {
    lazy var urlService = requirements.urlService
    let localFileSystemWriter = LocalFileSystemWriter()
    let systemPermissionManager = SystemPermissionManager()
}


// USAGE

let rootComponent = DevelopmentRootComponent(requirements: NilComponentProvisions())
let loggedOutComponent = LoggedOutComponent(requirements: rootComponent)
//let loggedInComponent = LoggedInComponent(requirements: loggedOutComponent)
