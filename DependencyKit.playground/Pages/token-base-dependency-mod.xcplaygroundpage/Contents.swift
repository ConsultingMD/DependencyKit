//: [Previous](@previous)

import Foundation

// MARK: Framework
protocol EmptyDependency {}
class EmptyComponent: EmptyDependency {}

protocol DependencyContainer {
    associatedtype T
    var dependency: T { get }
}

class Component<T>: DependencyContainer {
    typealias T = T
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
extension DependencyContainer where T: DIName {
    var name: String { dependency.name }
}
extension DependencyContainer where T: DIStartupTime {
    var startupTime: Date { dependency.startupTime }
}
extension DependencyContainer where T: DIMood {
    var mood: Mood { dependency.mood }
}

// MARK: Definitions

protocol ChildDependency: DependencyContainer,
    DIName
{}

protocol LevelTwoDependency: DependencyContainer,
    DIName,
    DIMood
{}

protocol LevelThreeDependency: DependencyContainer,
//    DIStartupTime,
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

//// That this works to extend level 2 to meet LevelThreeDependency, suggests this could be doable
//extension LevelTwoComponent: DIStartupTime where T: LevelTwoDependency {
//    var startupTime: Date { Date() }
//}

//// The following two extensions are sufficient to make LevelTwoComponent conform to LevelThreeDependency
//extension LevelTwoDependency {
//    var startupTime: Date { Date() }
//}
//extension LevelTwoComponent: DIStartupTime where T: LevelTwoDependency {
//    var startupTime: Date { dependency.startupTime }
//}

//extension ChildDependency where T == RootComponent {
//    var startupTime: Date { dependency.startupTime }
//}
//
//extension LevelTwoDependency where T: ChildDependency, T.T: RootComponent {
//    var startupTime: Date { dependency.startupTime }
//}
//extension LevelTwoComponent: DIStartupTime where T: LevelTwoDependency, T.T: ChildDependency, T.T.T: RootComponent {
//    var startupTime: Date { dependency.startupTime }
//}
//
//extension RootComponent: DIStartupTime {}
//extension ChildComponent: DIStartupTime where T: DIStartupTime {}
//extension LevelTwoComponent: DIStartupTime where T: DIStartupTime {}


// MARK: Usage

let root = RootComponent(dependency: EmptyComponent())
let child = ChildComponent(dependency: root)
let levelTwo = LevelTwoComponent(dependency: child)
let levelThree = LevelThreeComponent(dependency: levelTwo)

print(child.name)
print(levelTwo.name)
print(levelTwo.mood)
//print(levelThree.startupTime)

//: [Next](@next)

