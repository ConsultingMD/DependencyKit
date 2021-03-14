import Combine
import DependencyKit
import Foundation
import NetworkClient

class DIUsage: ObservableObject {
    init() {}
    
    private func propertiesDiagnostic<T>(for resource: T, paths: [KeyPath<T, String>]) -> [String] {
        return paths.map { "\($0): '\(resource[keyPath: $0])" }
    }
    
    func diagnostic() -> [String] {
        var output: [String] = []
        let root = ScopeZeroResource(injecting: NilResource())
        let one = root.buildScopeOne()
        let two = one.buildScopeTwo()
        let three = two.buildScopeThree()
        output += [
            "_____ Root _____",
            "explicit: '\(root.explicit)'",
            "implicit: '\(root.implicit)'",
            "modified: '\(root.modified)'",
            "recreated: '\(root.recreated)'",
            "createdLater: < N/A, created in later scope >",
            "duplicated: < N/A, created in later scope >",
            "dropped: '\(root.dropped)'",
            "",
        ]
        output += [
            "_____ One _____",
            "explicit: '\(one.explicit)'",
            "implicit: < Unavailable, not in Requirements. (Passed only implicitly to descendent explicit uses) >",
            "modified: '\(one.modified)'",
            "recreated: '\(one.recreated)'",
            "createdLater: '\(one.createdLater)'",
            "duplicated: < N/A, created in later scope >",
            "dropped: < Unavailable, not in Requirements >",
            "conformance to external module resource requirement: '\(String(describing: one.networkMonitor))'",
            "resource from external module: '\(one.buildNetworkClientResource())'",
            "",
        ]
        output += [
            "_____ Two _____",
            "explicit: '\(two.explicit)'",
            "implicit: '\(two.implicit)'",
            "modified: '\(two.modified)'",
            "recreated: '\(two.recreated)'",
            "createdLater: '\(two.createdLater)'",
            "duplicated: '\(two.duplicated)'",
            "dropped: < Unavailable, not in Requirements >",
            "",
        ]
        output += [
            "_____ Three _____",
            "explicit: '\(three.explicit)'",
            "implicit: '\(three.implicit)'",
            "modified: '\(three.modified)'",
            "recreated: '\(three.recreated)'",
            "createdLater: '\(three.createdLater)'",
            "duplicated: '\(three.duplicated)'",
            "dropped: < Unavailable, not in Requirements >",
            "",
        ]
        return output
    }
}
