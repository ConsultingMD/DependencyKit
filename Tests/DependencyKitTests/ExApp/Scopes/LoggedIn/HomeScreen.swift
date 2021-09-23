import Combine
import Foundation

final class HomeScreen: EXView {

    private let profileScreenBuilder: (ProfileScreenListener) -> EXViewType
    private let logOutScreenBuilder: (LogOutScreenListener) -> EXViewType
    private let supportScreenBuilder: (SupportScreenListener) -> EXViewType

    init(profileScreenBuilder: @escaping (ProfileScreenListener) -> EXViewType,
         logOutScreenBuilder: @escaping (LogOutScreenListener) -> EXViewType,
         supportScreenBuilder: @escaping (SupportScreenListener) -> EXViewType) {
        self.profileScreenBuilder = profileScreenBuilder
        self.logOutScreenBuilder = logOutScreenBuilder
        self.supportScreenBuilder = supportScreenBuilder
    }

    /// MARK: View Lifecycle Behavior
    private var cancellables = Set<AnyCancellable>()

    override func didPush() {
        userInputSubject
            .sink { input in

                self.popChild()

                switch input {
                case .showProfileAction:
                    let view = self.profileScreenBuilder(self)
                    self.push(child: view)
                case .showLogOutScreenAction:
                    let view = self.logOutScreenBuilder(self)
                    self.push(child: view)
                case .showSupportAction:
                    let view = self.supportScreenBuilder(self)
                    self.push(child: view)
                case .dismissLogOutScreenAction,
                        .dismissSupportAction,
                        .dismissProfileScreenAction:
                    // We only needed to pop the log out screen.
                    break
                }
            }
            .store(in: &cancellables)
    }

    override func willPop() {
        super.willPop()
        cancellables.forEach { $0.cancel() }
    }

    /// MARK: User Input Modeling
    enum UserInput {
        case showProfileAction
        case showLogOutScreenAction
        case showSupportAction
        case dismissLogOutScreenAction
        case dismissProfileScreenAction
        case dismissSupportAction
    }

    private let userInputSubject = PassthroughSubject<UserInput, Never>()

    func userInput(_ input: UserInput) {
        userInputSubject.send(input)
    }
}

extension HomeScreen: ProfileScreenListener {
    func dismissProfile() {
        userInputSubject.send(.dismissProfileScreenAction)
    }
}

extension HomeScreen: LogOutScreenListener {
    func cancelLogout() {
        userInputSubject.send(.dismissLogOutScreenAction)
    }
}

extension HomeScreen: SupportScreenListener {
    func cancelSupport() {
        userInputSubject.send(.dismissSupportAction)
    }
}
