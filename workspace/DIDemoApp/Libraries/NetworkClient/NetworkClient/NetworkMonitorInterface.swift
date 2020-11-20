//
//  NetworkMonitorInterface.swift
//  NetworkClient
//
//  Created by az on 2020-11-18.
//

import Foundation

public enum NetworkResolution {
    case success
    case failure(error: Error)
}

public protocol NetworkMonitorInterface {
    func requested(url: URL, event: UUID)
    func resolved(url: URL, event: UUID, resolution: NetworkResolution)
}
