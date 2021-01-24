import Foundation

struct CodegenConstants {
	static var codegenDirectory = "__CODEGEN__"
	static var codegenFile = "CODEGEN.swift"
	static var swiftFileExtension = "swift"
    static var codegenProtocolSuffix = "_CODEGEN"
}

struct FrameworkConstants {
    static var importString = "DependencyKit"
    static var dependencyProtocolString = "Dependency"
    static var nilDependencyProtocolString = "NilDependency"
    static var requirementsProtocolString = "Requirements"
    static var nilRequirementsProtocolString = "NilRequirements"
    static var resourceClassString = "Resource"
    static var nilResourceClassString = "NilResource"
}
