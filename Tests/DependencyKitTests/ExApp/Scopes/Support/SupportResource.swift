import Combine
import DependencyKit
import Foundation

enum SupportIdentifier {
    case loggedInUser(token: AuthToken)
    case anonymousUser
}


// NOTE: Implemented by two different resources
protocol SupportRequirements: Requirements {
    var supportIdentifier: SupportIdentifier { get }
}

final class SupportResource<I: SupportRequirements>: Resource<I, ()> {

    var supportIdentifier: SupportIdentifier {
        injected.supportIdentifier
    }

}

extension SupportResource {

    func buildSupportScreen(listener: SupportScreenListener) -> SupportScreen {
        SupportScreen(supportIdentifier: supportIdentifier,
                      resourceForTesting: self,
                      resourcesInjectedForTesting: injected as AnyObject,
                      listener: listener)
    }

}
