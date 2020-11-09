# DependencyKit

DependencyKit is an attempt to make a fully typesafe, lightweight, dependency injection framework for Swift.
DependencyKit is inspired by Uber's excellent [Needle](https://github.com/uber/needle) framework, and aims to extend its core aim of first class type safety by avoiding a reliance on an unsafe internal runtime.

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
1. Productionisation
    * Code generation implementation & tooling integration. (The current 'generated code' is all hand written.)
    * Runtime dependency integration (i.e. The ability to instantiate a Component at runtime with a value known only at runtime. Auth tokens are a good usage example.)
    * Shared vs. Factory fields. (State containers such as Publishers must be shared across accesses. Currently all fields are factories.)
    * Intermodule API testing. (What needs to be public? What needs to be imported? Should code generation be in module or centralized to DependencyKit?)
    * Thread safety. (No attempt has been made to devlop a threading story. Ideally off-main instantiation should be safe for a subset of well defined cases.)
    * API considerations & niceties. (Is the current [Types](https://github.com/adam-zethraeus/DependencyKit/blob/mainline/DemoApplication/Types.swift) configuration desirable? Should property wrappers, or even codegen, be used minimize passthrough code?)
2. Fundamentals investigation
    * Generic/Protocol usage improvements. (e.g. Is it possible to remove the DependencyBase.NEW_TO_GENERATE conformance requirement for new Dependencies?)
    * Codegen minimization / simplification. (i.e. What compromises or improvements could be made to decrease the code generation burden?)
    * Performance Profiling. (How does compile time and usage compare to other frameworks? Across what project sizes?)
    
Input as issues or PRs is more than welcome.

## Demo usage
```
❯ swiftc Framework/*.swift DemoApplication/*.swift DemoApplication/GeneratedCode/*.swift main.swift
❯ ./main
Root
Overriden value
Root
Could this be less verbose?
```
