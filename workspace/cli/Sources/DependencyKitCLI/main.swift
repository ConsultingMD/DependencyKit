import Foundation
import Yams

let args = DepGen.parseOrExit()
let yamlConfigPath = args.config
let fileURL = URL(fileURLWithPath: yamlConfigPath)
let data = try! Data(contentsOf: fileURL)
let decoder = YAMLDecoder()
let decoded = try decoder.decode(ConfigFileModel.self, from: data)
let files = decoded.modules
    .flatMap { module -> [URL] in
        FileSystem.find(FS.pwd().appendingPathComponent(module.path))
            .filter { $0.pathExtension == Constants.swiftFileExtension }
            .filter { !module.isCodegen(url: $0) }
    }
if files.count != Set(files).count {
    print("""
        Error: files found multiple times.

        This could be due to modules being nested within eachother.

        """)
}

print(files)
