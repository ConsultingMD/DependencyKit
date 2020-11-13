import Foundation

// In this example a hypothetical ViewController at Level Two specifies this dependency.
// As this LevelTwoDependency conforms to it, conforming Components can support the ViewController.
protocol LevelTwoViewControllerDependencies:
    DIBoolIndicator
    {}

// In this example a hypothetical ViewModel at Level Two specifies this dependency.
// As this LevelTwoDependency conforms to it, conforming Components can support the ViewModel.
protocol LevelTwoViewModelDependencies:
    DISessionToken,
    DIAppName
    {}

// LevelTwoDependency simply merges the dependencies already defined for the ViewModel and ViewController at this level.
protocol LevelTwoDependency: DependencyBase.LevelTwo,
                             LevelTwoViewModelDependencies,
                             LevelTwoViewControllerDependencies
                             {}

// The Component defines its requirement as a LevelTwoDependency.
// It needs no additional implementation to satisfy its downstream dependencies (LevelThreeDependency).
class LevelTwoComponent<T: LevelTwoDependency>: Component<T>,
                                                LevelTwoViewModelDependencies, // TODO: remove this confusing example.
                                                LevelThreeDependency {
    // Let's flip this false for funsies.
    let boolIndicator = false
}
