/// This file contains (theoretically) autogenerated code. It should not be edited manually.
import DependencyKit
import Foundation

extension DependencyProvider where T: DINetworkMonitorInterface {
    var networkMonitor: NetworkMonitorInterface? { dependency.networkMonitor }
}

public protocol DependencyFill {
    typealias NetworkClient = Empty
}
