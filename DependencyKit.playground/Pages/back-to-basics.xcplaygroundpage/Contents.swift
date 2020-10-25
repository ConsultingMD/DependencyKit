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
protocol DIRootName { var rootName: String { get } }
protocol DIMood { var mood: Mood { get } }


// MARK: Use

// MARK: Root
class RootComponent: Component<EmptyDependency>,
                     LevelOneDependency {
    let rootName = "Root"
    let name = "Root"
    let startupTime = Date(timeIntervalSince1970: 0)
}

extension RootComponent: LevelOneChildDependencies {}

// MARK: LevelOne

protocol LevelOneDependency: Dependency,
    DIName,
    DIRootName
{}
protocol LevelOneChildDependencies: Dependency,
                                    DIStartupTime {}

class LevelOneComponent<T: LevelOneDependency & LevelOneChildDependencies>: Component<T>,
                                                LevelTwoDependency {
    let mood = Mood.happy
    let name = "NOT ROOT"

    func show() {
        print(
            """
            owned
                mood: \(mood)
            override:
                name: \(dependency.name)
            direct:
                rootName: \(dependency.rootName)
            indirect:
                startupTime: \(dependency.startupTime)

            """)
    }
}

extension LevelOneComponent:
    DIStartupTime,
    DIRootName
{
    var startupTime: Date { dependency.startupTime }
    var rootName: String { dependency.rootName}
}

// MARK: LevelTwo

protocol LevelTwoDependency: Dependency,
    DIName,
    DIRootName,
    DIMood,
    DIStartupTime
{}
class LevelTwoComponent<T: LevelTwoDependency>: Component<T>,
                                                LevelThreeDependency{
    func show() {
        print(
            """
            direct:
                name: \(dependency.name)
                mood: \(dependency.mood)
                startupTime: \(dependency.startupTime)
                rootName: \(dependency.rootName)

            """)
    }
}

// MARK: LevelThree

protocol LevelThreeDependency {}

// MARK: Invocation
let empty = EmptyComponent()
let root = RootComponent(dependency: empty)
let levelOne = LevelOneComponent(dependency: root)
let levelTwo = LevelTwoComponent(dependency: levelOne)
levelOne.show()
levelTwo.show()

//: [Next](@next)
