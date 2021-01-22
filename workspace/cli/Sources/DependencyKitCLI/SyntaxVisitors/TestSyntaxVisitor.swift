import Foundation
import SwiftSyntax

class TestSyntaxVisitor: SyntaxVisitor {

    override func visit(_ token: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        print("""
            %%% IMPORT %%%
            %%%%%%%%%%%%%%

            importTok: >"\(String(describing: token.importTok))"<

            path: >"\(String(describing: token.path))"<

            """)
        
        return super.visit(token)
    }
    
    override func visit(_ token: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        // For both Dependency & Requirement
        print("""
        %%% PROTOCOL %%%
        %%%%%%%%%%%%%%%%

        (access) modifiers: >"\(String(describing:token.modifiers?.children.flatMap{$0.children.flatMap{$0.tokens.map{$0.text}}}))"<

        inheritanceClause: >"\(String(describing: token.inheritanceClause?.inheritedTypeCollection.flatMap{$0.children.flatMap{$0.children.flatMap {$0.tokens.map{$0.text}}}}))"<

        """)
        return super.visit(token)
    }
    
    override func visit(_ token: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        // For both Dependency & Requirement
        print("""
        %%% CLASS %%%
        %%%%%%%%%%%%%

        (access) modifiers: >"\(String(describing:token.modifiers?.children.flatMap{$0.children.flatMap{$0.tokens.map{$0.text}}}))"<

        generic: >"\(String(describing:
                                token.genericParameterClause?.genericParameterList.children.flatMap { $0.tokens.map{ $0.text }}
                        ))"<

        inheritanceClause: >"\(String(describing: token.inheritanceClause?.inheritedTypeCollection.flatMap{$0.children.flatMap{$0.children.flatMap {$0.tokens.map{$0.text}}}}))"<

        """)
        return super.visit(token)
    }
    
    // TODO: Subclasses & their parents //ClassDecl
    
    // TODO: Instantiations & their parameters.
    // Finding the type of the param might be an issue?
    
}
