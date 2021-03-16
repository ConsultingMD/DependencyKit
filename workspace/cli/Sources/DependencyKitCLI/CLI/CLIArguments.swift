import ArgumentParser
import Foundation

struct CLIArguments {
    struct DependencyKit: ParsableArguments {

        @Option(name: [.customShort("c"), .long], help: "A YAML config file")
        var config: String

        @Flag(name: [.customShort("d"), .long], help: "Debug Dump")
        var debugDump: Bool = false

    }
}
