import Foundation

public protocol Requirements {
    associatedtype I
    var injected: I { get }
}
public protocol NilRequirements: Requirements {}

public protocol ResourceType: Requirements {}

open class Resource<I: Requirements, P>: ResourceType {
    public let injected: I
    public let parameters: P
    public init(injecting injected: I, parameters: P) {
        self.injected = injected
        self.parameters = parameters
    }

    public final func cached<T>(function: String = #function, _ builder: () -> T) -> T {
        cachedStorageLock.lock()
        defer { cachedStorageLock.unlock() }
        let value: T
        if let stored = cachedStorage[function] as? T {
            value = stored
        } else {
            value = builder()
            cachedStorage[function] = value
        }
        return value
    }


    // MARK: - Private
    private let cachedStorageLock = NSRecursiveLock()
    private var cachedStorage = [String: Any]()

}


public extension Resource where P == Void {
    convenience init(injecting injected: I) {
        self.init(injecting: injected, parameters: ())
    }
}

public extension Resource where I == NilResource, P == Void {
    convenience init() {
        self.init(injecting: NilResource(), parameters: ())
    }
}

public class NilResource: ResourceType, NilRequirements {
    public lazy var injected = self
    public init(){}
}
