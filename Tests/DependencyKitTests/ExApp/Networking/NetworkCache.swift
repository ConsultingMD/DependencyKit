import Foundation


protocol NetworkCache {
    func fetchResult(for url: URL) -> Data?
    func save(result: Data, for url: URL)
}

final class NetworkCacheImpl: NetworkCache {

    private var dataCache = [URL: Data]()
    private let lock = NSLock()

    func fetchResult(for url: URL) -> Data? {
        lock.lock()
        defer { lock.unlock() }
        return dataCache[url]
    }

    func save(result: Data, for url: URL) {
        lock.lock()
        defer { lock.unlock() }
        dataCache[url] = result
    }
}
