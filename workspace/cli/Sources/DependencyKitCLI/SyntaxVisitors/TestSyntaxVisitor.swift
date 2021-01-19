import Foundation
import SwiftSyntax

class TestSyntaxVisitor: SyntaxVisitor {

    override func visit(_ token: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        print(token.importTok.text)
        print(token.path)
        return super.visit(token)
    }
    
    override func visit(_ token: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        print(token.attributes)
        print(token.members)
        print(token.modifiers)
        print(token.identifier)
        print(token.inheritanceClause?.children)
        return super.visit(token)
    }
    
    override func visit(_ token: TokenSyntax) -> SyntaxVisitorContinueKind {
        print("%% \(token.description)")
        return super.visit(token)
    }
    
}
