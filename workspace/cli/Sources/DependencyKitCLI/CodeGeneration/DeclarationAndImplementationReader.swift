import Foundation
import SwiftSyntax

class DeclarationAndImplementationReader {
    
    let moduleParsingConfig: ModuleCodeParsingConfiguration
    private let declarationVisitor: DeclarationSyntaxVisitor
    
    init(config: ModuleCodeParsingConfiguration, debugDump: Bool) {
        self.moduleParsingConfig = config
        self.declarationVisitor = DeclarationSyntaxVisitor(config: config, debugDump: debugDump)
    }
 
    private func parseSources() -> [SourceFileSyntax] {
        moduleParsingConfig.files.map {
            guard let source = try? SyntaxParser.parse($0)
            else { fatalError("Source couldn't be parsed: \($0)")}
            return source
        }
    }
    
    func parseModules() -> ModuleDeclarations {
        parseSources().forEach { declarationVisitor.walk($0) }
        return ModuleDeclarations(parsingConfig: moduleParsingConfig,
                                  name: moduleParsingConfig.name,
                                  imports: declarationVisitor.imports,
                                  requirements: declarationVisitor.requirements,
                                  resources: declarationVisitor.resources)
    }

}
