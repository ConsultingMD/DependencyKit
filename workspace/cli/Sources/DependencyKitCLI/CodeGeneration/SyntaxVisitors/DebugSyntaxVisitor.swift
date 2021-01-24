import Foundation
import SwiftSyntax

class DebugSyntaxVisitor: SyntaxVisitor {

    var acc = ""
    
    override func visit(_ token: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        acc += """
            %%% IMPORT %%%
            %%%%%%%%%%%%%%

            importTok: >"\(String(describing: token.importTok))"<

            path: >"\(String(describing: token.path))"<

            """
        
        return super.visit(token)
    }
    
    override func visit(_ token: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        // For both Dependency & Requirement
        acc += """
        %%% PROTOCOL %%%
        %%%%%%%%%%%%%%%%

        (access) modifiers: >"\(String(describing:token.modifiers?.withoutTrivia().flatMap{$0.withoutTrivia().tokens.map{$0.text}}))"<
        identifier: >"\(String(describing: token.identifier.text))"<
        inheritanceClause: >"\(String(describing: token.inheritanceClause?.inheritedTypeCollection.withoutTrivia().flatMap{$0.withoutTrivia().tokens.map{ $0.text }}))"<

        """
        return super.visit(token)
    }
    
    override func visit(_ token: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        // For both Dependency & Requirement
        acc += """
        %%% CLASS %%%
        %%%%%%%%%%%%%

        (access) modifiers: >"\(String(describing:token.modifiers?.withoutTrivia().flatMap{$0.children.flatMap{$0.tokens.map{$0.text}}}))"<
        identifier: >"\(String(describing: token.identifier.text))"<
        generic: >"\(String(describing:
                                token.genericParameterClause?.genericParameterList.children.flatMap { $0.tokens.map{ $0.text }}
                        ))"<
        inheritanceClause: >"\(String(describing: token.inheritanceClause?.inheritedTypeCollection.withoutTrivia().flatMap{$0.withoutTrivia().tokens.map{ $0.text }}))"<

        """
        return super.visit(token)
    }
    
    override func visit(_ token: SimpleTypeIdentifierSyntax) -> SyntaxVisitorContinueKind {
        
        // Look for all type uses
        
        // We shouldn't have to look for access modifiers on the storage of the
        // instances because the access of the declarations should do.
        acc += """
        %%% TYPE %%%
        %%%%%%%%%%%%%

        name: >"\(String(describing: token.name.text))"<"
        generic: >"\(String(describing: token.genericArgumentClause?.arguments.withoutTrivia().children.flatMap{$0.tokens.map{$0.text}}))"<
        
        """
        return super.visit(token)
    }

    override func visit(_ token: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        
        // If the only instantiations of a Resource are *stored* in variables with
        // inferred types, we can only find the type by looking at the instantiation.
        // i.e. `let resourceX = ResourceX<RequirementY>(injecting: requirementY)`
        // (We could simply disallow FunctionCallExprSyntax referencing things that don't
        // have a corresponding SimpleTypeIdentifierSyntax.)
        
        // If the instantiation itself is done with an inferred generic parameter,
        // we would have to crawl higher scopes to find it.
        // i.e. `let resourceX = ResourceX(injecting: requirementY)`
        // Evaluating the inferred generic parameter with only a Syntax parsert
        // is a losing battle, so at least for now we'll disallow it.
        
        // There currently no helper on FunctionCallExprSyntax to resolve a SpecializeExpr
        // or anything that allows us to distinguish the semantics of the contained
        // identifiers by anything other than position relative to other syntax.
        // SwiftSyntax.TokenKind.leftAngle, SwiftSyntax.TokenKind.colon, etc.
        acc += """
        %%% INVOCATIONS %%%
        %%%%%%%%%%%%%%%%%%%

        expression: >"\(String(describing: token.calledExpression.withoutTrivia().tokens.map{$0.text}))"<
        expression: >"\(String(describing: token.calledExpression.withoutTrivia().tokens.map{$0.tokenKind}))"<

        arguments: >"\(String(describing: token.argumentList.tokens.map{$0.text}))"<
        arguments: >"\(String(describing: token.argumentList.tokens.map{$0.tokenKind}))"<

        """
        return super.visit(token)
    }
    
}


extension DebugSyntaxVisitor: CustomStringConvertible {
    var description: String { acc }
}
