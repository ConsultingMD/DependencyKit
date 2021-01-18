import DependencyKit
import Foundation

/// The types with DependencyKit can manage provision of.
public protocol NetworkMonitorInterfaceDependency: Dependency { var networkMonitor: NetworkMonitorInterface? { get } }
