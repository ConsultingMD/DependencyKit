import Combine
import DependencyKit
import Foundation

protocol LoggedInRequirements: Requirements {
    var appVersion: String { get }
    var appDomain: URL { get }
    var authSubject: CurrentValueSubject<AuthToken?, Never> { get }
}

struct LoggedInParameters{
    let token: String
}

final class LoggedInResource<I: LoggedInRequirements>: Resource<I, LoggedInParameters>,
                                                       SupportRequirements {
    var supportIdentifier: SupportIdentifier {
        .loggedInUser(token: parameters.token)
    }

    private let networkCache = NetworkCacheImpl()

    var authenticatedClient: AuthenticatedNetworkClient {
        cached {
            AuthenticatedNetworkClientImpl(token: parameters.token,
                                           url: injected.appDomain,
                                           appVersion: injected.appVersion,
                                           cache: networkCache)
        }
    }

}

extension LoggedInResource {

    func buildProfileScreen(listener: ProfileScreenListener) -> EXViewType {
        ProfileScreen(logOutScreenBuilder: buildLogOutScreen(listener:),
                      networkClient: authenticatedClient,
                      listener: listener)
    }

    func buildHomeScreen() -> EXViewType {
        HomeScreen(profileScreenBuilder: buildProfileScreen(listener:),
                   logOutScreenBuilder: buildLogOutScreen(listener:),
                   supportScreenBuilder: buildSupportScreen(listener:))
    }

    func buildLogOutScreen(listener: LogOutScreenListener) -> EXViewType {
        LogOutScreen(networkClient: authenticatedClient,
                     authSubject: injected.authSubject,
                     listener: listener)
    }
}

extension LoggedInResource {
    func supportResource() -> SupportResource<LoggedInResource> {
        SupportResource(injecting: self)
    }

    func buildSupportScreen(listener: SupportScreenListener) -> SupportScreen {
        supportResource().buildSupportScreen(listener: listener)
    }
}
