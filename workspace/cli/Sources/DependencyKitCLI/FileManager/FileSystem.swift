import Foundation

class FileSystem {
    static func find(_ url: URL) -> [URL]{
        FileManager.default
            .enumerator(at: url,
                        includingPropertiesForKeys: [.isRegularFileKey],
                        options: [.skipsHiddenFiles, .skipsPackageDescendants]
            )?
            .compactMap { $0 as? URL }
            .filter { (try? $0.resourceValues(forKeys:[.isRegularFileKey]).isRegularFile) ?? false }
            ?? []
    }

    static func pwd() -> URL {
        URL(string: FileManager.default.currentDirectoryPath)!
    }
}

typealias FS = FileSystem