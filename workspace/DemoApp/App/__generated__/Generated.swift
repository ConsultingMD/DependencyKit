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
protocol CODEGEN_ScopeOneRequirements {
    func _CODEGEN_implicit() -> String
}

protocol CODEGEN_ScopeTwoRequirements {
    func _CODEGEN_implicit() -> String
}

protocol CODEGEN_ScopeThreeRequirements {
}

// MARK: Surface implicit Requirements once explicitly required
extension ScopeTwoResource where I: CODEGEN_ScopeTwoRequirements {
    var implicit: String { injected._CODEGEN_implicit() }
}

// MARK: Carry through implicit Requirements
extension ScopeZeroResource: CODEGEN_ScopeOneRequirements {
    func _CODEGEN_implicit() -> String { implicit }
}

extension ScopeOneResource: CODEGEN_ScopeTwoRequirements {
    func _CODEGEN_implicit() -> String { injected._CODEGEN_implicit() }
}
