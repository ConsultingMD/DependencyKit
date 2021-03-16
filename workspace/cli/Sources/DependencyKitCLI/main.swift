import Foundation

let configURL = CLIArguments.DependencyKit.parseConfigFileURL()
let configReader = ConfigurationReader(configURL: configURL)
let moduleConfigurations = configReader.getParsingConfiguration()
let readers = moduleConfigurations.map(DeclarationAndImplementationReader.init(config:))
let moduleDeclarations = readers.map { $0.parseModules() }
moduleDeclarations.forEach {
    print(String(describing: $0))
}
