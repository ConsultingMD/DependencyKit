import Foundation

let args = CLIArguments.DependencyKit.parseOrExit()
let yamlConfigPath = args.config
let configURL = URL(fileURLWithPath: yamlConfigPath)
let configReader = ConfigurationReader(configURL: configURL, debugDump: args.debugDump)
let callConfiguration = configReader.getParsingConfiguration()
let readers = callConfiguration.modules.map {
    DeclarationAndImplementationReader(config: $0, debugDump: callConfiguration.debugDump)
}
let moduleDeclarations = readers.map { $0.parseModules() }
moduleDeclarations.forEach {
    print(String(describing: $0))
}
