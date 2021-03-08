import DependencyKit
import Foundation

public protocol NetworkClientRequirements: Requirements {
    var networkMonitor: NetworkMonitorInterface? { get }
}

public class NetworkClientResource<I: NetworkClientRequirements>: Resource<I> {
    public func buildClient() -> NetworkClient {
        if let monitor = injected.networkMonitor {
            return MonitoredNetworkClient(monitor: monitor)
        } else {
            return StandardNetworkClient()
        }
    }
}
