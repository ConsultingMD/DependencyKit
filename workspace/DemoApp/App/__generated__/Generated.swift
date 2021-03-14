import DependencyKit
import Foundation
import NetworkClient

// MARK: Surface explicit Requirements on corresponding Resources
extension ResourceType where I: ScopeOneRequirements {
    var explicit: String { injected.explicit }
}
extension ResourceType where I: ScopeTwoRequirements {
    var explicit: String { injected.explicit }
    var modified: String { injected.modified }
    var recreated: String { injected.recreated }
    var createdLater: String { injected.createdLater }
}
extension ResourceType where I: ScopeThreeRequirements {
    var explicit: String { injected.explicit }
    var implicit: String { injected.implicit }
    var modified: String { injected.modified }
    var recreated: String { injected.recreated }
    var createdLater: String { injected.createdLater }
    var duplicated: String { injected.duplicated }
}

// MARK: Declare implicit (transitive) Requirements
protocol GENERATED_IMPLICIT_ScopeOneRequirements {
    func _GENERATED_IMPLICIT_implicit() -> String
}

protocol GENERATED_IMPLICIT_ScopeTwoRequirements {
    func _GENERATED_IMPLICIT_implicit() -> String
}

protocol GENERATED_IMPLICIT_ScopeThreeRequirements {
}

// MARK: Surface implicit Requirements once explicitly required
extension ScopeTwoResource where I: GENERATED_IMPLICIT_ScopeTwoRequirements {
    var implicit: String { injected._GENERATED_IMPLICIT_implicit() }
}

// MARK: Carry through implicit Requirements
extension ScopeZeroResource: GENERATED_IMPLICIT_ScopeOneRequirements {
    func _GENERATED_IMPLICIT_implicit() -> String { implicit }
}

extension ScopeOneResource: GENERATED_IMPLICIT_ScopeTwoRequirements {
    func _GENERATED_IMPLICIT_implicit() -> String { injected._GENERATED_IMPLICIT_implicit() }
}
