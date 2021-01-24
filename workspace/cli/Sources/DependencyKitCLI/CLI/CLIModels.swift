import ArgumentParser
import Foundation

struct DepGen: ParsableArguments {
    @Option(name: [.customShort("c"), .long], help: "A YAML config file")
    var config = ""
}

struct ConfigFileModel: Codable {
    let modules: [ModuleDefinition]
}

struct ModuleDefinition: Codable {
    let path: String
    let name: String
    let codegenDirectory: String?
    let codegenFile: String?
}

extension ModuleDefinition {

    func codegenFileURL(from root: URL) -> URL {
        root
            .appendingPathComponent(path)
            .appendingPathComponent(codegenDirectory ?? CodegenConstants.codegenDirectory)
            .appendingPathComponent(codegenFile ?? CodegenConstants.codegenFile)
    }
    
}
