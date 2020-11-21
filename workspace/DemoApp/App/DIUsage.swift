import Combine
import DependencyKit
import Foundation
import NetworkClient

class DIUsage {
    static let instance = DIUsage()
    var disposeBag = [AnyCancellable]()
    init() {}
    
    func multiModuleTest() -> [String] {
        let root = RootComponent(dependency: EmptyComponent())
        root.networkClient.get(url: URL(string: "https://google.com")!)
            .sink { _ in }
                receiveValue: { _ in }
            .store(in: &disposeBag)

        return ["prints to console"]
    }
    
    func diagnostic() -> [String] {
        var output: [String] = []
        // Instantiate a Root which requires no real dependency.
        let root = RootComponent(dependency: EmptyComponent())
        output.append(
            """
                The RootComponent sets up:
                    - root.appName: String                  = \(root.appName)
                    - root.sessionToken: String?            = \(root.sessionToken as Any)
                    - root.startupTime: Date                = \(root.startupTime)
                    - root.currentTime: Date                = \(root.currentTime)
                    - root.messageToCarryThrough: Date      = \(root.messageToCarryThrough)
            """)

        output.append(
            """

                ==========================================================

            """)

        // LevelOne can only be instantiated with a component like root, which satisfies its dependencies.
        let levelOne = LevelOneComponent(dependency: root)
        output.append(
            """
                The LevelOneComponent sets up:
                    - levelOne.boolIndicator: Bool           = \(levelOne.boolIndicator)
                
                It also resets:
                    - levelOne.sessionToken: String?         = \(levelOne.sessionToken as Any)
            """)

        output.append(
            """
            
                ==========================================================

            """)

        // LevelTwo can only be instantiated with a component like LevelOne, which satisfies its dependencies.
        let levelTwo = LevelTwoComponent(dependency: levelOne)
        output.append(
            """
                The LevelTwoComponent declares some dependencies:
                    protocol LevelTwoViewControllerDependencies: DIBoolIndicator {}
                    protocol LevelTwoViewModelDependencies: DISessionToken, DIAppName {}

                It groups these dependencies:
                    protocol LevelTwoDependency: Dependency.LevelTwoDependency,
                                                 LevelTwoViewModelDependencies,
                                                 LevelTwoViewControllerDependencies
                                                 {}

                It resets one dependency:
                    - levelTwo.boolIndicator: Bool          = \(levelTwo.boolIndicator)

                And it directly exposes all of its declared dependencies:
                    - levelTwo.boolIndicator: Bool          = \(levelTwo.boolIndicator)
                    - levelTwo.sessionToken: String?        = \(levelTwo.sessionToken as Any)
                    - levelTwo.appName: String              = \(levelTwo.appName)

                The *component* also exposes its implicit (passthrough) dependencies:
                    - levelTwo.startupTime: Date            = \(levelTwo.startupTime)

                However, when treated as one of its declared *dependencies*, they behave as one would expect:
                    - (levelTwo as LevelTwoViewModelDependencies).appName       = \( (levelTwo as LevelTwoViewModelDependencies).appName )
                    - (levelTwo as LevelTwoViewModelDependencies).boolIndicator = <COMPILER ERROR>
                    - (levelTwo as LevelTwoViewModelDependencies).startupTime   = <COMPILER ERROR>
            """)

        output.append(
            """
            
                ==========================================================

            """)

        let levelThree = LevelThreeComponent(dependency: levelTwo)
        output.append(
            """
                The LevelThreeComponent adds a method which exposes the DIMessage, and overrides the DIBoolIndicator:
                    - levelThree.showMessageFromRoot()      // \(levelThree.showMessageFromRoot())
                    - levelThree.boolIndicator              = \(levelThree.boolIndicator)
            """)

        output.append(
            """
            
                ==========================================================

            """)

        // Since LevelThree collects all of the dependencies in its construction chain, it can be used to create another instance of LevelOneComponent
        let levelOneAgain = LevelOneComponent(dependency: levelThree)
        output.append(
            """
                The second instance of the LevelOneComponent,levelOneAgain, runs again. As such it overrides DIBoolIndicator and DISessionToken:
                    - levelOneAgain.boolIndicator           = \(levelOneAgain.boolIndicator)
                    - levelOneAgain.sessionToken: String?   = \(levelOneAgain.sessionToken as Any)
            """)
        return output
    }
}
