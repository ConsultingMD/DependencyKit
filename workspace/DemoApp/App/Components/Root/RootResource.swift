import DependencyKit
import Foundation
import NetworkClient

// The entrypoint to the Demo Application.
// This Component has no requirements (annotated as EmptyDependency).
// It explicitly satisfies Level One's requirements (LevelOneDependency) providing fields conforming to DIName, and DIRootName.
// It also has other properties which might be used at the root level and/or satisfy requirements beyond Level One.
class RootResource<T: NilRequirement>: Resource<T>,
                     NetworkClientRequirements,
                     LevelOneRequirements {
    
    // MARK: dependency provisions
    let appName = "DependencyKit"
    let sessionToken: String? = nil
    let startupTime = Date(timeIntervalSince1970: 0)
    let currentTime = Date()
    let messageToCarryThrough = "You shouldn't have to make intermediate references to this."
    let networkMonitor: NetworkMonitorInterface? = TimingNetworkMonitor()
    var networkClient: NetworkClient { networkComponent.buildClient() }
    
    // MARK: subcomponents
    var networkComponent: NetworkClientResource<RootResource> { NetworkClientResource(injecting: self) }
    var levelOneComponent: LevelOneResource<RootResource> { LevelOneResource(injecting: self) }
}
