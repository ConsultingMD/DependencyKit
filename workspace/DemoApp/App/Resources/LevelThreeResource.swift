import DependencyKit
import Foundation

public protocol LevelThreeRequirements: Requirements, CODEGEN_LevelThreeRequirements {
    var explicitPassthrough: String { get }
    var modified: String { get }
    var recreated: String { get }
    var implicitPassthrough: String { get }
}


public class LevelThreeResource<I: LevelThreeRequirements>: Resource<I> {
}
