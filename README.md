![Icon](https://raw.githubusercontent.com/adam-zethraeus/DependencyKit/main/icon.svg)
# DependencyKit

DependencyKit is a typesafe codegenerated dependency injection framework for Swift.

## Philosophy

DependencyKit has three tenants:
1. Typesafety. *All* code should be typechecked by the compiler and can not crash at runtime. <sup id="a1">[1](#f1)</sup>
2. No magic. The framework and generated code should be easily understood.
3. Simply Swift. Your code written with DependencyKit is idiomatic Swift.

DependencyKit also aims to have a low binary-size footprint and to be fast at code-generation-time, compile-time, and runtime—but will not compromise on the three tenants for these aims.

<sup>[[1]](#a1) Both framework code and generated code are typesafe. This distinguishes DependencyKit from many other Swift dependency injection frameworks. The code you use DependencyKit to inject is as typesafe as you make it :).</sup>

## Nomenclature & Conceptual Model 

DependencyKit's model has 'Requirements' and 'Resources'. 

**Requirements are your declared API**. They describe what's required to instantiate a specific part of your app.

An early stage of your app might designate that a logged in user and session token are pre-defined.
```swift
protocol LoggedInRequirements: Requirements {
    var sessionToken: String { get }
    var userId: String { get }
}
```

A later stage of your app might also require data models representing things to show in the UI and a pre-configured network service.
```swift
protocol ChatThreadListRequirements: Requirements {
    var chatThreadSource: AnyPublisher<[ChatThread], Error> { get }
    var messagingNetworkService: MessagingService { get }
    var currentUser: User { get }
}
```

**Resources provide things to your app**. They're the source of the data structures you use in your application code and are used to satisfy the Requirements your code has declared.

Resources specify the Requirements they need as a generic parameter. The properties are made available on its `injected` property. 
Resources can also satisfy *other* Resource's DependencyKit Requirements—and indicate that they do so through protocol conformance.

A Resource might require state from a earlier stage of your app and build out state and data structures required for later stages.
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

}
```

Since this is *Simply Swift* a resource can just as easily satisfy any other non-DependencyKit protocol you have in your app.
```swift
extension LoggedInResource: LegacyUserInfo {}
```

```swift
// TODO: Finish 2017 migration to accept a plain User object.
protocol LegacyUserInfo {
    var currentUser: User { get }
}
```

**TL;DR:** `Requirements` define dependencies. `Resources` provide requirements.

## Proof of concepts

These code blocks show different types of values passed across multiple Requirements & Resources:
* Values passes explicitly in each Requirements definition.
* Values passes implicitly (skipping some requirements definitions).
* Values modification by subsequent Resources.
* Values replaced by subsequent Resources.

### Root
```swift
public class RootResource<I: NilRequirements>: Resource<I>,
                                               LevelOneRequirements {
    
    public let explicitPassthrough = "Root value passed through explicitly"
    public let implicitPassthrough = "Root value passed implicitly"
    public let modified = "Root value to be modified"
    public let recreated = "Root value to be recreated"
    
    public var levelOneResource: LevelOneResource<RootResource> { LevelOneResource(injecting: self) }
}
```

### Level One
```swift
public protocol LevelOneRequirements: Requirements, CODEGEN_LevelOneRequirements {
    var explicitPassthrough: String { get }
    var modified: String { get }
}

public class LevelOneResource<I: LevelOneRequirements>: Resource<I>,
                                                        LevelTwoRequirements {
    
    public lazy var modified = "Value modified based on source: '\(injected.modified)'"
    public let recreated = "Value recreated independent of original"
    
    public var levelTwoResource: LevelTwoResource<LevelOneResource> { LevelTwoResource(injecting: self) }
}

```

### Level Two
```swift
public protocol LevelTwoRequirements: Requirements, CODEGEN_LevelTwoRequirements {
    var explicitPassthrough: String { get }
    var modified: String { get }
    var recreated: String { get }
}


public class LevelTwoResource<I: LevelTwoRequirements>: Resource<I>,
                                                        LevelThreeRequirements{
    public var levelThreeResource: LevelThreeResource<LevelTwoResource> { LevelThreeResource(injecting: self) }
}

```

### Level Three
```swift
public protocol LevelThreeRequirements: Requirements, CODEGEN_LevelThreeRequirements {
    var explicitPassthrough: String { get }
    var modified: String { get }
    var recreated: String { get }
    var implicitPassthrough: String { get }
}


public class LevelThreeResource<I: LevelThreeRequirements>: Resource<I> {
}

```

## Usage 

```swift
let root = RootResource(injecting: NilResource())
let levelOne = root.levelOneResource
let levelTwo = levelOne.levelTwoResource
let levelThree = levelTwo.levelThreeResource

print(
    """
    _____ Root _____
    explicitPassthrough: <\(root.explicitPassthrough)>
    modified: <\(root.modified)>
    recreated: <\(root.recreated)>
    implicitPassthrough: <\(root.implicitPassthrough)>

    _____ Level One _____
    explicitPassthrough: <\(levelOne.explicitPassthrough)>
    modified: <\(levelOne.modified)>
    recreated: <\(levelOne.recreated)>
    implicitPassthrough (not available): <N/A>

    _____ Level Two _____
    explicitPassthrough: <\(levelTwo.explicitPassthrough)>
    modified: <\(levelTwo.modified)>
    recreated: <\(levelTwo.recreated)>
    implicitPassthrough (made available to satisfy LevelThreeRequirements): <\(levelThree.implicitPassthrough)>

    _____ Level Three _____
    explicitPassthrough: <\(levelThree.explicitPassthrough)>
    modified: <\(levelThree.modified)>
    recreated: <\(levelThree.recreated)>
    implicitPassthrough: <\(levelThree.implicitPassthrough)>
    """
)
```

## Output

```
_____ Root _____
explicitPassthrough: <Root value passed through explicitly>
modified: <Root value to be modified>
recreated: <Root value to be recreated>
implicitPassthrough: <Root value passed implicitly>

_____ Level One _____
explicitPassthrough: <Root value passed through explicitly>
modified: <Value modified based on source: 'Root value to be modified'>
recreated: <Value recreated independent of original>
implicitPassthrough (not available): <N/A>

_____ Level Two _____
explicitPassthrough: <Root value passed through explicitly>
modified: <Value modified based on source: 'Root value to be modified'>
recreated: <Value recreated independent of original>
implicitPassthrough (made available to satisfy LevelThreeRequirements): <Root value passed implicitly>

_____ Level Three _____
explicitPassthrough: <Root value passed through explicitly>
modified: <Value modified based on source: 'Root value to be modified'>
recreated: <Value recreated independent of original>
implicitPassthrough: <Root value passed implicitly>

```
