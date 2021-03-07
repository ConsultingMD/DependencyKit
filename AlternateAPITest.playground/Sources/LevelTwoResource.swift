import Foundation

import Foundation

public protocol LevelTwoRequirements: Requirements {
    var appName: String { get }
}


public class LevelTwoResource<I: LevelTwoRequirements>: Resource<I> {
}
