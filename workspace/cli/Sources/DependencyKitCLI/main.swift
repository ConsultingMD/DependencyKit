import ArgumentParser
import Foundation
import SwiftSyntax

struct DepGen: ParsableArguments {
	@Option(help: ArgumentHelp("Parses file <f>", valueName: "f"))
	var file = ""
}

let args = DepGen.parseOrExit()
let file = args.file
let url = URL(fileURLWithPath: file)
let sourceFile = try SyntaxParser.parse(url)
let incremented = AddOneToIntegerLiterals().visit(sourceFile)
print(incremented)
