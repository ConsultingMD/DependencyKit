import Foundation
import SwiftSyntax

class DeclarationSyntaxVisitor: SyntaxVisitor {
    
    private let moduleConfig: ModuleCodeParsingConfiguration
    private let debugDump: Bool
    
    init(config: ModuleCodeParsingConfiguration, debugDump: Bool) {
        self.moduleConfig = config
        self.debugDump = debugDump
    }
    
    var imports = Set<ModuleImportStatement>()
    var requirements = Set<Requirements>()
    var resources = Set<Resource>()

    override func visit(_ token: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        if let text = token.path.first?.name.text {
            imports.insert(ModuleImportStatement(identifier: text))
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
        }.map { acc -> FieldDefinition in
            guard let varIdentifier = acc.var,
                  let typeIdentifier = acc.type
            else { fatalError("unparseable field") }
            return FieldDefinition(identifier: varIdentifier,
                                   type: typeIdentifier,
                                   access: nil,
                                   optional: acc.optional)
        }

        if inherited.contains(FrameworkConstants.requirementsProtocolString) {
            let codegenProtocol = inherited
                .filter({ $0.hasPrefix(CodegenConstants.implicitGeneratedProtocolPrefix) })
            precondition(inherited.count > 0
                            && inherited.count <= 2
                            && modifiers.count <= 1
                            && codegenProtocol.count <= 1,
                         "Requirements must be declared with the form: \n"
                            + "(public|internal|fileprivate|private)? "
                            + "protocol TheScopeRequirements: Requirements "
                            + "(, GENERATED_IMPLICIT_TheScopeRequirements)? {\n"
                            + "\t(var requirementName: RequirementType { get })*?\n"
                            + "}")
            requirements.insert(
                Requirements(access: modifiers.first,
                             identifier: identifier,
                             implicitGeneratedProtocol: codegenProtocol.first,
                             fields: fields)
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

        precondition(modifiers.count <= 1
                        && genericConstraint.count == 1,
                     "Resources must be declared in the form: \n"
                        + "(public|internal|fileprivate|private)?"
                        + "class TheScopeResource<I: TheScopeRequirements>: Resource<I> "
                        + "(, Conformances)? {"
                        + "\t(var requirementName: RequirementType { /*implementation*/ })*?\n"
                        + "}")
        
        typealias TypeAccumulator = (var: String?, type: String?, optional: Bool, kind: SwiftSyntax.TokenKind?)
        
        resources.insert(
            Resource(access: modifiers.first,
                     identifier: identifier,
                     genericIdentifier: genericConstraint.first!,
                     conformanceIdentifiers: protocolConformance,
                     fields: [])
        )
        
        return super.visit(token)
    }
}
