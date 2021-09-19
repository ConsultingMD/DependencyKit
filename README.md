![DependencyKit Icon](https://raw.githubusercontent.com/adam-zethraeus/DependencyKit/main/Images/DependencyKit.png)
# DependencyKit

DependencyKit is a typesafe dependency injection framework for Swift.

## State of project

The DependencyKit library, this repo, which provides the API and the fundamentals is stable at version 1.0.0.

A [DependencyKit command line tool](https://github.com/DependencyKit/DependencyKitCLI) is under development, and is intended to reduce builderplate in passthrough dependencies. Without it, the library is still usable. Breaking changes to the library API are not anticipated.

## Philosophy

DependencyKit has three tenants:

1. Stay typesafe.
    
    *All* code is typechecked by the compiler and can not crash at runtime.
    Many Swift dependency injection setups either require you to manage potentially crashy runtime behavior or to trust the framework developers to do so for you. DependencyKit does neither.
    
    The Swift compiler has an advanced typesystem written by smart people. We should use it.

2. Don't get fancy.
    
    The code you write with DependencyKit is simple.
    The framework and generated code are simple.
    
    You're the one shipping the code. You should be able to read it.

3. It's just Swift.
    
    Your code you write with DependencyKit is idiomatic Swift.

DependencyKit aims to have *low code-size and binary-size footprints* and to be *fast at code-generation-time, compile-time, and runtime*—but not at the expense of the three tenants.

## Nomenclature & Conceptual Model 

DependencyKit helps you model application scopes through `Requirements` and `Resource`s. 

Scoping enforced by the compiler helps access, ownership, and lifecycle concerns. DependencyKit makes scoping easy.

### Requirements
**Requirements *declare* what a scope of the app needs—but can't build**. A scope has a single set of `Requirements` which describe what's required to be able to instantiate and run a section of your app.

An early scope of your app might need basic user login information: an identifier and session token.
```swift
protocol LoggedInRequirements: Requirements {
    var sessionToken: String { get }
    var userId: String { get }
}
```

A later scope of your app could require the data models used to hydrate its UI, a 'User' model used to highlight things authored by the logged-in user, and a pre-configured network service to be able to send user input to your server.
```swift
protocol ChatThreadListRequirements: Requirements {
    var chatThreadSource: AnyPublisher<[ChatThread], Error> { get }
    var messagingNetworkService: MessagingService { get }
    var currentUser: User { get }
}
```

### Resources
**`Resource`s *provide* things a scope of your app needs—and may build them**. There is one `Resource` per scope. It is the source for the entities that *its scope* uses, and it helps build its *child-scopes* by satisfying the child's declared `Requirements`.

`Resource`s should be used to *provide* all of what's needed by any construct in their scope.
They can *pass* things they've received from their parent-scopes through a structure their scope. They can also *build* things that are needed but not directly provided to them by their parent. (They often combine multiple things passed from their parents to make new entities that their parents don't need to know about.)

`Resource`s can only be instantiated with their defined `Requirements` satisfied. They take a generic `I` parameter which conforms to `Requirements` and are instantiated with an `init(injecting:)` call accepting an instance of `I`.

When building a child-scope you need to satisfy its `Requirements`. `Resource`s declare that they support a child-scope through protocol conformance, and are passed into then child-scope's `Resource`'s `init(injecting:)` initializer to create it.


A `LoggedInResource` might require state from parent-scope as `LoggedInRequirements` and build out state required to instantiate a child-scope, conforming to its `ChatThreadRequirements`. It could build its child-scope's `ChatThreadResource` directly, passing itself as the required generic `init(injecting:)` parameter.
```swift
class LoggedInResource<I: LoggedInRequirements>: Resource<I, ()>, ChatThreadRequirements {

    var currentUser: User {
        User(id: injected.userId, sessionToken: injected.sessionToken)
    }

    // An implementation of MessagingService
    private var webSocketMessagingService: WebSocketMessagingService {
        WebSocketMessagingService(user: self.currentUser)
    }

    var messagingNetworkService: MessagingService {
        self.webSocketMessagingService
    }

    var chatThreadSource: AnyPublisher<[ChatThread], Error> {
        self.webSocketMessagingService.streamingChatThreadSource
    }

    var chatThreadResource: ChatThreadResource {
        ChatThreadResource<LoggedInResource>(injecting: self)
    }
}
```

A `Resource` provides everything required by entities within its scope, not just what's needed to instantiate sub-scopes. It could do this by constructing these entities.

```swift
extension LoggedInResource {
    func threadsAuthoredByUserViewController(for user: User) -> ThreadsAuthoredByUserViewController {
        let filteredThreads = chatThreadSource.filter { $0.userId == user.id }
        return ThreadsAuthoredByUserViewController(threads: filteredThreads, for: user)
    }
}
```

Since DependencyKit code *is just Swift*, a resource can also conform to non-DependencyKit protocols in its scope.
```swift
protocol MyThreadsViewControllerParameters {
    var myThreads: AnyPublisher<[ChatThread], Error> { get }
    var user: User { get }
}
```

```swift
extension LoggedInResource: MyThreadsViewControllerParameters {

    var myThreads: AnyPublisher<[ChatThread], Error> {
        chatThreadSource.filter { $0.userId == currentUser.id }
    }

}
```

### Resources Part 2: Runtime Parameters

A `Resource` may also have runtime `parameters`. These are runtime dependencies—which are likely not directly available to the parent scope, and so are not modeled as `Requirements`.

They are likely to be configuration for the scope based on user input or network responses.

Parameters are the `Resource` superclass's second generic parameter, and are referenced as `parameters`.

e.g. If the `LoggedInResource` represents the earliest scope after authentication, its parent may not be able to *directly* provide a session token.

```swift

protocol LoggedInRequirements: Requirements {
    var userId: String { get }
}

struct LoggedInParameters {
    let sessionToken: String
}

class LoggedInResource<I: LoggedInRequirements>: Resource<I, LoggedInParameters>, ChatThreadRequirements {

    var currentUser: User {
        User(id: injected.userId, sessionToken: parameters.sessionToken)
    }
}
```

`LoggedInResource`'s parent `Resource` can now be refactored to use the `init(injecting:parameters:)` initializer.

```swift

protocol ReLoginRequirements: Requirements {
    var cachedUserId: String { get }
}

class ReLoginResource<I: PreAuthenticationRequirements>: Resource<I, ()>, LoggedInRequirements {

    var userId: String { injected.cachedUserId }

    func buildLoggedInResourceOnceAuthenticated(token: String) -> LoggedInResource {
        LoggedInResource(injecting: self,
                         paramaters: LoggedInParameters(sessionToken: token))
    }
}
```

### Cached Fields

It is often necessary to persist entities created in a scope across the scope's lifecycle. If a scope contains multiple constructs which should share state, they must all be able to reference it.

The ideal way to do this is to use a `let`—but `let` properties don't have access to `self`. `lazy var`s run after `init` as so have access to `self`—but they lack thread safety.

The `cached` helper function can provide a `lazy var`'s behavior while maintaining thread safety.


```swift

class CurrentScope<I: CurrentScopeRequirements>: Resource<I, ()>, ChildScopeRequirements {

    // If no access to the enclosing type is required a `let` is preferrable.
    let aConstant = UUID().uuidString

    // If your value is a constant data type you could also use a computed value
    var justData: String { "A constant piece of data" }

    // When you need to access other fields on the Resource a `lazy var` is safe only on a single thread.
    lazy var unsafeForMultithreadedAccess = "Requires access to `self` to compose with \(self.aConstant)."

    // The `cached(builder:)`, accessed as `cached { /*...*/ }`, will be evaluated and stored as a lazy var would.
    // But access is thread-safe.
    var safeLazyCachedValue: String {
        cached {
            "This can access \(String(describing: self)), and will return a constant value across accesses. \(UUID().uuidString)"
        }
    }


    // Note that this is particularly useful for shared state.


    var sharedSubject: PassthroughSubject<String, Never> {
        cached {
            PassthroughSubject<String, Never>()
        }
    }

    var broadcastPublisher: AnyPublisher<String, Never> {
        sharedSubject.eraseToAnyPublisher()
    }

    func buildBroadcaster() -> BroadcastingObject {
        BroadcastingObject(messaging: sharedSubject)
    }

    func buildReceiver() -> ListeningObject {
        ListeningObject(monitoring: broadcastPublisher)
    }

}
```

### Usage

`Resource`s are intended to be used as the 'Builder' layer of an application. They shouldn't be retained by the objects they create.

This is nicely achieved by passing builder functions from the `Resource` into the structures it creates.

```

protocol MVVMScopeRequirements {
    var dataSource: AnyPublisher<Models, Never> { get }
}

class MVVMScopeResource<I: MVVMScopeRequirements>: Resource<I, ()>, ChildScopeRequirements {

    var viewModel: ViewModel { ViewModel(dataSource: injected.dataSource) }
    var viewController: MyUIViewController { MyUIViewController(viewModel: viewModel, childBuilder: buildChildScope) }

    func buildChildScope() -> ChildScopeResource {
        ChildScopeResource(injecting: self)
    }
}

```

