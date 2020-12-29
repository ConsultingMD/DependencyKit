import DependencyKit
import Foundation

public protocol NetworkClientDependency: DependencyFill.NetworkClient,
                                         DINetworkMonitorInterface {}

public class NetworkClientComponent<T: NetworkClientDependency>: Component<T> {
    public func buildClient() -> NetworkClient {
        if let monitor = dependency.networkMonitor {
            return MonitoredNetworkClient(monitor: monitor)
        } else {
            return StandardNetworkClient()
        }
    }
}
