import Foundation

/// The types with DependencyKit can manage provision of.
protocol DIStartupTime { var startupTime: Date { get } }
protocol DICurrentTime { var currentTime: Date { get } }
protocol DIAppName { var appName: String { get } }
protocol DISessionToken { var sessionToken: String? { get } }
protocol DIBoolIndicator { var boolIndicator: Bool { get } }
protocol DIMessage { var messageToCarryThrough: String { get } }
