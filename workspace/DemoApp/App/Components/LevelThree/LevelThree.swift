import DependencyKit
import Foundation

// Level Three requires a 'FinalThoughts' type.
protocol LevelThreeRequirements:
    _Generated, _LevelThreeRequirements,
    MessageDependency
{}

// The Component defines a method on itself that isn't required by any downstream dependencies.
// The method has access to 'finalThoughts' which is defined only in RootComponent, and passed down through codegnenerated Fills.
class LevelThreeResource<T: LevelThreeRequirements>: Resource<T>,
                                                    LevelOneRequirements {

    func showMessageFromRoot() -> String {
        // We passed this from root without writing any explicit code.
        return injected.messageToCarryThrough
    }

    // MARK: subcomponents
    var levelOneComponent: LevelOneResource<LevelThreeResource> { LevelOneResource(dependency: self) }
    
}
