import DependencyKit
import Foundation


protocol LevelOneRequirements:
    _Generated, _LevelOneRequirements,
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
