import Foundation

let cliReader = CLIReader()
let configURL = cliReader.configURL()
let configReader = ConfigurationReader(configURL: configURL)
let moduleConfigurations = configReader.readModuleConfigurations()
let readers = moduleConfigurations.map(ModuleReader.init(config:))
readers.forEach {
    $0.read()
    $0.printInfo()
}


