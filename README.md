![Icon](https://raw.githubusercontent.com/adam-zethraeus/DependencyKit/main/icon.svg)
# DependencyKit

DependencyKit is a typesafe codegenerated dependency injection framework for Swift.



## Philosophy

DependencyKit has three tenants:

1. Stay typesafe.
    
    *All* code is typechecked by the compiler and can not crash at runtime.<sup id="a1">[1](#f1)</sup>
    Many Swift dependency injection setups either require you to manage potentially crashy runtime behavior or to trust the framework developers to do so for you.
    
    The Swift compiler has an advanced typesystem written by smart people. We should use it.

2. Don't get fancy.
    
    The code you write with DependencyKit is simple.
    The framework and generated code are simple.
    
    You're the one shipping the code. You should be able to read it.

3. It's just Swift.
    
    Your code you write with DependencyKit is idiomatic Swift.

DependencyKit also aims to have a low binary-size footprint and to be fast at code-generation-time, compile-time, and runtime—but not at the expense of the three tenants.

## Nomenclature & Conceptual Model 

DependencyKit's model is of 'Requirements' and 'Resources'. 

### Requirements
**Requirements declare what you need**. They describe what's required to instantiate a section of your app.

An early stage of your app might designate that an id and session token for a logged in user pre-defined.
```swift
protocol LoggedInRequirements: Requirements {
    var sessionToken: String { get }
    var userId: String { get }
}
```

A later stage of your app might require data models representing things to show in its UI, a pre-configured network service, and a User model.
```swift
protocol ChatThreadListRequirements: Requirements {
    var chatThreadSource: AnyPublisher<[ChatThread], Error> { get }
    var messagingNetworkService: MessagingService { get }
    var currentUser: User { get }
}
```

### Resources
**Resources provide things to your app**. They are used to satisfy the Requirements your code has declared, and as a source for other contructs that your app needs at their stage.

Resources can only be created with their Requirements pre-satisfied. Their Requirements's properties are made available the `injected` property. 

Resources are also used to satisfy *other* Resource's DependencyKit Requirements—and indicate that they do so through protocol conformance.

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

Since DependencyKit code is *Simply Swift* a resource can just as easily satisfy any other non-DependencyKit protocol you have in your app.
```swift
extension LoggedInResource: LegacyUserInfo {}
```

```swift
// TODO: Finish 2017 migration to accept a plain User object.
protocol LegacyUserInfo {
    var currentUser: User { get }
}
```

**TL;DR:** `Requirements` define things your app needs. `Resources` satisfy these requirements.

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
