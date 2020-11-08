# DependencyKit

DependencyKit is an attempt to make a typesafe and usable, lightweight, dependency injection framework for Swift.

## Status
This is just a proof of concept. It's intended to show:
* [How the fundamental framework code would function](https://github.com/adam-zethraeus/DependencyKit/blob/mainline/Framework/DependencyKit.swift)
* [What the code generation would product to hook up depenencies](https://github.com/adam-zethraeus/DependencyKit/blob/mainline/DemoApplication/GeneratedCode/CodeGeneration.swift)
* [A possible API for defining auto-injectable types](https://github.com/adam-zethraeus/DependencyKit/blob/mainline/DemoApplication/Types.swift)
* [How to hook it together](https://github.com/adam-zethraeus/DependencyKit/tree/mainline/DemoApplication) to provide:
    * Types passed from parent -> child component.
    * The ability to override, merge, and use use types in a child component.
    * Types passed from ancestor to indirect-child component without requiring manual piping.
    * And that it can be pulled together in a compile-safe manner.

This project doesn't implement the code generation required. It also doesn't support dependencies set through runtime interaction... or many other necessary features.

## Demo usage
```
❯ swiftc Framework/*.swift DemoApplication/*.swift DemoApplication/GeneratedCode/*.swift main.swift
❯ ./main
Root
Overriden value
Root
Could this be less verbose?
```
