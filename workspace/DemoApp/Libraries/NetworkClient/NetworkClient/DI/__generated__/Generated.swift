import DependencyKit
import Foundation

extension ResourceType where I: NetworkClientRequirements {
    var networkMonitor: NetworkMonitorInterface? { injected.networkMonitor }
}
