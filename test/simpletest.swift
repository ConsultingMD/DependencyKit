import Foundation

// INTERFACE

protocol Provisions {}

protocol Speaking: Provisions {
    func say(_ string: String)
}

protocol Thinking: Provisions {
    var thoughts: String { get }
}

// IMPL

class Person: Speaking {
    func say(_ string: String) {
        print("~whispering~: \(string)")
    }
}

class YellingPerson: Speaking {
    func say(_ string: String) {
        print("*shouting*: \(string.uppercased())")
    }
}

class Test<Requirements: Provisions>: Thinking {
    let id = UUID()
    let thoughts: String
    let requirements: Requirements
    init(requirements: Requirements, thoughts: String) {
        self.thoughts = thoughts
        self.requirements = requirements
    }
}

// AUTOGEN EXTENSIONS

extension Thinking where Self == Test<Person> {
    var requirements: Person { requirements }
    func say(_ string: String) { requirements.say(string) }
}

extension Thinking where Self == Test<YellingPerson> {
    var requirements: YellingPerson { requirements }
    func say(_ string: String) { requirements.say(string) }
}

// USAGE

let baseTest = Test(requirements: Person(), thoughts: "i'm pretty normal.")
let altTest = Test(requirements: YellingPerson(), thoughts: "i'm exactly the same as them.")
baseTest.say(baseTest.thoughts)
altTest.say(altTest.thoughts)
