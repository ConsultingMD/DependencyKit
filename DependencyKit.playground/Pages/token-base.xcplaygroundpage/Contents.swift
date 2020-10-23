//: [Previous](@previous)

import Foundation

// MARK: Framework
protocol EmptyDependency {}
class EmptyComponent: EmptyDependency {}

protocol DependencyContainer {
    associatedtype DependencyType
    var dependency: DependencyType { get }
}

class Component<T>: DependencyContainer {
    typealias DependencyType = T
    let dependency: T
    init(dependency: T) {
        self.dependency = dependency
    }
}

// MARK: Mocks
enum Mood {
    case happy
}

// MARK: Types
protocol DIStartupTime { var startupTime: Date { get } }
protocol DIName { var name: String { get } }
protocol DIMood { var mood: Mood { get } }

// MARK: - Client Code

// MARK: Codegen

extension DependencyContainer where DependencyType: DIName {
    var name: String { dependency.name }
}
extension DependencyContainer where DependencyType: DIStartupTime {
    var startupTime: Date { dependency.startupTime }
}
extension DependencyContainer where DependencyType: DIMood {
    var mood: Mood { dependency.mood }
}

// MARK: Definitions

protocol ChildDependency:
    DIName
{}

protocol LevelTwoDependency:
    DIName,
    DIMood
{}

protocol LevelThreeDependency:
    DIStartupTime,
    DIName
{}

class RootComponent: Component<EmptyDependency>,
                     ChildDependency {
    let name = "Root"
}

class ChildComponent<T: ChildDependency>: Component<T> {

}

// MARK: Usage

let root = RootComponent(dependency: EmptyComponent())
let child = ChildComponent(dependency: root)
print(child.name)

//: [Next](@next)
