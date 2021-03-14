import DependencyKit
import Foundation

protocol ScopeThreeRequirements: Requirements, GENERATED_IMPLICIT_ScopeThreeRequirements {
    var explicit: String { get }
    var implicit: String { get }
    var modified: String { get }
    var recreated: String { get }
    var createdLater: String { get }
    var duplicated: String { get }
}


class ScopeThreeResource<I: ScopeThreeRequirements>: Resource<I> {
}
