import DependencyKit
import Foundation
import NetworkClient

public class RootResource<I: NilRequirements>: Resource<I>, LevelOneRequirements {
    public let explicitPassthrough = "Root value passed through explicitly"
    public let implicitPassthrough = "Root value passed implicitly"
    public let modified = "Root value to be modified"
    public let recreated = "Root value to be recreated"
    public var levelOneResource: LevelOneResource<RootResource> { LevelOneResource(injecting: self) }

//    var networkComponent: NetworkClientResource<RootResource> { NetworkClientResource(injecting: self) }
}

