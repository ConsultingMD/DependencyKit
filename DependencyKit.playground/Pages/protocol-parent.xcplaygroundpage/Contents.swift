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

protocol StartupProvisions: Provisions {
    var startupTime: Date { get }
}

protocol LoggedOutProvisions: StartupProvisions {
    var urlService: URLService { get }
    var identityService: IdentityService { get }
}

protocol LoggedInProvisions: Provisions {
    var urlService: URLService { get }
    var authenticatedService: AuthenticatedService { get }
}

protocol ProfileProvisions: Provisions {
    var urlService: URLService { get }
    var localFileSystemWriter: LocalFileSystemWriter { get }
}

protocol SettingsProvisions: Provisions {
    var systemPermissionManager: SystemPermissionManager { get }
    var startupTime: Date { get }
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

// Path 0:
// - extend every provision to provide all of its subtrees requirements from their impls.
// - extend the ComponentObject to fetch non-subclassed definitions from its parent.
//      - but the ComponentObject can't be parametrized with a concrete impl (or you'd have to write one per path to node).
//      - so this requires the Requirements generic parameter protocol to be known to implement a protocol asserting it providers the child requirements.
//          - this may not be possible
//      - the impl also needs to be extended somehow to call to the requirements IFF it lacks implementation.
//          - this seems to require per-impl code.
//         - caveat, if replacing your own implemented protocol's extension provision is possible, this can be skipped.

// Path 1:
// - extend every component to have all of its subtree's requirements.
// - this would also mean extending the requirement extension to satisfy it if the it's not already used at that level. (?)
//extension LoggedOutComponent { // we could have a protocol defining all non-immediate requirements that it fills. but probably not required.
//    // as the logged out component doesn't use this directly it doesn't define it.
//    // we must autogen a definition to pass it to the child.
//    var urlService: URLService {
//        requirements.urlService
//    }
//
//    var startupTime: Date {
//        requirements.startupTime
//    }
//}

// Path 2:
// - Each requirement independent, with a protocol name as a token.

// Promising. breaking out into token-base.

// could these be named tokens?
protocol StartupTimeProviding {
    var startupTime: Date { get }
}

protocol Parented {
    associatedtype ParentRequirements
    var parentRequirements: ParentRequirements { get }
}
extension Parented where ParentRequirements: StartupTimeProviding { // would a class implementing this still be able to provide an override?
    var startupTime: Date {
        parentRequirements.startupTime
    }
}

class TestRootNode: StartupTimeProviding {
    var startupTime = Date()
}

class TestChildNode: Parented {
    typealias ParentRequirements = StartupTimeProviding
    let parentRequirements: StartupTimeProviding
    init(parent: StartupTimeProviding) {
        parentRequirements = parent
    }
//    let startupTime = Date.init(timeIntervalSince1970: 0)
}

extension TestChildNode {
    var startupTime: Date { parentRequirements.startupTime }
}

let root = TestRootNode()
let child = TestChildNode(parent: root)
print(child.startupTime)

// IMPL
//
//class DevelopmentRootComponent<Requirements: NilProvisions>: ComponentObject<Requirements>,
//                                                             LoggedOutProvisions {
//    let startupTime = Date()
//    let urlService: URLService = UnsecuredService()
//    lazy var identityService = IdentityService(urlService: urlService)
//}
//
//class ProductionRootComponent<Requirements: NilProvisions>: ComponentObject<Requirements>,
//                                                            LoggedOutProvisions {
//    let startupTime = Date()
//    let urlService: URLService = SecuredService()
//    lazy var identityService = IdentityService(urlService: urlService)
//}
//
//class LoggedOutComponent<Requirements: LoggedOutProvisions>: ComponentObject<Requirements>,
//                                                             LoggedInProvisions {
//    lazy var authenticatedService = AuthenticatedService(token: IdentityToken(), urlService: requirements.urlService)
//}
//
////class LoggedInComponent<Requirements: LoggedInProvisions>: ComponentObject<Requirements>,
////                                                           ProfileProvisions, SettingsProvisions {
////    let localFileSystemWriter = LocalFileSystemWriter()
////    let systemPermissionManager = SystemPermissionManager()
////}
//
//
//// USAGE
//
//let rootComponent = DevelopmentRootComponent(requirements: NilComponentProvisions())
//let loggedOutComponent = LoggedOutComponent(requirements: rootComponent)
////let loggedInComponent = LoggedInComponent(requirements: loggedOutComponent)
