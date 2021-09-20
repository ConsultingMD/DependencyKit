import Combine
import Foundation

protocol LogOutScreenListener: AnyObject {
    func cancelLogout()
}

final class LogOutScreen: EXView {

    private let networkClient: AuthenticatedNetworkClient
    private let authSubject: CurrentValueSubject<AuthToken?, Never>
    private weak var listener: LogOutScreenListener?

    init(networkClient: AuthenticatedNetworkClient,
         authSubject: CurrentValueSubject<AuthToken?, Never>,
         listener: LogOutScreenListener) {
        self.networkClient = networkClient
        self.authSubject = authSubject
        self.listener = listener
    }

    /// MARK: View Lifecycle Behavior
    private var cancellables = Set<AnyCancellable>()

    override func didPush() {
        userInputSubject
            .filter { $0 == .logOutAction }
            .setFailureType(to: Error.self)
            .flatMap { _ in
                self.networkClient.logout()
            }
            .sink(receiveCompletion: { _ in },
                  receiveValue: { _ in
                self.authSubject.send(nil)
            }).store(in: &cancellables)

        userInputSubject
            .filter { $0 == .cancelLogoutAction }
            .sink { _ in
                self.listener?.cancelLogout()
            }.store(in: &cancellables)
    }

    override func willPop() {
        super.willPop()
        cancellables.forEach { $0.cancel() }
    }

    /// MARK: User Input Modeling
    enum UserInput {
        case logOutAction
        case cancelLogoutAction
    }

    private let userInputSubject = PassthroughSubject<UserInput, Never>()

    func userInput(_ input: UserInput) {
        userInputSubject.send(input)
    }

}
