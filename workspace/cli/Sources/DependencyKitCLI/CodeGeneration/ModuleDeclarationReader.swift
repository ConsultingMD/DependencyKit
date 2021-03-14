import Foundation
import SwiftSyntax

class ModuleDeclarationReader {
    
    let config: ModuleConfiguration
    private let declarationVisitor: DeclarationSyntaxVisitor
    
    init(config: ModuleConfiguration) {
        self.config = config
        self.declarationVisitor = DeclarationSyntaxVisitor(config: config)
    }
 
    private func parseSources() -> [SourceFileSyntax] {
        config.files.map {
            guard let source = try? SyntaxParser.parse($0)
            else { fatalError("Source couldn't be parsed: \($0)")}
            return source
        }
    }
    
    func read() {
        parseSources().forEach { declarationVisitor.walk($0) }
    }

    func printInfo() {
        print(declarationVisitor)
    }
    
    var visitedDeclarations: ModuleDeclarations {
        ModuleDeclarations(config: config,
                           imports: declarationVisitor.imports,
                           requirements: declarationVisitor.requirements,
                           resources: declarationVisitor.resources)
    }
}
