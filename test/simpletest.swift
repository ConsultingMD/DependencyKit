import Foundation

// INTERFACE

protocol Speaking: Provisions {
    func say(_ string: String)
}

protocol Thinking: Provisions {
    var thoughts: String { get }
}

// FRAMEWORK

protocol Component {
    associatedtype Requirements 
}

protocol Provisions {}

protocol ComponentProvisions: Component, Provisions {}


class NilComponentProvisions: ComponentProvisions {
    typealias Requirements = NilComponentProvisions
    lazy var requirements = self
}

class ComponentObject<Dep: ComponentProvisions>: Component {
    typealias Requirements = Dep
    let requirements: Requirements
    init(requirements: Dep) {
        self.requirements = requirements
    }
}

// IMPL

// class Person: ComponentObject, Speaking {
//     func say(_ string: String) {
//         print("~whispering~: \(string)")
//     }
// }

// class YellingPerson: ComponentObject, Speaking {
//     func say(_ string: String) {
//         print("*shouting*: \(string.uppercased())")
//     }
// }

class Test: ComponentObject<NilComponentProvisions>, Thinking {
    let id = UUID()
    let thoughts: String
    init(requirements: NilComponentProvisions, thoughts: String) {
        self.thoughts = thoughts
        super.init(requirements: requirements)
    }
}

// AUTOGEN EXTENSIONS

// extension Thinking where Self: Component, Component.Requirements == Person {
//     var requirements: Person { requirements }
//     func say(_ string: String) { requirements.say(string) }
// }

// extension Thinking where Self == Test<YellingPerson> {
//     var requirements: YellingPerson { requirements }
//     func say(_ string: String) { requirements.say(string) }
// }

// USAGE

// let baseTest = Test(requirements: Person(), thoughts: "i'm pretty normal.")
// let altTest = Test(requirements: YellingPerson(), thoughts: "i'm exactly the same as them.")
// baseTest.say(baseTest.thoughts)
// altTest.say(altTest.thoughts)
