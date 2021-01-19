import Foundation

struct ModuleInfo: Codable {
	let path: String
	let name: String
}

struct ConfigFileModel: Codable {
	let modules: [ModuleInfo]
}
