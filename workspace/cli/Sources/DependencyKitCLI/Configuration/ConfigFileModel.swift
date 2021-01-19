import Foundation

struct ModuleInfo: Codable {
    let path: String
    let name: String
    let codegenDirectory: String?
    let codegenFileName: String?
}

extension ModuleInfo {

    func isCodegen(url: URL) -> Bool {
        // urls from FileManager are NSURLs with file:// scheme. Strip.
        url.path == codegenFile.path
    }

    var codegenDirectoryURL: URL {
        FS.pwd()
            .appendingPathComponent(path)
            .appendingPathComponent(codegenDirectory ?? Constants.codegenDirectory)
    }

    var codegenFileNameString: String {
        codegenFileName ?? Constants.codegenFileName + ".\(Constants.swiftFileExtension)"
    }

    var codegenFile: URL {
        codegenDirectoryURL.appendingPathComponent(codegenFileNameString)
    }
}

struct ConfigFileModel: Codable {
    let modules: [ModuleInfo]
}
