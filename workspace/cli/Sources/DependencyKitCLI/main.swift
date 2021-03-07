import Foundation

let cliReader = CLIReader()
let configURL = cliReader.configURL()
let configReader = ConfigurationReader(configURL: configURL)
let moduleConfigurations = configReader.readModuleConfigurations()
let readers = moduleConfigurations.map(ModuleDeclarationReader.init(config:))
readers.forEach {
    $0.read()
}
let declarations = readers.map(\.visitedDeclarations)
let 

