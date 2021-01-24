import Foundation

struct Module: Hashable, CustomStringConvertible {
	let identifier: String
    
    var description: String { identifier }
}

struct Dependency: Hashable, CustomStringConvertible {
    let identifier: String
    let access: String?
    let fields: [Field]
    
    var description: String { "\(access.map{$0 + " "} ?? "")protocol \(identifier): Dependency { \(fields) }" }
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

struct Resource: Hashable, CustomStringConvertible {
	let access: String?
    let identifier: String
	let genericIdentifier: String
	let conformanceIdentifiers: [String]
    
    var description: String { "\(access.map{$0 + " "} ?? "")class \(identifier)<T: \(genericIdentifier)>: Resource<T>\(conformanceIdentifiers.reduce(""){ $0 + ", " + $1 }) {/* ... */}" }
}

struct ResourceInstantiation {
	let module: Module
	let constructedResource: Resource
	let injectedResource: Resource
}
