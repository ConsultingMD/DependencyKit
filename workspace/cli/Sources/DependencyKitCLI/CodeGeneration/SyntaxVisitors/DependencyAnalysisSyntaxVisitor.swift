import Foundation
import SwiftSyntax

class DependencyAnalysisSyntaxVisitor: SyntaxVisitor {
    
    var imports = Set<String>()

    override func visit(_ token: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        if let text = token.path.first?.name.text {
            imports.insert(text)
        }
        return super.visit(token)
    }
    
    override func visit(_ token: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        return super.visit(token)
    }
    
    override func visit(_ token: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        return super.visit(token)
    }
    
    override func visit(_ token: SimpleTypeIdentifierSyntax) -> SyntaxVisitorContinueKind {
        return super.visit(token)
    }

    override func visit(_ token: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        return super.visit(token)
    }
    
}
