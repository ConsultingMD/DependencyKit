import DependencyKit
import Foundation
import NetworkClient

// MARK: Extensions for resources
extension ResourceType where I == RootResource<NilResource> {
    public var explicitPassthrough: String { injected.explicitPassthrough }
    public var modified: String { injected.modified }
//    public var implicitPassthrough: String { injected.implicitPassthrough }
}
extension ResourceType where I == LevelOneResource<RootResource<NilResource>> {
    public var explicitPassthrough: String { injected.explicitPassthrough }
    public var modified: String { injected.modified }
    public var recreated: String { injected.recreated }
//    public var implicitPassthrough: String { injected.implicitPassthrough }
}

// MARK: Extensions for requirements

extension Requirements where I: NilRequirements {
}

extension Requirements where I: LevelOneRequirements {
    public var explicitPassthrough: String { injected.explicitPassthrough }
    public var modified: String { injected.modified }
//    public var implicitPassthrough: String { injected.implicitPassthrough }
}

extension Requirements where I: LevelTwoRequirements {
}
