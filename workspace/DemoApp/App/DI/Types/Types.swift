import DependencyKit
import Foundation
import NetworkClient

/// The types with DependencyKit can manage provision of.
protocol StartupTimeDependency: Dependency { var startupTime: Date { get } }
protocol CurrentTimeDependency: Dependency { var currentTime: Date { get } }
protocol AppNameDependency: Dependency { var appName: String { get } }
protocol SessionTokenDependency: Dependency { var sessionToken: String? { get } }
protocol BoolIndicatorDependency: Dependency { var boolIndicator: Bool { get } }
protocol MessageDependency: Dependency { var messageToCarryThrough: String { get } }
protocol NetworkClientDependency: Dependency { var networkClient: NetworkClient { get } }
