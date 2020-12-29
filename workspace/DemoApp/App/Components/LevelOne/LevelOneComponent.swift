import DependencyKit
import Foundation

// Definition of what is required to instantiate the LevelOneComponent.
// DIName and DIRootName refer to types specified in Types.swift
// When initially manually written, this dependency conformed to Dependency.
// Code generation switches conformances (to Dependency.LevelOneDependency) once the level's 'Fill' is created.
protocol LevelOneDependency: DependencyFill.LevelOne,
    DISessionToken,
    DIAppName,
    DICurrentTime,
    DINetworkClient
{}

// The LevelOnceComponent collects values from its dependencies, allows the Application code to override them,
// supplement them, or created derived values from them.
// LevelOneComponent provides the required fields for to LevelTwo, and so conforms to LevelTwoDependency.
class LevelOneComponent<T: LevelOneDependency>: Component<T>,
                                                LevelTwoDependency {
    let boolIndicator = true // initial value
    let sessionToken: String? = UUID().uuidString
    
    // MARK: subcomponents
    var levelTwoComponent: LevelTwoComponent<LevelOneComponent> { LevelTwoComponent(dependency: self) }
}
