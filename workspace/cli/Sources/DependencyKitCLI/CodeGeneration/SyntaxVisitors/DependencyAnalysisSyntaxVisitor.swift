import Foundation
import SwiftSyntax

class DependencyAnalysisSyntaxVisitor: SyntaxVisitor {
    
    private let config: ModuleConfiguration
    
    init(config: ModuleConfiguration) {
        self.config = config
    }
    
    var imports = Set<Module>()
    var dependencies = Set<Dependency>()
    var requirements = Set<Requirement>()

    override func visit(_ token: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        if let text = token.path.first?.name.text {
            imports.insert(Module(identifier: text))
        }
        return super.visit(token)
    }
    
    override func visit(_ token: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let inherited = token
                .inheritanceClause?
                .inheritedTypeCollection
                .tokens
                .reduce(into: [String](), { out, curr in
                    if case let .identifier(name) = curr.tokenKind {
                        out.append(name)
                    }
                })
        else { return super.visit(token) }
        
        let modifiers = token.modifiers?.withoutTrivia().flatMap{$0.withoutTrivia().tokens.map{$0.text}}
        let identifier = token.identifier.text
        
        if inherited.contains(FrameworkConstants.dependencyProtocolString) {
            precondition(inherited.count <= 1 && modifiers?.count ?? 0 <= 1,
                         "Dependencies should only be declared in the form: \n" +
                         "[access] protocol Identifier: Dependency { var name: Type { get } }")
            dependencies.insert(
                Dependency(identifier: identifier,
                           access: modifiers?.first,
                           fieldName: "UNKNOWN",
                           fieldType: "UNKNOWN")
            )
        }

        if inherited.contains(FrameworkConstants.requirementsProtocolString) {
            let codegenProtocol = inherited.filter({ $0.hasSuffix(CodegenConstants.codegenProtocolSuffix) })
            let dependencyProtocols = inherited.filter({ $0 != FrameworkConstants.requirementsProtocolString &&
                                                        !$0.hasSuffix(CodegenConstants.codegenProtocolSuffix) })
            precondition(inherited.count >= 2 && modifiers?.count ?? 0 <= 1 && codegenProtocol.count == 1,
                         "Requirements must be declared in the form: \n" +
                         "[access] protocol MyRequirements: Requirements, MyReqStubFor_\(CodegenConstants.codegenProtocolSuffix), MyDependency1, MyDependency2, MyDependencyEtc {}")
            requirements.insert(
                Requirement(access: modifiers?.first,
                            identifier: identifier,
                            dependencyIdentifiers: dependencyProtocols,
                            codegenProtocolIdentifier: codegenProtocol.first!)
            )
        }

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

extension DependencyAnalysisSyntaxVisitor: CustomStringConvertible {
    var description: String {
        let header = "MODULE: \(config.module.identifier)"
        return String(repeating: "#", count: header.count + 4) + "\n"
            + "# \(header) #\n"
            + String(repeating: "#", count: header.count + 4) + "\n"
            + "# imports: \n"
            + imports.reduce("") { "\($0)# - \($1)\n" }
            + "# \(String(repeating: "-", count: header.count))\n"
            + "# dependencies: \n"
            + dependencies.reduce("") { "\($0)# - \($1)\n" }
            + "# \(String(repeating: "-", count: header.count))\n"
            + "# requirements: \n"
            + requirements.reduce("") { "\($0)# - \($1)\n" }
            + "# \(String(repeating: "-", count: header.count))\n"
    }
}
