import Foundation

struct Module: Hashable {
	let name: String
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
