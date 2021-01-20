import Foundation
import SwiftSyntax
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
print("")
print("### FILES")
print(files)
let file = files[3]
print("")
print("### SINGLE FILE")
print(file)
let sourceFile = try SyntaxParser.parse(file)
print("")
print("### SOURCEFILE")
print(sourceFile)
print("")
print("""
    ### RESULT ###
    ##############

    """)
let visitor = TestSyntaxVisitor()
visitor.walk(sourceFile)
