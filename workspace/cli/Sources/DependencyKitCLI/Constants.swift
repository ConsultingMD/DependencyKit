import Foundation

struct CodegenConstants {
	static var codegenDirectory = "__generated__"
	static var codegenFile = "Generated.swift"
	static var swiftFileExtension = "swift"
    static var implicitGeneratedProtocolPrefix = "GENERATED_IMPLICIT_"
}

struct FrameworkConstants {
    static var importString = "DependencyKit"
    static var requirementsProtocolString = "Requirements"
    static var nilRequirementsProtocolString = "NilRequirements"
    static var resourceClassString = "Resource"
    static var nilResourceClassString = "NilResource"
}
