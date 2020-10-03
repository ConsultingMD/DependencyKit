import UIKit

// Dummy structures

struct UnauthenticatedService{}
struct AuthenticationService{
    func tryAuth(_ response: (Bool, String?) -> ()) {
        response(true, "token")
    }
}
struct AuthenticatedService{
    let token: String
}

struct Storage {}

// Dependency definitions

protocol LoggedOutDependency: Dependency {
    var storage: Storage { get }
    var unauthenticatedService: UnauthenticatedService { get }
    var authenticationService: AuthenticationService { get }
}

protocol HomeDependency: Dependency {
    var token: String { get }
    var authenticatedService: AuthenticatedService { get }
}

protocol ChatDependency: Dependency {
    var authenticatedService: AuthenticatedService { get }
    var storage: Storage { get }
}

// Component Implementation

protocol Dependency {}

// This is only required for the reflection API
protocol Parented: class {
    var typeErasedParent: Parented { get }
}

protocol ComponentProtocol: class where T: ComponentProtocol{
    associatedtype T
    var parent: T { get }
}

class NilComponent: ComponentProtocol, Parented {
    lazy var parent = self
    var typeErasedParent: Parented { parent }
}

class Component<ParentType, InitRequirementsTuple>: ComponentProtocol where ParentType: ComponentProtocol, ParentType: Parented {

    let parent: ParentType
    let requirements: InitRequirementsTuple

    init(parent: ParentType,
         requirements: InitRequirementsTuple) {
        self.parent = parent
        self.requirements = requirements
    }

}

extension Component: Parented {
    var typeErasedParent: Parented { parent }
}

// Test work

protocol OptionalStorageChatDependency: Dependency {
    var authenticatedService: AuthenticatedService { get }
    var storage: Storage? { get }
}

class ReflectingChatComponent: Component<HomeComponent, Void>, OptionalStorageChatDependency {
    var authenticatedService: AuthenticatedService { parent.authenticatedService }
    var storage: Storage? { reflectedFromAncestor(key: "storage", t: Storage.self) }

    func reflectedFromAncestor<T>(key: String, t: T.Type) -> T? {
        var current: Parented = self
        var parent = current.typeErasedParent
        repeat {
            if let value = Mirror(reflecting: current).descendant(key) as? T { return value }
            current = parent
            parent = parent.typeErasedParent
        } while current !== parent
        return nil
    }
}


// Usage

class LoggedOutComponent: Component<NilComponent, Void>, LoggedOutDependency {
    let unauthenticatedService = UnauthenticatedService()
    let authenticationService = AuthenticationService()
    let storage = Storage()
}

struct OtherHomeRequirements { let token: String}
class HomeComponent: Component<LoggedOutComponent, OtherHomeRequirements>, HomeDependency {
    var token: String { requirements.token }
    var authenticatedService: AuthenticatedService { AuthenticatedService(token: token) }
}

class ChatComponent: Component<HomeComponent, Void>, ChatDependency {
    var authenticatedService: AuthenticatedService { parent.authenticatedService }
    var storage: Storage { parent.parent.storage } // in theory we could codegen (or runtime) an 'any-ancestor'

    func test<T>(key: String, t: T.Type) -> T? {
        if let value = Mirror(reflecting: self).descendant(key) as? T { return value }
        return nil
    }

    func testTest() {
        let x = test(key: "storage", t: Storage.self)
        x // Storage?
    }
}
