import Foundation

struct ModuleDeclarations {
    let config: ModuleConfiguration
    let imports: Set<Module>
    let requirements: Set<Requirements>
    let resources: Set<Resource>
}

struct Module: Hashable, CustomStringConvertible {
	let identifier: String
    
    var description: String { identifier }
}

struct FieldDeclaration: Hashable, CustomStringConvertible {
	let identifier: String
	let type: String
	let access: String?
    let optional: Bool
    
    var description: String { "\(access ?? "") var \(identifier)\(optional ? "?" : ""): \(type)" }
}

struct Requirements: Hashable, CustomStringConvertible {
    let access: String?
    let identifier: String
	let implicitGeneratedProtocol: String?
    let fields: [FieldDeclaration]

    private func fieldDescriptions() -> String {
        "\(fields.reduce("") { $0 + "\n " + $1.description })\n"
    }

    var description: String {
        return
            access.map{$0 + " "} ?? "" +
            "protocol \(identifier): Requirements, \(implicitGeneratedProtocol ?? "")" +
            "{\(fieldDescriptions())}"
    }
}

struct FieldImplementation: Hashable, CustomStringConvertible {
    let identifier: String
    let type: String
    let access: String?
    
    var description: String { "\(access ?? "") var \(identifier): \(type) \\ TODO: show impl" }
}

struct Resource: Hashable, CustomStringConvertible {
	let access: String?
    let identifier: String
	let genericIdentifier: String
	let conformanceIdentifiers: [String]
    let fields: [FieldImplementation]
    
    private func accessDescription() -> String {
        access.map { $0 + " " } ?? ""
    }

    private func declarationDescription() -> String {
        "class \(identifier)<I: \(genericIdentifier)>: Resource<I>"
    }

    private func conformanceDescription() -> String {
        "\(conformanceIdentifiers.reduce("") { $0 + ",\n " + $1 })"
    }

    private func fieldDescriptions() -> String {
        "\(fields.reduce("") { $0 + "\n " + $1.description })\n"
    }
    
    var description: String {
        return
            accessDescription() +
            declarationDescription() +
            conformanceDescription() + "{\n" +
            fieldDescriptions() + "}"
    }
}

struct ResourceInstantiation {
	let module: Module
	let constructedResource: Resource
	let injectedResource: Resource
}
