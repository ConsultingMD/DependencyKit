![Icon](https://raw.githubusercontent.com/adam-zethraeus/DependencyKit/main/icon.svg)
# DependencyKit

DependencyKit is a typesafe codegenerated dependency injection framework for Swift. It's under development and isn't ready for use.

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

DependencyKit helps you model application 'scopes' through `Requirements` and `Resource`s. 

### Scopes
There is no `Scope` entity in DependencyKit. 'Scopes' are a conceptual framework which improve our ability to model app logic by facilitating clear ownership and separation of concerns.

A 'scope' is a grouping of entities which: 
* Share a lifecycle boundary—when the scope ends all entities in the scope are deinitialized
* Share access to their dependencies—entities in the same scope can reach the same things

Scopes contain child-scopes which:
* Have shorter or equal lifetimes—a child scope never outlives its parent
* Have *potential* access to only a subset of the entities their parent-scopes have—a parent scope can always create a sub-scope with some or all of the context it has
* Have a more specialized purpose than their parents
* Create and use more specialized entities than their parents—a parent scope should usually avoid creating an entity it doesn't use, it should delegate creation to the child-scope which does use it

The value of careful scoping is well illustrated by considering its antithesis: pervasive use of global state or Singletons.

Singletons, by design, make an entity available to the whole application—the full 'app scope'. This can be convenient in the short term but usually introduces hazardous potential complexity.

When an entity isn't in a usable state for the whole app lifecycle but is nevertheless available its easy to use inappropriately. If it's always accessible how can you know not to use it? Will you be able to tell if a usage is appropriate when stumble on it a year from now? Will your co-authors be able to? The compiler certainly won't.

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
**`Resource`s *provide* things a scope of your app needs—and may build them**. There is one `Resource` per scope. They are the source for the entities that *their scope* uses, and they help build their *child-scopes* by satisfying the child's declared `Requirements`.

`Resource`s should be used to *provide* all of what's needed by any construct in their scope.
They can *pass* things they've received from their parent-scopes through a structure their scope. They can also *build* things that are needed but not directly provided to them by their parent. (They often combine multiple things passed from their parents to make new entities that their parents don't need to know about.)

`Resource`s can only be instantiated with their defined `Requirements` satisfied. They take a generic `I` parameter which conforms to `Requirements` and are instantiated with an `init(injecting:)` call accepting an instance of `I`.

When building a child-scope you need to satisfy its `Requirements`. `Resource`s declare that they support a child-scope through protocol conformance, and are passed into then child-scope's `Resource`'s `init(injecting:)` initializer to create it.


A `LoggedInResource` might require state from parent-scope as `LoggedInRequirements` and build out state required to instantiate a child-scope, conforming to its `ChatThreadRequirements`. It could build its child-scope's `ChatThreadResource` directly, passing itself as the required generic `init(injecting:)` parameter.
```swift
class LoggedInResource<I: LoggedInRequirements>: Resource<I>, ChatThreadRequirements {

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

DependencyKit itself is not prescriptive about how you use `Resource`s. We've found that using `Resources` primarily as builders for entities (like view controllers, manager classes, views, and view models) within their scopes works well. We intend to add more real world examples to the demo app.

### TL;DR
DependencyKit helps you model explicit 'scopes' in your app and reduces the boilerplate needed to manage passing dependencies into them.

`Requirements` describe things your scopes need. `Resource`s satisfy requirements needed to build things in a scope—including their sub-scopes' `Resource`s.

-----

## Proof of concepts

These code blocks show values pass in different useful ways across multiple `Requirements` & `Resource`s:
* Explicitly in each `Requirements` definition
* Implicitly, leaning on typesafe code generation to remove boiler plate by skipping intermediate `Requirements`
* Explicitly, but modified by a sub-scope `Resource`
* Un-passed, and explicitly replaced by a sub-scope `Resource`

### Definitions

```swift
class ScopeZeroResource<I: NilRequirements>: Resource<I>,
                                             ScopeOneRequirements {
    let explicit = "s0-explicit"
    let implicit = "s0-implicit"
    let modified = "s0-modified"
    let recreated = "s0-recreated"
    let dropped = "s0-dropped"
    
    func buildScopeOne() -> ScopeOneResource<ScopeZeroResource> { ScopeOneResource(injecting: self) }
}
```

```swift
protocol ScopeOneRequirements: Requirements, CODEGEN_ScopeOneRequirements {
    var explicit: String { get }
    var modified: String { get }
}

