import DependencyKit
import Foundation

public protocol NetworkClientRequirements: GeneratedRequirements_NetworkClient,
                                         NetworkMonitorInterfaceDependency {}

public class NetworkClientResource<T: NetworkClientRequirements>: Resource<T> {
    public func buildClient() -> NetworkClient {
        if let monitor = injected.networkMonitor {
            return MonitoredNetworkClient(monitor: monitor)
        } else {
            return StandardNetworkClient()
        }
    }
}
