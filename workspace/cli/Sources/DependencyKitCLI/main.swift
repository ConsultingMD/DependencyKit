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
let visitor = TestSyntaxVisitor()
visitor.walk(sourceFile)



/*
 
 let sourceFile = try SyntaxParser.parse(url)
 
 let envVarRewriter = EnvironmentVariableLiteralRewriter(
                         environment: ProcessInfo.processInfo.environment,
                         ignoredLiteralValues: varLiteralsToIgnore,
                         logger: logger
                      )
 let result = envVarRewriter.visit(sourceFile)
 
 var contents: String = ""
 result.write(to: &contents)
 
 try contents.write(to: url, atomically: true, encoding: .utf8)
 */
