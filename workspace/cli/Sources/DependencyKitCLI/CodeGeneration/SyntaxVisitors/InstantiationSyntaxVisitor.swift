import Foundation
import SwiftSyntax

class InstantiationSyntaxVisitor: SyntaxVisitor {

    private let config: ModuleCodeParsingConfiguration
    
    init(config: ModuleCodeParsingConfiguration) {
        self.config = config
    }
    
    override func visit(_ token: SimpleTypeIdentifierSyntax) -> SyntaxVisitorContinueKind {
//        print("#>")
//        print(token.name.text)
//        print(token.genericArgumentClause?.tokens.map { $0.text })
        return super.visit(token)
    }

    override func visit(_ token: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
//        print("@>")
//        print(token.calledExpression.withoutTrivia())
        return super.visit(token)
    }
    
}


extension InstantiationSyntaxVisitor: CustomStringConvertible {
    var description: String { "" }
}
