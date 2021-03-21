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
}

public extension Resource where P == Void {
    convenience init(injecting injected: I) {
        self.init(injecting: injected, parameters: ())
    }
}

public class NilResource: ResourceType, NilRequirements {
    public lazy var injected = self
    public init(){}
}
