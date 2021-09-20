import Combine
import Foundation

final class AppStartScreen: EXView {

    private let loginScreenBuilder: () -> EXViewType
    private let homeScreenBuilder: (AuthToken) -> EXViewType
    private let authPublisher: AnyPublisher<AuthToken?, Never>

    init(loginScreenBuilder: @escaping () -> EXViewType,
         homeScreenBuilder: @escaping (AuthToken) -> EXViewType,
         authPublisher: AnyPublisher<AuthToken?, Never>) {
        self.loginScreenBuilder = loginScreenBuilder
        self.homeScreenBuilder = homeScreenBuilder
        self.authPublisher = authPublisher
    }

    /// MARK: View Lifecycle Behavior
    private var cancellables = Set<AnyCancellable>()

    override func didPush() {
        authPublisher
            .combineLatest(userInputPublisher.prepend(nil))
            .sink { token, userInput in
                // Dismiss any displayed screens.
                self.popChild()
                switch (token, userInput) {
                case (.some(let token), _):
                    let view = self.homeScreenBuilder(token)
                    self.push(child: view)
                case (.none, .goToLoginAction):
                    let view = self.loginScreenBuilder()
                    self.push(child: view)
                case (.none, .goToRegisterAction):
                    fatalError("unimplemented!")
                case (.none, .none):
                    // We only had to pop
                    break
                }
            }.store(in: &cancellables)
    }

    override func willPop() {
        super.willPop()
        cancellables.forEach { $0.cancel() }
    }

    /// MARK: User Input Modeling
    enum UserInput {
        case goToLoginAction
        case goToRegisterAction
    }

    private let userInputSubject = PassthroughSubject<UserInput?, Never>()
    private var userInputPublisher: AnyPublisher<UserInput?, Never> {
        userInputSubject.eraseToAnyPublisher()
    }

    func userInput(_ input: UserInput) {
        userInputSubject.send(input)
    }

}
