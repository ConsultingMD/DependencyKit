import Foundation

public protocol Dependency {}
public protocol NilDependency: Dependency {}

public protocol Requirements {
    associatedtype I
    var injected: I { get }
}
public protocol NilRequirement: Requirements {}

open class Resource<I>: Requirements {
    public let injected: I
    public init(dependency: I) {
        self.injected = dependency
    }
}
public class NilResource: NilRequirement {
    public lazy var injected = self
    public init(){}
}

@available(*, deprecated, message: "Once code generation has run, the currently conforming protocol '<Name>Requirements' should instead conform to GeneratedRequirements_<Name>")
public protocol GeneratedRequirements_ {}
