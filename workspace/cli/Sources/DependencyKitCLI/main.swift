import ArgumentParser
import Foundation
import SwiftSyntax

struct DepGen: ParsableArguments {
	@Argument(help: "A list of paths to module source roots. Each root folder must have the same name one would use to import the module.")
    var modules: [String] = []
}

struct Module {
	let name: String
	let path: URL
	let generationPath: URL?
}

struct Field {
	let name: String
	let type: String
	let access: String
}

struct Requirement {
	let fields: [Field]
	let codegenName: String
}

struct Resource {
	let access: String
	let genericRequirement: Requirement
	let conformedRequirements: [Requirement]
	let directProvisions: [Field]
	let module: Module
}

struct ResourceInstantiation {
	let module: Module
	let constructedResource: Resource
	let injectedResource: Resource
}

let args = DepGen.parseOrExit()


// let file = args.file
// let url = URL(fileURLWithPath: file)
// let sourceFile = try SyntaxParser.parse(url)
// let visitor = TestSyntaxVisitor()
// visitor.walk(sourceFile)



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
