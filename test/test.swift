//: [Previous](@previous)

import Foundation

// MARK: Framework
protocol Dependency {}
protocol EmptyDependency: Dependency {}
class EmptyComponent: EmptyDependency {}

class Component<T>: Dependency {
    let dependency: T
    init(dependency: T) {
        self.dependency = dependency
    }
}

// MARK: Types
enum Mood {
    case happy
}

protocol DIStartupTime { var startupTime: Date { get } }
protocol DIName { var name: String { get } }
protocol DIMood { var mood: Mood { get } }


// MARK: Use
class RootComponent: Component<EmptyDependency>,
                     LevelOneDependency {
    let name = "Root"
    let startupTime = Date(timeIntervalSince1970: 0)
}

protocol LevelOneDependency: Dependency,
    DIName
{}
class LevelOneComponent<T: LevelOneDependency>: Component<T>,
                                                LevelTwoDependency {

}

protocol LevelTwoDependency: Dependency,
    DIName,
    DIMood,
    DIStartupTime
{}
class LevelTwoComponent<T: LevelTwoDependency>: Component<T>,
                                                LevelThreeDependency{

}

protocol LevelThreeDependency: Dependency,
//    DIStartupTime,
    DIName
{}
class LevelThreeComponent<T: LevelThreeDependency>: Component<T> {

}

// MARK: Invocation
let empty = EmptyComponent()
let root = RootComponent(dependency: empty)
let levelOne = LevelOneComponent(dependency: root)
let levelTwo = LevelTwoComponent(dependency: levelOne)

//: [Next](@next)