class ScopeOneResource<I: ScopeOneRequirements>: Resource<I>,
                                                 ScopeTwoRequirements {
    // Must be lazy to access `injected`.
    // Must access injected as this var overrides `modified` passed from injected.
    lazy var modified = "s1-modified-\(injected.modified)"
    let createdLater = "s1-createdLater"
    let recreated = "s1-recreated"
    
    func buildScopeTwo() -> ScopeTwoResource<ScopeOneResource> {
        ScopeTwoResource(injecting: self)
    }
}

```

```swift
protocol ScopeTwoRequirements: Requirements, CODEGEN_ScopeTwoRequirements {
    var explicit: String { get }
    var modified: String { get }
    var recreated: String { get }
    var createdLater: String { get }
}


class ScopeTwoResource<I: ScopeTwoRequirements>: Resource<I>,
                                                 ScopeThreeRequirements{
    var duplicated: String { explicit }

    func buildScopeThree() -> ScopeThreeResource<ScopeTwoResource> {
        ScopeThreeResource(injecting: self)
    }
}

```

```swift
protocol ScopeThreeRequirements: Requirements, CODEGEN_ScopeThreeRequirements {
    var explicit: String { get }
    var implicit: String { get }
    var modified: String { get }
    var recreated: String { get }
    var createdLater: String { get }
    var duplicated: String { get }
}


class ScopeThreeResource<I: ScopeThreeRequirements>: Resource<I> {
}

```

### Usage 

```swift
var output: [String] = []
let root = ScopeZeroResource(injecting: NilResource())
let one = root.buildScopeOne()
let two = one.buildScopeTwo()
let three = two.buildScopeThree()
output += [
    "_____ Root _____",
    "explicit: '\(root.explicit)'",
    "implicit: '\(root.implicit)'",
    "modified: '\(root.modified)'",
    "recreated: '\(root.recreated)'",
    "createdLater: < N/A, created in later scope >",
    "duplicated: < N/A, created in later scope >",
    "dropped: '\(root.dropped)'",
    "",
]
output += [
    "_____ One _____",
    "explicit: '\(one.explicit)'",
    "implicit: < Unavailable, not in Requirements. (Passed only implicitly to descendent explicit uses) >",
    "modified: '\(one.modified)'",
    "recreated: '\(one.recreated)'",
    "createdLater: '\(one.createdLater)'",
    "duplicated: < N/A, created in later scope >",
    "dropped: < Unavailable, not in Requirements >",
    "",
]
output += [
    "_____ Two _____",
    "explicit: '\(two.explicit)'",
    "implicit: '\(two.implicit)'",
    "modified: '\(two.modified)'",
    "recreated: '\(two.recreated)'",
    "createdLater: '\(two.createdLater)'",
    "duplicated: '\(two.duplicated)'",
    "dropped: < Unavailable, not in Requirements >",
    "",
]
output += [
    "_____ Three _____",
    "explicit: '\(three.explicit)'",
    "implicit: '\(three.implicit)'",
    "modified: '\(three.modified)'",
    "recreated: '\(three.recreated)'",
    "createdLater: '\(three.createdLater)'",
    "duplicated: '\(three.duplicated)'",
    "dropped: < Unavailable, not in Requirements >",
    "",
]

print(output)
```

### Output

```
_____ Root _____
explicit: 's0-explicit'
implicit: 's0-implicit'
modified: 's0-modified'
recreated: 's0-recreated'
createdLater: < N/A, created in later scope >
duplicated: < N/A, created in later scope >
dropped: 's0-dropped'

_____ One _____
explicit: 's0-explicit'
implicit: < Unavailable, not in Requirements. (Passed only implicitly to descendent explicit uses) >
modified: 's1-modified-s0-modified'
recreated: 's1-recreated'
createdLater: 's1-createdLater'
duplicated: < N/A, created in later scope >
dropped: < Unavailable, not in Requirements >

_____ Two _____
explicit: 's0-explicit'
implicit: 's0-implicit'
modified: 's1-modified-s0-modified'
recreated: 's1-recreated'
createdLater: 's1-createdLater'
duplicated: 's0-explicit'
dropped: < Unavailable, not in Requirements >

_____ Three _____
explicit: 's0-explicit'
implicit: 's0-implicit'
modified: 's1-modified-s0-modified'
recreated: 's1-recreated'
createdLater: 's1-createdLater'
duplicated: 's0-explicit'
dropped: < Unavailable, not in Requirements >


```
