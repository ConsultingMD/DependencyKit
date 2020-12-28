// Generated using Sourcery 1.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// MARK: Dependency extensions for Injected types
extension Dependency where T:DIAppName {
    var appName: String { dependency.appName }
}
extension Dependency where T:DIBoolIndicator {
    var boolIndicator: Bool { dependency.boolIndicator }
}
extension Dependency where T:DICurrentTime {
    var currentTime: Date { dependency.currentTime }
}
extension Dependency where T:DIMessage {
    var messageToCarryThrough: String { dependency.messageToCarryThrough }
}
extension Dependency where T:DINetworkClient {
    var networkClient: NetworkClient { dependency.networkClient }
}
extension Dependency where T:DISessionToken {
    var sessionToken: String? { dependency.sessionToken }
}
extension Dependency where T:DIStartupTime {
    var startupTime: Date { dependency.startupTime }
}
