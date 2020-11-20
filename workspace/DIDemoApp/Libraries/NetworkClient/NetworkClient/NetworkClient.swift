//
//  NetworkClient.swift
//  NetworkClient
//
//  Created by az on 2020-11-18.
//

import Combine
import Foundation

public protocol NetworkClient {
    func get(url: URL) -> AnyPublisher<Data, Error>
}


public struct MonitoredNetworkClient: NetworkClient {
    
    private let monitor: NetworkMonitorInterface
    
    public init(monitor: NetworkMonitorInterface) {
        self.monitor = monitor
    }
    
    public func get(url: URL) -> AnyPublisher<Data, Error> {
        let event = UUID()
        monitor.requested(url: url, event: event)
        let publisher = PassthroughSubject<Data, Error>()
        DispatchQueue.main.async {
            publisher.send(Data())
            monitor.resolved(url: url, event: event, resolution: .success)
        }
        return publisher.eraseToAnyPublisher()
    }

}


public struct StandardNetworkClient: NetworkClient {
    public func get(url: URL) -> AnyPublisher<Data, Error> {
        let publisher = PassthroughSubject<Data, Error>()
        DispatchQueue.main.async {
            publisher.send(Data())
        }
        return publisher.eraseToAnyPublisher()
    }
}
