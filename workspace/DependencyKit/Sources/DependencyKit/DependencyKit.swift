import Foundation

/// **This is a code generation hook.**
/// Dependency protocols should be initially written to conform to this `Dependency` protocol.
/// Code generation will create a `DependencyFill` and swap conformance to a  `Dependency` extension type.
/// e.g. `protocol MyDependency: Dependency {}` → `protocol MyDependency: Dependency.MyDependency`
public protocol Dependency {
    associatedtype T
    var dependency: T { get }
}

/// The internal abstract representation of 'nothing'. 
/// Application code should never have to conform directly to it.
public protocol Empty {}

// MARK: - Bases for application code

/// The Component base class. Components should directly inherit this.
open class Component<T>: Dependency {
    public let dependency: T
    public init(dependency: T) {
        self.dependency = dependency
    }
}

/// A special Dependency representing that nothign is provided or required.
/// Root components should use this to indicate they are fully self-standing.
public protocol EmptyDependency: Dependency {}

/// A special component to be provided as a Dependency to root level Components.
public class EmptyComponent: EmptyDependency {
    public lazy var dependency = self
    public init(){}
}
