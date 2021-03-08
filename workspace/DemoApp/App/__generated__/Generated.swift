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
}
extension ResourceType where I: LevelThreeRequirements {
    public var explicitPassthrough: String { injected.explicitPassthrough }
    public var modified: String { injected.modified }
    public var recreated: String { injected.recreated }
    public var implicitPassthrough: String { injected.implicitPassthrough }
}

// MARK: Declare implicit (transitive) Requirements
public protocol CODEGEN_LevelOneRequirements {
    func _CODEGEN_implicitPassthrough() -> String
}

public protocol CODEGEN_LevelTwoRequirements {
    func _CODEGEN_implicitPassthrough() -> String
}

public protocol CODEGEN_LevelThreeRequirements {
}

// MARK: Surface implicit Requirements once explicitly required
extension LevelTwoResource where I: CODEGEN_LevelTwoRequirements {
    public var implicitPassthrough: String { injected._CODEGEN_implicitPassthrough() }
}

// MARK: Carry through implicit Requirements
extension RootResource: CODEGEN_LevelOneRequirements {
    public func _CODEGEN_implicitPassthrough() -> String { implicitPassthrough }
}

extension LevelOneResource: CODEGEN_LevelTwoRequirements {
    public func _CODEGEN_implicitPassthrough() -> String { injected._CODEGEN_implicitPassthrough() }
}
