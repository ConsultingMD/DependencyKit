import Foundation

// MARK: - Internal Only

/// The internal abstract base representation of a dependency type.
/// Application code should never have to conform directly to it.
protocol Dependency {
    associatedtype T
    var dependency: T { get }
}

/// The internal abstract representation of 'nothing'. 
/// Application code should never have to conform directly to it.
protocol Empty {}

// MARK: - Bases for application code

/// Dependencies should conform to a DependencyBase, initially the NEW_TO_GENERATE codegen hook.
protocol DependencyBase {
    /// This is a code generation hook.
    /// Code generation will create a DependencyFill and corresponding DependencyBase extension type.
    /// The user code conformance will then be swapped out.
    typealias NEW_TO_GENERATE = Dependency
}

/// The Component base class. Components should directly inherit this.
class Component<T>: Dependency {
    let dependency: T
    init(dependency: T) {
        self.dependency = dependency
    }
}

/// A special Dependency representing that nothign is provided or required.
/// Root components should use this to indicate they are fully self-standing.
protocol EmptyDependency: Dependency {}

/// A special component to be provided as a Dependency to root level Components.
class EmptyComponent: EmptyDependency {
    lazy var dependency = self
}
