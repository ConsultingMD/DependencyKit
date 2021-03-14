import Foundation

struct ModuleDeclarations {
    let parsingConfig: ModuleCodeParsingConfiguration
    let name: String
    let imports: Set<ModuleImportStatement>
    let requirements: Set<Requirements>
    let resources: Set<Resource>
}

struct ModuleImportStatement: Hashable, CustomStringConvertible {
	let identifier: String
    
    var description: String { identifier }
}

struct FieldDefinition: Hashable, CustomStringConvertible {
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
    let fields: [FieldDefinition]

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

extension ModuleDeclarations: CustomStringConvertible {
    var description: String {
        let module = "# module: " + name + " #"
        let moduleLine = module + "\n"
        let hashLine = String(repeating: "#", count: module.count) + "\n"
        let dashLine = "#" + String(repeating: "-", count: module.count) + "\n"
        let importsBlock = imports.reduce("") { $0 + "# - " + String(describing: $1) + "\n" }
        let requirementsBlock = requirements.reduce("") { $0 + "# - " + String(describing: $1) + "\n" }
        let resourcesBlock = resources.reduce("") { $0 + "# - " + String(describing: $1) + "\n" }
        return hashLine
            + moduleLine
            + hashLine
            + "# imports: \n"
            + importsBlock
            + dashLine
            + "# requirements: \n"
            + requirementsBlock
            + dashLine
            + "# resources: \n"
            + resourcesBlock
            + dashLine
    }
}

