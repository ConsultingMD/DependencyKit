import DependencyKit
import Foundation

public protocol LevelTwoRequirements: Requirements {
    var explicitPassthrough: String { get }
    var modified: String { get }
    var recreated: String { get }
//    var implicitPassthrough: String { get }
}


public class LevelTwoResource<I: LevelTwoRequirements>: Resource<I> {
}
