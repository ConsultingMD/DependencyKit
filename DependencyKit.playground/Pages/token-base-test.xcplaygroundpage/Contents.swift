//: [Previous](@previous)

import Foundation
// could these be named tokens?
protocol StartupTime { var startupTime: Date { get } }
protocol Name { var name: String { get } }

protocol Parented {
    associatedtype ParentRequirements
    var parentRequirements: ParentRequirements { get }
}

extension Parented where ParentRequirements: StartupTime {
    var startupTime: Date { parentRequirements.startupTime }
}
extension Parented where ParentRequirements: Name {
    var name: String { parentRequirements.name }
}

protocol RootProvisions: StartupTime, Name {}

class TestRootNode: RootProvisions {
    let startupTime = Date()
    let name = "The Root"
}

// Overrides are possible IFF indirect protocols are used
class TestChildNode<T: RootProvisions>: Parented {
    typealias ParentRequirements = T
    let parentRequirements: T
    init(parent: T) {
        parentRequirements = parent
    }
    // override the parent's value
    let name = "Actually, The Child."
}

let root = TestRootNode()
let child = TestChildNode(parent: root)
print(child.startupTime)
print(child.name)

