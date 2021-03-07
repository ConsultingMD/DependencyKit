import Foundation

public protocol LevelOneRequirements: Requirements {
    var appName: String { get }
}

public class LevelOneResource<I: LevelOneRequirements>: Resource<I>,
                                                        LevelTwoRequirements {
    public var levelTwoResource: LevelTwoResource<LevelOneResource> { LevelTwoResource(injecting: self) }
}
