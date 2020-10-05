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

struct Storage {
    let location = "disk"
}

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

class Component<ParentType>: ComponentProtocol where ParentType: ComponentProtocol, ParentType: Parented {
    let parent: ParentType
    init(parent: ParentType) {
        self.parent = parent
    }
}

class ExtraRequirementsComponent<ParentType, ExtraRequirementsTuple>: Component<ParentType> where ParentType: ComponentProtocol, ParentType: Parented {

    let requirements: ExtraRequirementsTuple

    init(parent: ParentType,
         requirements: ExtraRequirementsTuple) {
        self.requirements = requirements
        super.init(parent: parent)
    }
}


// reflected api impl
extension Component {
    func reflectedFromAncestor<T>(key: String, type: T.Type) -> T? {
        // You'd probably want to cache the ancestor for the key-Type
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

extension Component: Parented {
    var typeErasedParent: Parented { parent }
}

// dyanmic lookup api. slightly better than reflection. requires extra storage.
@dynamicMemberLookup
class DynamicAncestorSelector<C: ComponentProtocol, P: ComponentProtocol, R, D: Dependency> {
    private let component: C
    init?(component: C, parent: P?) {
        guard component !== parent else { return nil }
        self.component = component
    }

    subscript<R>(dynamicMember property: String) -> R? {
        // can't use keypath as can't modify to point to new type.
        // we'd have to store a dict of name-type: dep.
        return nil
    }
}

// Reflection API usage.

protocol OptionalStorageChatDependency: Dependency {
    var authenticatedService: AuthenticatedService { get }
    var storage: Storage? { get }
}

class ReflectingChatComponent: Component<HomeComponent>, OptionalStorageChatDependency {
    var authenticatedService: AuthenticatedService { parent.authenticatedService }
    var storage: Storage? { reflectedFromAncestor(key: "storage", type: Storage.self) }
}


// Usage

class LoggedOutComponent: Component<NilComponent>, LoggedOutDependency {
    let unauthenticatedService = UnauthenticatedService()
    let authenticationService = AuthenticationService()
    let storage = Storage()
}

struct OtherHomeRequirements { let token: String}
class HomeComponent: ExtraRequirementsComponent<LoggedOutComponent, OtherHomeRequirements>, HomeDependency {
    var token: String { requirements.token }
    var authenticatedService: AuthenticatedService { AuthenticatedService(token: token) }
}

class ChatComponent: Component<HomeComponent>, ChatDependency {
    var authenticatedService: AuthenticatedService { parent.authenticatedService }
    var storage: Storage { parent.parent.storage } // in theory we could codegen (or runtime) an 'any-ancestor'
}

// Test

let loggedOutComponent = LoggedOutComponent(parent: NilComponent())
loggedOutComponent.authenticationService.tryAuth { (success, value) in
    if let value = value, success {
        let homeComponent = HomeComponent(parent: loggedOutComponent, requirements: OtherHomeRequirements(token: value))
        let chatComponent = ChatComponent(parent: homeComponent)
        print(chatComponent.storage.location)
    }
}


