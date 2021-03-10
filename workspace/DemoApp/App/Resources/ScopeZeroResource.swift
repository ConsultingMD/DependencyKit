import DependencyKit
import Foundation
import NetworkClient

class ScopeZeroResource<I: NilRequirements>: Resource<I>,
                                             ScopeOneRequirements {
    let explicit = "s0-explicit"
    let implicit = "s0-implicit"
    let modified = "s0-modified"
    let recreated = "s0-recreated"
    let dropped = "s0-dropped"
    
    func buildScopeOne() -> ScopeOneResource<ScopeZeroResource> { ScopeOneResource(injecting: self) }
}

