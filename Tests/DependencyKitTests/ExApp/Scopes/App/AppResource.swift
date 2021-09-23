import Combine
import DependencyKit
import Foundation

protocol AppRequirements: Requirements {
    var appVersion: String { get }
    var appDomain: URL { get }
}

final class AppResource<I: AppRequirements>: Resource<I, ()>,
                                             LoggedInRequirements,
                                             SupportRequirements {

    let supportIdentifier: SupportIdentifier = .anonymousUser

    let authSubject = CurrentValueSubject<AuthToken?, Never>(nil)

    var appVersion: String { injected.appVersion }

    var appDomain: URL { injected.appDomain }

    var authPublisher: AnyPublisher<AuthToken?, Never> {
        authSubject.eraseToAnyPublisher()
    }

    var unauthenticatedClient: UnauthenticatedNetworkClient {
        cached {
            UnauthenticatedNetworkClientImpl(url: injected.appDomain,
                                             appVersion: injected.appVersion)
        }
    }
}

extension AppResource {

    func buildAppStartScreen() -> EXViewType {
        AppStartScreen(loginScreenBuilder: buildLoginScreen,
                       homeScreenBuilder: buildHomeScreen(token:),
                       supportScreenBuilder: buildSupportScreen(listener:),
                       authPublisher: authPublisher)
    }

    func buildLoginScreen() -> EXViewType {
        LogInScreen(networkClient: unauthenticatedClient,
                    authSubject: authSubject)
    }

    func buildHomeScreen(token: AuthToken) -> EXViewType {
        let resource = loggedInResource(token: token)
        return resource.buildHomeScreen()
    }

    func buildSupportScreen(listener: SupportScreenListener) -> EXViewType {
        let resource = supportResource()
        return resource.buildSupportScreen(listener: listener)
    }
}

extension AppResource {

    func supportResource() -> SupportResource<AppResource> {
        SupportResource(injecting: self)
    }

    func loggedInResource(token: AuthToken) -> LoggedInResource<AppResource> {
        LoggedInResource(injecting: self,
                         parameters: LoggedInParameters(token: token))
    }
}
