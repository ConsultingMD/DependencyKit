
import Foundation
import SwiftSyntax

private let stringLiteralEnvVarPattern: String = "\"*\\$\\((\\w+)\\)\"*"

public class EnvironmentVariableLiteralRewriter: SyntaxRewriter {
  public var ignoredLiteralValues: Set<String> = []
  private var environment: [String: String] = [:]
  
  public init(environment: [String: String]) {
    self.environment = environment
  }
  
  public convenience init(
    environment: [String: String],
    ignoredLiteralValues: [String]) {
    self.init(environment: environment)
    self.ignoredLiteralValues = Set(ignoredLiteralValues)
  }
  
  override public func visit(_ token: TokenSyntax) -> Syntax {
    // Matching ENV var pattern e.g. $(ENV_VAR)
    guard matchesLiteralPattern(token) else { return Syntax(token) }
    
    guard let text = token.stringLiteral else { return Syntax(token) }
    
    let envVar = extractTextEnvVariableName(text)
    
    guard shouldPerformSubstitution(for: envVar), let envValue = environment[envVar] else {
      return Syntax(token)
    }
    
    return Syntax(token.byReplacingStringLiteral(string: envValue))
  }
  
  private func shouldPerformSubstitution(for text: String) -> Bool {
    return !ignoredLiteralValues.contains(text)
  }
  
  private func extractTextEnvVariableName(_ text: String) -> String {
    let regex = try? NSRegularExpression(pattern: stringLiteralEnvVarPattern, options: .caseInsensitive)
    let matches = regex?.matches(in: text, options: .anchored, range: NSRange(location: 0, length: text.count))
    
    guard let match = matches?.first else { return "" }
  
    let range = match.range(at: 1)
    let start = text.index(text.startIndex, offsetBy: range.location)
    let end = text.index(start, offsetBy: range.length)

    return String(text[start..<end])
  }
  
}

extension EnvironmentVariableLiteralRewriter {
  func matchesLiteralPattern(_ token: TokenSyntax) -> Bool {
    switch token.tokenKind {
    case .stringLiteral(let text), .stringSegment(let text):
      return text.range(of: stringLiteralEnvVarPattern,
                        options: .regularExpression,
                        range: nil,
                        locale: nil) != nil
    default:
      return false
    }
  }
}


extension TokenSyntax {
  var stringLiteral: String? {
    switch tokenKind {
    case .stringLiteral(let text), .stringSegment(let text):
      return text
    default:
      return nil
    }
  }
  
  func byReplacingStringLiteral(string: String) -> TokenSyntax {
    switch tokenKind {
    case .stringLiteral:
      return withKind(.stringLiteral("\"\(string)\""))
    case .stringSegment:
      return withKind(.stringSegment("\(string)"))
    default:
      return self
    }
  }
    
}
