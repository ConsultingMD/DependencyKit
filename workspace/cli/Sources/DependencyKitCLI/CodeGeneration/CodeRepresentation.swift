import Foundation

struct Module: Hashable, CustomStringConvertible {
	let identifier: String
    
    var description: String { identifier }
}

struct Dependency: Hashable, CustomStringConvertible {
    let identifier: String
    let access: String?
    let fieldName: String
    let fieldType: String
    
    var description: String { "\(access.map{$0 + " "} ?? "")protocol \(identifier): Dependency { var \(fieldName): \(fieldType) { get } }" }
}

struct Field: Hashable, CustomStringConvertible {
	let identifier: String
	let type: String
	let access: String?
    
    var description: String { "\(access ?? "") var \(identifier): \(type)" }
}

struct Requirement: Hashable, CustomStringConvertible {
    let access: String?
    let identifier: String
	let dependencyIdentifiers: [String]
	let codegenProtocolIdentifier: String
    
    var description: String { "\(access.map{$0 + " "} ?? "")protocol \(identifier): Requirements, \(codegenProtocolIdentifier)\(dependencyIdentifiers.reduce(""){ $0 + ", " + $1 }) {}"}
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
