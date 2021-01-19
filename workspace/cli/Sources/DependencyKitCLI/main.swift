import Foundation
import Yams

let args = DepGen.parseOrExit()
let yamlConfigPath = args.config
let fileURL = URL(fileURLWithPath: yamlConfigPath)
let data = try! Data(contentsOf: fileURL)
let decoder = YAMLDecoder()
let decoded = try decoder.decode(ConfigFileModel.self, from: data)
let currDir = URL(string: FileManager.default.currentDirectoryPath)!
let files = decoded.modules
    .flatMap { FileEnumerator.find(currDir.appendingPathComponent($0.path)) }
    .filter { $0.pathExtension == "swift" }
    .filter { !$0.pathComponents.contains(Constants.codegenDirectory) }
print(files)