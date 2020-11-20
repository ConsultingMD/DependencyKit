import DependencyKit
import Foundation

// Level Three requires a 'FinalThoughts' type.
protocol LevelThreeDependency: Dependency.LevelThreeDependency,
    DIMessage
{}

// The Component defines a method on itself that isn't required by any downstream dependencies.
// The method has access to 'finalThoughts' which is defined only in RootComponent, and passed down through codegnenerated Fills.
class LevelThreeComponent<T: LevelThreeDependency>: Component<T>,
                                                    LevelOneDependency {

    func showMessageFromRoot() -> String {
        // We passed this from root without writing any explicit code.
        return dependency.messageToCarryThrough
    }

}
