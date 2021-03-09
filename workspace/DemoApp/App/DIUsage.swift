import Combine
import DependencyKit
import Foundation
import NetworkClient

class DIUsage: ObservableObject {
    var disposeBag = [AnyCancellable]()
    init() {}
    
    func diagnostic() -> [String] {
        var output: [String] = []
        let root = RootResource(injecting: NilResource())
        let levelOne = root.levelOneResource
        let levelTwo = levelOne.levelTwoResource
        let levelThree = levelTwo.levelThreeResource
        output.append("_____ Root _____")
        output.append("explicitPassthrough: <\(root.explicitPassthrough)>")
        output.append("modified: <\(root.modified)>")
        output.append("recreated: <\(root.recreated)>")
        output.append("implicitPassthrough: <\(root.implicitPassthrough)>")
        output.append("")
        output.append("_____ Level One _____")
        output.append("explicitPassthrough: <\(levelOne.explicitPassthrough)>")
        output.append("modified: <\(levelOne.modified)>")
        output.append("recreated: <\(levelOne.recreated)>")
        output.append("implicitPassthrough (not available): <N/A>")
        output.append("")
        output.append("_____ Level Two _____")
        output.append("explicitPassthrough: <\(levelTwo.explicitPassthrough)>")
        output.append("modified: <\(levelTwo.modified)>")
        output.append("recreated: <\(levelTwo.recreated)>")
        output.append("implicitPassthrough (made available to satisfy LevelThreeRequirements): <\(levelThree.implicitPassthrough)>")
        output.append("")
        output.append("_____ Level Three _____")
        output.append("explicitPassthrough: <\(levelThree.explicitPassthrough)>")
        output.append("modified: <\(levelThree.modified)>")
        output.append("recreated: <\(levelThree.recreated)>")
        output.append("implicitPassthrough: <\(levelThree.implicitPassthrough)>")
        return output
    }
}
