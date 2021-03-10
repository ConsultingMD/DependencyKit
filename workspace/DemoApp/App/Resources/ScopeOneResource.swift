import DependencyKit
import Foundation

protocol ScopeOneRequirements: Requirements, CODEGEN_ScopeOneRequirements {
    var explicit: String { get }
    var modified: String { get }
}

class ScopeOneResource<I: ScopeOneRequirements>: Resource<I>,
                                                 ScopeTwoRequirements {
    // Must be lazy to access `injected`.
    // Must access injected as this var overrides `modified` passed from injected.
    lazy var modified = "s1-modified-\(injected.modified)"
    let createdLater = "s1-createdLater"
    let recreated = "s1-recreated"
    
    func buildScopeTwo() -> ScopeTwoResource<ScopeOneResource> {
        ScopeTwoResource(injecting: self)
    }
}
