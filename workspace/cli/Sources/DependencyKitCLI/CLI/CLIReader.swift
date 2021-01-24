import ArgumentParser
import Foundation

class CLIReader {
    func configURL() -> URL {
        let args = DepGen.parseOrExit()
        let yamlConfigPath = args.config
        let fileURL = URL(fileURLWithPath: yamlConfigPath)
        return fileURL
    }
}
