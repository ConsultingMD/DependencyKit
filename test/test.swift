
// Dummy structures

struct UnauthenticatedService{}
struct AuthenticationService{
    func tryAuth(_ response: (Bool, String?) -> ()) {
        response(true, "token")
    }
}

struct AuthenticatedService {
    let token: String
    func getActiveChats(_ response: (Bool, [String]) -> ()) {
        response(true, ["id1", "id2", "id23"])
    }
}

struct ChatService {
    let authenticatedService: AuthenticatedService
    func getNewMessages(for chatId: String, _ callback: (Bool, [(chat: String, messages: [String])]) -> ()) {
        guard chatId == "id1" else { callback(false, []); return }
        callback(true, [(chat: chatId, messages: ["hello!", "where are you?", "hellllooooo?"])])
    }
    func sendMessage(to chatId: String, _ callback: (Bool) -> ()) {
        callback(true)
    }
}

struct Storage {
    let location = "disk"
}

struct Alerter {
    func alert(_ alert: String){
        print(alert)
    }
}

struct Animator {
    func animate(gif: String) {
        print("i'm animating: \(gif)")
    }
}

// Dependency definitions

protocol LoggedOutViewControllerDependency {
    var alerter: Alerter { get }
}

protocol LoggedOutViewModelDependency {
    var storage: Storage { get }
    var authenticationService: AuthenticationService { get }
}

protocol HomeViewControllerDependency {
    var animator: Animator { get }
}

protocol HomeViewModelDependency {
    var authenticatedService: AuthenticatedService { get }
}

protocol ChatViewModelDependency {
    var storage: Storage { get }
    var chatService: ChatService { get }
}

protocol ChatViewControllerDependency {
    var alerter: Alerter { get }
}

// Component Implementation

// private extension?
protocol TraversableDependency where Parent: TraversableDependency {
    associatedtype Parent
    var parent: Parent { get } // we want to make this module-internal.
}

protocol Dependency: TraversableDependency {}

protocol NilRequirements: Dependency {}

class NilComponent: Dependency, NilRequirements {
    lazy var parent = self
}

class Component<Parent>: Dependency where Parent: Dependency {
    let parent: Parent
    init(parent: Parent) {
        self.parent = parent
    }
}

//class ExtraRequirementsComponent<ParentType, ExtraRequirementsTuple>: Component<ParentType> where ParentType: TraversableDependency {
//    let requirements: ExtraRequirementsTuple
//    init(parent: ParentType,
//         requirements: ExtraRequirementsTuple) {
//        self.requirements = requirements
//        super.init(parent: parent)
//    }
//}

// Usage

typealias LoggedOutRequirements = NilRequirements
protocol LoggedOutProvisions: LoggedOutViewModelDependency,
                              LoggedOutViewControllerDependency,
                              HomeRequirements {} // once chat conformance has been added to this, it needs autogen.

class LoggedOutComponent<Parent: LoggedOutRequirements>: Component<Parent>, LoggedOutProvisions {
    let authenticationService = AuthenticationService()
    let storage = Storage()
    let alerter = Alerter()
    let token = "dummy requires constructor injection; should  be fetched from auth service"
}

let loggedOut = LoggedOutComponent<NilComponent>(parent: NilComponent())


protocol HomeRequirements: Dependency {
    var token: String { get }
}
protocol HomeProvisions: HomeViewControllerDependency,
                         HomeViewModelDependency,
                         ChatRequirements {} // when ChatRequirements is added, the following must be autogenerated .....

/// start autogen

extension HomeComponent where Parent: HomeRequirements {
    var alerter: Alerter { parent.alerter }
    var storage: Storage { parent.storage }
}

extension HomeRequirements where Self == LoggedOutComponent<Parent>, Parent: LoggedOutRequirements {
    var alerter: Alerter { self.alerter }
    var storage: Storage { self.storage }
}

/// end autogen

class HomeComponent<Parent: HomeRequirements>: Component<Parent>, HomeProvisions {
    let animator = Animator()
    var authenticatedService: AuthenticatedService { AuthenticatedService(token: parent.token) }
}

let home = HomeComponent(parent: loggedOut)

protocol ChatRequirements: Dependency {
    var authenticatedService: AuthenticatedService { get }
    var alerter: Alerter { get }
    var storage: Storage { get }
}
typealias ChatProvisions = ChatViewModelDependency & ChatViewControllerDependency

class ChatComponent<Parent: ChatRequirements>: Component<Parent>, ChatProvisions {
    var alerter: Alerter { parent.alerter }
    var storage: Storage { parent.storage }
    var chatService: ChatService { ChatService(authenticatedService: parent.authenticatedService) }
}

let chat = ChatComponent(parent: home)
chat.alerter.alert("hi")



//struct OtherHomeRequirements { let token: String}
//class HomeComponent: ExtraRequirementsComponent<LoggedOutComponent, OtherHomeRequirements>, HomeViewControllerDependency {
//    var token: String { requirements.token }
//    var authenticatedService: AuthenticatedService { AuthenticatedService(token: token) }
//}
//
//class ChatComponent: Component<HomeComponent>, ChatViewControllerDependency {
//    var authenticatedService: AuthenticatedService { parent.authenticatedService }
//    var storage: Storage { parent.parent.storage } // in theory we could codegen (or runtime) an 'any-ancestor'
//}
//
//// Test
//
//let loggedOutComponent = LoggedOutComponent(parent: NilComponent())
//loggedOutComponent.authenticationService.tryAuth { (success, value) in
//    if let value = value, success {
//        let homeComponent = HomeComponent(parent: loggedOutComponent, requirements: OtherHomeRequirements(token: value))
//        let chatComponent = ChatComponent(parent: homeComponent)
//        print(chatComponent.storage.location)
//    }
//}


