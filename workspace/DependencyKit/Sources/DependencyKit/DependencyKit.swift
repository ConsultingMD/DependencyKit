import Foundation

public protocol Dependency {}
public protocol NilDependency: Dependency {}

public protocol Requirements {
    associatedtype I
    var injected: I { get }
}
public protocol NilRequirement: Requirements {}

public protocol ResourceType: Requirements {}

open class Resource<I: Requirements>: ResourceType {
    public let injected: I
    public init(injecting injected: I) {
        self.injected = injected
    }
}
public class NilResource: ResourceType, NilRequirement {
    public lazy var injected = self
    public init(){}
}
