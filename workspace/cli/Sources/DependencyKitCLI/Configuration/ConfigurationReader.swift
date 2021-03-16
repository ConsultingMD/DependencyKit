import ArgumentParser
import Foundation
import Yams

class ConfigurationReader {
    
    private let configURL: URL
    private let debugDump: Bool
    private let decoder = YAMLDecoder()
    
    init(configURL: URL, debugDump: Bool) {
        self.configURL = configURL
        self.debugDump = debugDump
    }
    
    func getParsingConfiguration() -> CodeParsingConfiguration {
        guard let data = try? Data(contentsOf: configURL)
        else { fatalError("Could not open YAML file at: \(configURL)") }
        guard let config = try? decoder.decode(ConfigurationFile.self, from: data)
        else { fatalError("Could not decode YAML config from file data from: \(configURL)") }
        return CodeParsingConfiguration(debugDump: debugDump,
                                        modules: config.modules.map { parsingConfiguration(module: $0) })
    }

    private func parsingConfiguration(module: ModuleConfigurationFileInformation) -> ModuleCodeParsingConfiguration {
        let workingDir = FS.pwd()
        let modulePath = workingDir.appendingPathComponent(module.path)
        let codegenFile = workingDir
            .appendingPathComponent(module.path)
            .appendingPathComponent(module.codegenDirectory ?? CodegenConstants.codegenDirectory)
            .appendingPathComponent(module.codegenFile ?? CodegenConstants.codegenFile)
        let files = FileSystem.find(modulePath)
            .filter { $0.pathExtension == CodegenConstants.swiftFileExtension }
            .reduce(into: (application: [URL](), codegen: [URL]())) { (out, curr) in
                // urls from FileManager are NSURLs with file:// scheme. Strip by using path.
                if codegenFile.path == curr.path {
                    out.codegen.append(curr)
                } else {
                    out.application.append(curr)
                }
            }
        assert(files.application.count == Set(files.application).count)
        assert(files.codegen.count <= 1)
        return ModuleCodeParsingConfiguration(name: module.name,
                                              files: files.application,
                                              codegenFile: files.codegen.first ?? codegenFile)
    }
    
}
