import DependencyKit
import Foundation
import NetworkClient

/// The types with DependencyKit can manage provision of.
protocol DIStartupTime: Injected { var startupTime: Date { get } }
protocol DICurrentTime: Injected { var currentTime: Date { get } }
protocol DIAppName: Injected { var appName: String { get } }
protocol DISessionToken: Injected { var sessionToken: String? { get } }
protocol DIBoolIndicator: Injected { var boolIndicator: Bool { get } }
protocol DIMessage: Injected { var messageToCarryThrough: String { get } }
protocol DINetworkClient: Injected { var networkClient: NetworkClient { get } }
