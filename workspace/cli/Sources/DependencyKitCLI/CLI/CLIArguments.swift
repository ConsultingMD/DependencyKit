import ArgumentParser
import Foundation

struct CLIArguments {
    struct DependencyKit: ParsableArguments {

        @Option(name: [.customShort("c"), .long], help: "A YAML config file")
        var config: String

        static func parseConfigFileURL() -> URL {
            let args = DependencyKit.parseOrExit()
            let yamlConfigPath = args.config
            return URL(fileURLWithPath: yamlConfigPath)
        }
    }
}
