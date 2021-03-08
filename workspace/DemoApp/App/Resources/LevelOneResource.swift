import DependencyKit
import Foundation

public protocol LevelOneRequirements: Requirements, CODEGEN_LevelOneRequirements {
    var explicitPassthrough: String { get }
    var modified: String { get }
}

public class LevelOneResource<I: LevelOneRequirements>: Resource<I>,
                                                        LevelTwoRequirements {
    public lazy var modified = "Value modified based on source: '\(injected.modified)'"
    public let recreated = "Value recreated independent of original"
    
    public var levelTwoResource: LevelTwoResource<LevelOneResource> { LevelTwoResource(injecting: self) }
}
