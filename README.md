![Icon](https://raw.githubusercontent.com/adam-zethraeus/DependencyKit/main/icon.svg)
# DependencyKit

DependencyKit is a typesafe codegenerated dependency injection framework for Swift.

## Requirement / Resource Setup

### Root
```swift
public class RootResource<I: NilRequirements>: Resource<I>, LevelOneRequirements {
    
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
