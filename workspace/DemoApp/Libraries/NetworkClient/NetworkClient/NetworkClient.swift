import Combine
import Foundation

public protocol NetworkClient {
    func get(url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}


public struct MonitoredNetworkClient: NetworkClient {
    
    private let monitor: NetworkMonitorInterface
    
    public init(monitor: NetworkMonitorInterface) {
        self.monitor = monitor
    }
    
    public func get(url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        let event = UUID()
        monitor.requested(url: url, event: event)
        let publisher = URLSession.shared
            .dataTaskPublisher(for: url)
            .handleEvents { _ in
                monitor.requested(url: url, event: event)
            } receiveOutput: { _ in
                monitor.resolved(url: url, event: event)
            }

        return publisher.eraseToAnyPublisher()
    }

}


public struct StandardNetworkClient: NetworkClient {
    public func get(url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        URLSession.shared
            .dataTaskPublisher(for: url)
            .eraseToAnyPublisher()
    }
}
