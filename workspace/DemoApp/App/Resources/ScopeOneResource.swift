import DependencyKit
import NetworkClient
import Foundation

protocol ScopeOneRequirements: Requirements, GENERATED_IMPLICIT_ScopeOneRequirements {
    var explicit: String { get }
    var modified: String { get }
}

class ScopeOneResource<I: ScopeOneRequirements>: Resource<I>,
                                                 NetworkClientRequirements,
                                                 ScopeTwoRequirements {

    // Recreate a resource using the ancestor-scope value.
    // Must be lazy to access `injected`.
    // Must access injected as this var overrides `modified` passed from injected.
    lazy var modified = "s1-modified-\(injected.modified)"

    // Created a resource that isn't present in an ancestor scope.
    let createdLater = "s1-createdLater"

    // Fully recreate a resource present in the ancestor scope.
    let recreated = "s1-recreated"

    func buildScopeTwo() -> ScopeTwoResource<ScopeOneResource> {
        ScopeTwoResource(injecting: self)
    }

    // MARK: NetworkClient Module

    // Network Monitor conforming to a value in another module.
    let networkMonitor: NetworkMonitorInterface? = TimingNetworkMonitor()

    // Build resource from external module.
    func buildNetworkClientResource() -> NetworkClientResource<ScopeOneResource> {
        NetworkClientResource(injecting: self)
    }
}
