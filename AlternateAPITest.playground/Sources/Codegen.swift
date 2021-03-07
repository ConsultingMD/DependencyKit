import Foundation

// MARK: Extensions for resources
extension Requirements where I == RootResource<NilResource> {
    public var appName: String { injected.appName }
}
extension Requirements where I == LevelOneResource<RootResource<NilResource>> {
    public var appName: String { injected.appName }
}

// MARK: Extensions for requirements
extension Requirements where I: LevelOneRequirements {
    public var appName: String { injected.appName }
}


typealias LevelOneRequirements_CODEGEN = NilDependency

typealias LevelTwoRequirements_CODEGEN = NilDependency
