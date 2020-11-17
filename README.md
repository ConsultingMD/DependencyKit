# DependencyKit

DependencyKit is an attempt to make a fully typesafe, lightweight, dependency injection framework for Swift.

## Status
This is a proof of concept intended to show:
* [How the fundamental framework code would function](https://github.com/adam-zethraeus/DependencyKit/blob/mainline/Framework/DependencyKit.swift)
* [What the code generation would product to hook up depenencies](https://github.com/adam-zethraeus/DependencyKit/blob/mainline/DemoApplication/GeneratedCode/CodeGeneration.swift)
* [A possible API for defining auto-injectable types](https://github.com/adam-zethraeus/DependencyKit/blob/mainline/DemoApplication/Types.swift)
* [How to hook it together](https://github.com/adam-zethraeus/DependencyKit/tree/mainline/DemoApplication) to provide:
    * Types passed from parent -> child component.
    * The ability to override, merge, and use use types in a child component.
    * Types passed from ancestor to indirect-child component without requiring manual piping.
    * And that it can be pulled together in a compile-safe manner.


## Further Work
This project has two primary directions of work:
1. **Productionisation**
    * Code generation implementation & tooling integration. (The current 'generated code' is all hand written.)
    * Runtime dependency integration (i.e. The ability to instantiate a Component at runtime with a value known only at runtime. Auth tokens are a good usage example.)
    * Intermodule API testing. (What needs to be public? What needs to be imported? Should code generation be in module or centralized to DependencyKit?)
    * Thread safety. (No attempt has been made to develop a threading story. Ideally off-main instantiation should be safe for a subset of well defined cases.)
    * API considerations & niceties. (Is the current single use [Types](https://github.com/adam-zethraeus/DependencyKit/blob/mainline/DemoApplication/Types.swift) config desirable or should passthroughs be generated for larger sets of grouped fields? Should property wrappers, or even codegen, be used minimize passthrough code?)
2. **Fundamentals investigation**
    * Generic/Protocol usage improvements.
    * Codegen minimization / simplification. (i.e. What compromises or improvements could be made to decrease the code generation burden?)
    * Performance Profiling. (How does compile time and usage compare to other frameworks? Across what project sizes?)
Input as issues or PRs is more than welcome.

## Demo usage

Compare the following output with [main.swift](https://github.com/adam-zethraeus/DependencyKit/blob/mainline/main.swift).

```
❯ swiftc Framework/*.swift DemoApplication/*.swift DemoApplication/GeneratedCode/*.swift main.swift
❯ ./main
    The RootComponent sets up:
        - root.appName: String                  = DependencyKit
        - root.sessionToken: String?            = nil
        - root.startupTime: Date                = 1970-01-01 00:00:00 +0000
        - root.currentTime: Date                = 2020-11-13 09:13:56 +0000
        - root.messageToCarryThrough: Date      = You shouldn't have to make intermediate references to this.

    ==========================================================

    The LevelOneComponent sets up:
        - levelOne.boolIndicator: Bool           = true

    It also resets:
        - levelOne.sessionToken: String?         = Optional("68972A06-B65B-46A3-8CD0-105EF6F4F0F3")

    ==========================================================

    The LevelTwoComponent declares some dependencies:
        protocol LevelTwoViewControllerDependencies: DIBoolIndicator {}
        protocol LevelTwoViewModelDependencies: DISessionToken, DIAppName {}

    It groups these dependencies:
        protocol LevelTwoDependency: Dependency.LevelTwoDependency,
                                     LevelTwoViewModelDependencies,
                                     LevelTwoViewControllerDependencies
                                     {}

    It resets one dependency:
        - levelTwo.boolIndicator: Bool          = false

    And it directly exposes all of its declared dependencies:
        - levelTwo.boolIndicator: Bool          = false
        - levelTwo.sessionToken: String?        = Optional("68972A06-B65B-46A3-8CD0-105EF6F4F0F3")
        - levelTwo.appName: String              = DependencyKit

    The *component* also exposes its implicit (passthrough) dependencies:
        - levelTwo.startupTime: Date            = 1970-01-01 00:00:00 +0000

    However, when treated as one of its declared *dependencies*, they behave as one would expect:
        - (levelTwo as LevelTwoViewModelDependencies).appName       = DependencyKit
        - (levelTwo as LevelTwoViewModelDependencies).boolIndicator = <COMPILER ERROR>
        - (levelTwo as LevelTwoViewModelDependencies).startupTime   = <COMPILER ERROR>

    ==========================================================

    The LevelThreeComponent adds a method which exposes the DIMessage, and overrides the DIBoolIndicator:
        - levelThree.showMessageFromRoot()      // You shouldn't have to make intermediate references to this.
        - levelThree.boolIndicator              = false

    ==========================================================

    The second instance of the LevelOneComponent,levelOneAgain, runs again. As such it overrides DIBoolIndicator and DISessionToken:
        - levelOneAgain.boolIndicator           = true
        - levelOneAgain.sessionToken: String?   = Optional("7106FDE9-E6E7-4643-AC0E-764F99A19567")
```

## Related Projects

DependencyKit is inspired by Uber's excellent [Needle](https://github.com/uber/needle) framework, and aims to extend its core aim of first class type safety by avoiding a reliance on an unsafe internal runtime.

[Weaver](https://github.com/scribd/Weaver) is another iOS DI framework which prioritizes type safety.

