import Foundation
import SwiftSyntax

class DependencyAnalysisSyntaxVisitor: SyntaxVisitor {
    
    override func visit(_ token: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
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
