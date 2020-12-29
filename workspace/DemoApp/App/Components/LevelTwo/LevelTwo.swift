import DependencyKit
import Foundation

// In this example a hypothetical ViewController at Level Two specifies this dependency.
// As this LevelTwoDependency conforms to it, conforming Components can support the ViewController.
protocol LevelTwoViewControllerDependencies:
    BoolIndicatorDependency
    {}

// In this example a hypothetical ViewModel at Level Two specifies this dependency.
// As this LevelTwoDependency conforms to it, conforming Components can support the ViewModel.
protocol LevelTwoViewModelDependencies:
    SessionTokenDependency,
    AppNameDependency
    {}

// LevelTwoDependency simply merges the dependencies already defined for the ViewModel and ViewController at this level.
protocol LevelTwoRequirements:
    _Generated, _LevelTwoRequirements,
    LevelTwoViewModelDependencies,
    LevelTwoViewControllerDependencies
{}

// The Component defines its requirement as a LevelTwoDependency.
// It needs no additional implementation to satisfy its downstream dependencies (LevelThreeDependency).
class LevelTwoResource<T: LevelTwoRequirements>: Resource<T>,
                                                LevelTwoViewModelDependencies, // TODO: remove this confusing example.
                                                LevelThreeRequirements {
    // Let's flip this false for funsies.
    let boolIndicator = false
    
    // MARK: subcomponents
    var levelThreeComponent: LevelThreeResource<LevelTwoResource> { LevelThreeResource(dependency: self) }
}
