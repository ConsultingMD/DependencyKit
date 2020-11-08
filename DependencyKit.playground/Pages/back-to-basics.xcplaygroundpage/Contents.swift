//: [Previous](@previous)

import Foundation

// MARK: Framework
protocol Empty{}
protocol Dependency {
    associatedtype T
    var dependency: T { get }
}
protocol EmptyDependency: Dependency {}
class EmptyComponent: EmptyDependency {
    lazy var dependency = self
}
protocol DependencyBase {
    // This is a code generation hook.
    // Dependencies should initially conform to this.
    // Code generation will create a DependencyFill and corresponding DependencyBase extension type.
    // The user code conformance will then be swapped out.
    typealias NEW_TO_GENERATE = Dependency
}
class Component<T>: Dependency {
    let dependency: T
    init(dependency: T) {
        self.dependency = dependency
    }
}

// MARK: Types
protocol DIStartupTime { var startupTime: Date { get } }
protocol DIName { var name: String { get } }
protocol DIRootName { var rootName: String { get } }
protocol DIMood { var mood: Bool { get } }
protocol DIFinalThoughts { var finalThoughts: String { get } }


// MARK: - AUTOGEN CODE
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
    var mood: Bool { dependency.mood }
}
extension Dependency where T: DIFinalThoughts {
    var finalThoughts: String { dependency.finalThoughts }
}

protocol DependencyFill {
    typealias Root = Empty & DIStartupTime & DIFinalThoughts
    typealias LevelOne = Empty & DIStartupTime & DIFinalThoughts
    typealias LevelTwo = Empty & DIFinalThoughts
    typealias LevelThree = Empty
}

extension DependencyBase {
    typealias Root = Dependency & DependencyFill.Root
    typealias LevelOne = Dependency & DependencyFill.LevelOne
    typealias LevelTwo = Dependency & DependencyFill.LevelTwo
    typealias LevelThree = Dependency & DependencyFill.LevelThree
}

extension RootComponent: DependencyFill.Root {}
extension LevelOneComponent: DependencyFill.LevelOne {}
extension LevelTwoComponent: DependencyFill.LevelTwo {}
extension LevelThreeComponent: DependencyFill.LevelThree {}

// MARRK: - Consumer's manual code

// MARK: Root
class RootComponent: Component<EmptyDependency>,
                     LevelOneDependency {
    let rootName = "Root"
    let name = "Root"
    let startupTime = Date(timeIntervalSince1970: 0)
    let finalThoughts = "This feels rather verbose."
}


// MARK: LevelOne
protocol LevelOneDependency: DependencyBase.LevelOne,
    DIName,
    DIRootName
{}

class LevelOneComponent<T: LevelOneDependency>: Component<T>,
                                                LevelTwoDependency {
    let mood = true // initial value
    let name = "Overriden value"
}

// MARK: LevelTwo
protocol LevelTwoViewControllerDependencies:
    DIMood,
    DIStartupTime
{}
protocol LevelTwoViewModelDependencies:
    DIName,
    DIRootName,
    DIMood
{}
protocol LevelTwoDependency: DependencyBase.LevelTwo,
                             LevelTwoViewModelDependencies,
                             LevelTwoViewControllerDependencies
{}
class LevelTwoComponent<T: LevelTwoDependency>: Component<T>,
                                                LevelTwoViewModelDependencies,
                                                LevelThreeDependency {
    // My dependencies are exposed without further action
}


// MARK: LevelThree
protocol LevelThreeDependency: DependencyBase.LevelThree,
    DIFinalThoughts
{}
class LevelThreeComponent<T: LevelThreeDependency>: Component<T> {
    func show() {
        // carried from root
        print(dependency.finalThoughts)
    }

}

// MARK: Invocation
let empty = EmptyComponent()
let root = RootComponent(dependency: empty)
let levelOne = LevelOneComponent(dependency: root)
let levelTwo = LevelTwoComponent(dependency: levelOne)
let levelTwoDepPassedToConsumerAtThisLevel: LevelTwoViewModelDependencies = levelTwo
print(levelTwoDepPassedToConsumerAtThisLevel.rootName)
let levelThree = LevelThreeComponent(dependency: levelTwo)
levelThree.show()

//: [Next](@next)
