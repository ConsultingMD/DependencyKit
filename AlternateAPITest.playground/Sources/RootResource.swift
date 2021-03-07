import Foundation

public class RootResource<I: NilRequirement>: Resource<I>, LevelOneRequirements {
    public let appName = "DependencyKit"
    public var levelOneResource: LevelOneResource<RootResource> { LevelOneResource(injecting: self) }
}
