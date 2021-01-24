import Foundation
import SwiftSyntax

class ModuleReader {
    
    let config: ModuleConfiguration
    private let visitor: SyntaxVisitor & CustomStringConvertible
    
    init(config: ModuleConfiguration) {
        self.config = config
        self.visitor = DependencyAnalysisSyntaxVisitor(config: config)
//        self.visitor = DebugSyntaxVisitor()
    }
 
    private func parseSources() -> [SourceFileSyntax] {
        config.files.map {
            guard let source = try? SyntaxParser.parse($0)
            else { fatalError("Source couldn't be parsed: \($0)")}
            return source
        }
    }
    
    func read() {
        parseSources().forEach { visitor.walk($0) }
    }

    func printInfo() {
        print(visitor)
    }
}
