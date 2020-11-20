import Foundation

public enum NetworkResolution {
    case success
    case failure(error: Error)
}

public protocol NetworkMonitorInterface {
    func requested(url: URL, event: UUID)
    func resolved(url: URL, event: UUID, resolution: NetworkResolution)
}
