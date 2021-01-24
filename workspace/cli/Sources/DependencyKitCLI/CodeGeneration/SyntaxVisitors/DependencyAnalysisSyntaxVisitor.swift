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
    var resources = Set<Resource>()

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
                    if case .identifier(let name) = curr.tokenKind { out.append(name) }
                }),
              case let modifiers = token
                .modifiers?
                .tokens
                .reduce(into: [String](), { out, curr in
                    switch curr.tokenKind {
                  case .publicKeyword, .privateKeyword, .internalKeyword, .fileprivateKeyword:
                      out.append(curr.text)
                  default:
                      break
                  }
              }) ?? []
        else { return super.visit(token) }

        let identifier = token.identifier.text
        typealias TypeAccumulator = (var: String?, type: String?, optional: Bool, kind: SwiftSyntax.TokenKind?)
        
        let fields = token.members.members.map { member -> TypeAccumulator in
            let acc: TypeAccumulator  = (var: nil, type: nil, optional: false, kind: nil)
            return member.tokens.reduce(acc) { acc, curr in
                switch (acc.kind, curr.tokenKind) {
                case (.some(TokenKind.varKeyword), TokenKind.identifier(let variableIdentifier)):
                    return (variableIdentifier, acc.type, acc.optional, curr.tokenKind)
                case (.some(TokenKind.colon), TokenKind.identifier(let typeIdentifier)):
                    return (acc.var, typeIdentifier, acc.optional, curr.tokenKind)
                case (.some(TokenKind.identifier(let type)), TokenKind.postfixQuestionMark):
                    if type == acc.type { // we must have collected the type already
                        return (acc.var, acc.type, true, curr.tokenKind)
                    } else {
                        return (acc.var, acc.type, acc.optional, curr.tokenKind)
                    }
                default:
                    return (acc.var, acc.type, acc.optional, curr.tokenKind)
                }
            }
        }.map { acc -> Field in
            guard let varIdentifier = acc.var,
                  let typeIdentifier = acc.type
            else { fatalError("unparseable field") }
            return Field(identifier: varIdentifier, type: typeIdentifier + (acc.optional ? "?" : ""), access: nil)
        }

        if inherited.contains(FrameworkConstants.dependencyProtocolString) {
            precondition(inherited.count <= 1 && modifiers.count <= 1,
                         "Dependencies should only be declared in the form: \n" +
                         "[public] protocol Identifier: Dependency { var name: Type { get } }")
            dependencies.insert(
                Dependency(identifier: identifier,
                           access: modifiers.first,
                           fields: fields)
            )
        }

        if inherited.contains(FrameworkConstants.requirementsProtocolString) {
            let codegenProtocol = inherited.filter({ $0.hasSuffix(CodegenConstants.codegenProtocolSuffix) })
            let dependencyProtocols = inherited.filter({ $0 != FrameworkConstants.requirementsProtocolString &&
                                                        !$0.hasSuffix(CodegenConstants.codegenProtocolSuffix) })
            precondition(inherited.count >= 2 && modifiers.count <= 1 && codegenProtocol.count == 1,
                         "Requirements must be declared in the form: \n" +
                         "[public] protocol MyRequirements: Requirements, MyReqStubFor_\(CodegenConstants.codegenProtocolSuffix), MyDependency1, MyDependency2, MyDependencyEtc {}")
            requirements.insert(
                Requirement(access: modifiers.first,
                            identifier: identifier,
                            dependencyIdentifiers: dependencyProtocols,
                            codegenProtocolIdentifier: codegenProtocol.first!)
            )
        }

        return super.visit(token)
    }
    
    override func visit(_ token: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let inheritedTypesTokens = token
                .inheritanceClause?
                .inheritedTypeCollection
                .tokens
                .reduce(into: [String](), { out, curr in
                    if case .identifier(let name) = curr.tokenKind { out.append(name) }
                }),
              let genericTypeTokens = token
                .genericParameterClause?
                .genericParameterList
                .tokens
                .reduce(into: [String](), { out, curr in
                    if case .identifier(let name) = curr.tokenKind { out.append(name) }
                }),
              inheritedTypesTokens.contains(FrameworkConstants.resourceClassString),
              case let modifiers = token
                .modifiers?
                .tokens
                .reduce(into: [String](), { out, curr in
                    switch curr.tokenKind {
                  case .publicKeyword, .privateKeyword, .internalKeyword, .fileprivateKeyword:
                      out.append(curr.text)
                  default:
                      break
                  }
              }) ?? [],
              case let identifier = token.identifier.text,
              // The generic name, e.g. T, is an Identifier and is present in the tokens collected. Remove.
              case let inheritedSet = Set<String>(inheritedTypesTokens),
              case let genericsSet = Set<String>(genericTypeTokens),
              case let t = inheritedSet.intersection(genericsSet),
              case let protocolConformance = Array(
                inheritedSet
                    .symmetricDifference(t)
                    .symmetricDifference([FrameworkConstants.resourceClassString])
              ),
              case let genericConstraint = Array(genericsSet.symmetricDifference(t))
        else { return super.visit(token) }

        precondition(modifiers.count <= 1 && genericConstraint.count == 1,
                     "Requirements must be declared in the form: \n" +
                     "[public] protocol MyRequirements: Requirements, MyReqStubFor_\(CodegenConstants.codegenProtocolSuffix), MyDependency1, MyDependency2, MyDependencyEtc {}")
        
        resources.insert(
            Resource(access: modifiers.first,
                     identifier: identifier,
                     genericIdentifier: genericConstraint.first!,
                     conformanceIdentifiers: protocolConformance,
                     fields: ["UNKNOWN"])
        )
        
        return super.visit(token)
    }
}

extension DependencyAnalysisSyntaxVisitor: CustomStringConvertible {
    var description: String {
        let header = "module: \(config.module.identifier)"
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
            + "# resources: \n"
            + resources.reduce("") { "\($0)# - \($1)\n" }
            + "# \(String(repeating: "-", count: header.count))\n"
    }
}
