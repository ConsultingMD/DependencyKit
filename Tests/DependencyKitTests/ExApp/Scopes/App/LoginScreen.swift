import Combine
import Foundation

final class LogInScreen: EXView {

    private let networkClient: UnauthenticatedNetworkClient
    private let authSubject: CurrentValueSubject<AuthToken?, Never>

    init(networkClient: UnauthenticatedNetworkClient,
         authSubject: CurrentValueSubject<AuthToken?, Never>) {
        self.networkClient = networkClient
        self.authSubject = authSubject
    }

    /// MARK: View Lifecycle Behavior
    private var cancellables = Set<AnyCancellable>()

    override func didPush() {
        userInputSubject
            .compactMap {
                guard case .submit(let email, let password) = $0
                else { return nil }
                return (email, password)
            }
            .setFailureType(to: Error.self)
            .flatMap { (email, password) in
                self.networkClient.login(username: email, password: password)
            }
            .sink(receiveCompletion: { _ in },
                  receiveValue: { response in
                self.authSubject.send(response.token)
            })
            .store(in: &cancellables)
    }

    override func willPop() {
        super.willPop()
        cancellables.forEach { $0.cancel() }
    }

    /// MARK: User Input Modeling
    enum UserInput {
        case submit(email: String, password: String)
    }

    private let userInputSubject = PassthroughSubject<UserInput, Never>()

    func userInput(_ input: UserInput) {
        userInputSubject.send(input)
    }

}
