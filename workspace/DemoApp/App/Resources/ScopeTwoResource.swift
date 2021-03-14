import DependencyKit
import Foundation

protocol ScopeTwoRequirements: Requirements, GENERATED_IMPLICIT_ScopeTwoRequirements {
    var explicit: String { get }
    var modified: String { get }
    var recreated: String { get }
    var createdLater: String { get }
}


class ScopeTwoResource<I: ScopeTwoRequirements>: Resource<I>,
                                                 ScopeThreeRequirements{
    var duplicated: String { explicit }

    func buildScopeThree() -> ScopeThreeResource<ScopeTwoResource> {
        ScopeThreeResource(injecting: self)
    }
}
