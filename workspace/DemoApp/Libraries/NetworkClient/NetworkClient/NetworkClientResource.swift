import DependencyKit
import Foundation

public protocol NetworkClientRequirements:
    Requirements, NetworkClientRequirements_CODEGEN,
    NetworkMonitorInterfaceDependency {}

public class NetworkClientResource<I: NetworkClientRequirements>: Resource<I> {
    public func buildClient() -> NetworkClient {
        if let monitor = injected.networkMonitor {
            return MonitoredNetworkClient(monitor: monitor)
        } else {
            return StandardNetworkClient()
        }
    }
}
