//: [Previous](@previous)

import Foundation

// MARK: Framework
protocol Dependency {
    associatedtype T
    var dependency: T { get }
}
protocol EmptyDependency: Dependency {}
class EmptyComponent: EmptyDependency {
    lazy var dependency = self
}

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
protocol DIFinalThoughts { var finalThoughts: String { get } }


extension Dependency where T: DIRootName {
    var rootName: String { dependency.rootName }
}
extension Dependency where T: DIName {
    var name: String { dependency.name }
}
extension Dependency where T: DIStartupTime {
    var startupTime: Date { dependency.startupTime }
}
extension Dependency where T: DIMood {
    var mood: Mood { dependency.mood }
}
extension Dependency where T: DIFinalThoughts {
    var finalThoughts: String { dependency.finalThoughts }
}


// MARK: Use

// MARK: Root
class RootComponent: Component<EmptyDependency>,
                     LevelOneDependency {
    let rootName = "Root"
    let name = "Root"
    let startupTime = Date(timeIntervalSince1970: 0)
    let finalThoughts = "This feels rather verbose."
}

extension RootComponent: LevelOneFill {}

// MARK: LevelOne

protocol LevelOneDependency: Dependency,
    DIName,
    DIRootName
{}
// TODO: can we factor this in anywhere?
typealias LevelOneFill = DIStartupTime & DIFinalThoughts

class LevelOneComponent<T: LevelOneDependency & LevelOneFill>: Component<T>,
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
    LevelOneFill
{}

// MARK: LevelTwo

protocol LevelTwoDependency: Dependency,
    DIName,
    DIRootName,
    DIMood,
    DIStartupTime
{}
typealias LevelTwoFill = DIFinalThoughts
class LevelTwoComponent<T: LevelTwoDependency & LevelTwoFill>: Component<T>,
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
extension LevelTwoComponent:
    LevelTwoFill
{}


// MARK: LevelThree

protocol LevelThreeDependency:
    DIFinalThoughts
{}

// MARK: Invocation
let empty = EmptyComponent()
let root = RootComponent(dependency: empty)
let levelOne = LevelOneComponent(dependency: root)
let levelTwo = LevelTwoComponent(dependency: levelOne)
levelOne.show()
levelTwo.show()

//: [Next](@next)
