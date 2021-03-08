import DependencyKit
import Foundation

public protocol LevelTwoRequirements: Requirements, CODEGEN_LevelTwoRequirements {
    var explicitPassthrough: String { get }
    var modified: String { get }
    var recreated: String { get }
}


public class LevelTwoResource<I: LevelTwoRequirements>: Resource<I>,
                                                        LevelThreeRequirements{
    public var levelThreeResource: LevelThreeResource<LevelTwoResource> { LevelThreeResource(injecting: self) }
}
