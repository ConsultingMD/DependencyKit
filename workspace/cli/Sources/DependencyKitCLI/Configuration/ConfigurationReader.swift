import ArgumentParser
import Foundation
import Yams

class ConfigurationReader {
    
    private let configURL: URL
    private let decoder = YAMLDecoder()
    
    init(configURL: URL) {
        self.configURL = configURL
    }
    
    func readModuleConfigurations() -> [ModuleConfiguration] {
        guard let data = try? Data(contentsOf: configURL)
        else { fatalError("Could not open YAML file at: \(configURL)") }
        guard let config = try? decoder.decode(ConfigFileModel.self, from: data)
        else { fatalError("Could not decode YAML config from file data from: \(configURL)") }
        
        return config.modules.map { configuration(for: $0) }
        
    }
    
    private func configuration(for module: ModuleDefinition) -> ModuleConfiguration {
        let workingDir = FS.pwd()
        let modulePath = workingDir.appendingPathComponent(module.path)
        let codegenFile = module.codegenFileURL(from: workingDir)
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
        return ModuleConfiguration(module: Module(name: module.name),
                                   files: files.application,
                                   codegenFile: files.codegen.first ?? codegenFile)
    }
    
}
