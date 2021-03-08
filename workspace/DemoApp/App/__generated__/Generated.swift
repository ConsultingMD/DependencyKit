import DependencyKit
import Foundation
import NetworkClient

// MARK: Surface explicit Requirements on corresponding Resources
extension ResourceType where I: LevelOneRequirements {
    public var explicitPassthrough: String { injected.explicitPassthrough }
}
extension ResourceType where I: LevelTwoRequirements {
    public var explicitPassthrough: String { injected.explicitPassthrough }
    public var modified: String { injected.modified }
    public var recreated: String { injected.recreated }
    public var implicitPassthrough: String { injected.implicitPassthrough }
}

// MARK: Declare implicit (transitive) Requirements
public protocol CODEGEN_LevelOneRequirements {
    var CODEGEN_implicitPassthrough: String { get }
}

public protocol CODEGEN_LevelTwoRequirements {
}

// MARK: Surface implicit Requirements once explicitly required
extension LevelOneResource where I: CODEGEN_LevelOneRequirements {
    public var implicitPassthrough: String { injected.CODEGEN_implicitPassthrough }
}

// MARK: Carry through implicit Requirements
extension RootResource {
    public var CODEGEN_implicitPassthrough: String { implicitPassthrough }
}

