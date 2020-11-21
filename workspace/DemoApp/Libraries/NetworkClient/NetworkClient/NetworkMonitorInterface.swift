import Foundation

public protocol NetworkMonitorInterface {
    func requested(url: URL, event: UUID)
    func resolved(url: URL, event: UUID)
}
