import Foundation

struct ConfigurationFile: Codable {
    let modules: [ModuleConfigurationFileInformation]
}

struct ModuleConfigurationFileInformation: Codable {
    let path: String
    let name: String
    let codegenDirectory: String?
    let codegenFile: String?
}

struct ModuleCodeParsingConfiguration {
    let name: String
    let files: [URL]
    let codegenFile: URL
}
