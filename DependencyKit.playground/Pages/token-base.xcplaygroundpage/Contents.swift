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

// MARK: Codegen, Type Tokens
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

// MARK: Class Declarations
class RootComponent: Component<EmptyDependency>,
                     ChildDependency {
    let name = "Root"
    let startupTime = Date(timeIntervalSince1970: 0)
}

class ChildComponent<T: ChildDependency>: Component<T>,
                                          LevelTwoDependency {
    let mood: Mood = .happy
}

class LevelTwoComponent<T: LevelTwoDependency>: Component<T>,
                                                LevelThreeDependency {
    let name = "I'm 'Level Two', actually."
}

class LevelThreeComponent<T: LevelThreeDependency>: Component<T> {
}

// MARK: Codegen, type extension
// TODO: ... with extensions
extension RootComponent: DIStartupTime {}

extension ChildComponent: DIStartupTime where T: EmptyDependency {
    var startupTime: Date { Date() }
}
extension LevelTwoDependency {
    // SOMEHOW, we need to get a value into the dependency
}
extension LevelTwoComponent: DIStartupTime where LevelTwoComponent.DependencyType: LevelTwoDependency {
    var startupTime: Date { dependency.startupTime }
}

// MARK: Usage

let root = RootComponent(dependency: EmptyComponent())
let child = ChildComponent(dependency: root)
let levelTwo = LevelTwoComponent(dependency: child)
let levelThree = LevelThreeComponent(dependency: levelTwo)

print(child.name)
print(levelTwo.name)
print(levelTwo.mood)
print(levelThree.startupTime)

//: [Next](@next)


//extension ChildComponent where T == RootComponent {
//    var startupTime: Date { dependency.startupTime }
//}

//extension LevelTwoComponent where T == ChildComponent<RootComponent> {
//    var startupTime: Date { dependency.startupTime }
//}
