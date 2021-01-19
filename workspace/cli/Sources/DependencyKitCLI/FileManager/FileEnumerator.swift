import Foundation

class FileEnumerator {
    static func find(_ url: URL) -> [URL]{
        var files = [URL]()
        if let enumerator = FileManager.default
            .enumerator(at: url,
                        includingPropertiesForKeys: [.isRegularFileKey],
                        options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                if let fileAttributes = try? fileURL.resourceValues(forKeys:[.isRegularFileKey]),
                    fileAttributes.isRegularFile == true {
                    files.append(fileURL)
                }
            }
        }
        return files
    }
}