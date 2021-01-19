import Foundation

struct FrameworkPrimitives {
	static var importString = "DependencyKit"
	static var dependencyProtocolString = "Dependency"
	static var nilDependencyProtocolString = "NilDependency"
	static var requirementsProtocolString = "Requirements"
	static var nilRequirementsProtocolString = "NilRequirements"
	static var resourceClassString = "Resource"
	static var nilResourceClassString = "NilResource"
}

struct Module {
	let name: String
}

struct ModuleConfiguration {
	let module: Module
	let path: URL
	let generationPath: URL?
}

struct Field {
	let name: String
	let type: String
	let access: String
}

struct Requirement {
	let fields: [Field]
	let codegenName: String
}

struct Resource {
	let access: String
	let genericRequirement: Requirement
	let conformedRequirements: [Requirement]
	let directProvisions: [Field]
	let module: Module
}

struct ResourceInstantiation {
	let module: Module
	let constructedResource: Resource
	let injectedResource: Resource
}
