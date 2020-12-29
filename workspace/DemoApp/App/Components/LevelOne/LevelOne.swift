import DependencyKit
import Foundation

protocol LevelOneRequirements: GeneratedRequirements_LevelOne,
    SessionTokenDependency,
    AppNameDependency,
    CurrentTimeDependency,
    NetworkClientDependency
{}


class LevelOneResource<T: LevelOneRequirements>: Resource<T>,
                                                LevelTwoRequirements {
    let boolIndicator = true // initial value
    let sessionToken: String? = UUID().uuidString
    
    // MARK: subcomponents
    var levelTwoComponent: LevelTwoResource<LevelOneResource> { LevelTwoResource(dependency: self) }
}
