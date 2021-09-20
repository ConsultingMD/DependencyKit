import Combine
import Foundation

protocol ProfileScreenListener: AnyObject {
    func dismissProfile()
}

final class ProfileScreen: EXView {

    private let logOutScreenBuilder: (LogOutScreenListener) -> EXViewType
    private let networkClient: AuthenticatedNetworkClient
    private weak var listener: ProfileScreenListener?

    init(logOutScreenBuilder: @escaping (LogOutScreenListener) -> EXViewType,
         networkClient: AuthenticatedNetworkClient,
         listener: ProfileScreenListener) {
        self.logOutScreenBuilder = logOutScreenBuilder
        self.networkClient = networkClient
        self.listener = listener
    }

    /// MARK: View Lifecycle Behavior
    private var cancellables = Set<AnyCancellable>()

    override func didPush() {
        networkClient.fetchProfileInfo()
            .map { Optional($0) }
            .prepend(.none)
            .sink(receiveCompletion: { completion in
                if case .failure(_) = completion {
                    self.setupUI(with: "Error loading your profile.")
                }
            }, receiveValue: { response in
                self.setupUI(with: response?.email)
            })
            .store(in: &cancellables)

        userInputSubject
            .sink { input in

                self.popChild()

                switch input {
                case .dismissProfileAction:
                    self.listener?.dismissProfile()
                case .showLogOutScreenAction:
                    let view = self.logOutScreenBuilder(self)
                    self.push(child: view)
                case .dismissLogOutScreenAction:
                    // We only needed to pop the log out screen.
                    break
                }
            }
            .store(in: &cancellables)
    }

    private func setupUI(with value: String?) {
        let /*label*/_ = value ?? "Loading..."
        /* show label on screen */
    }

    override func willPop() {
        super.willPop()
        cancellables.forEach { $0.cancel() }
    }

    /// MARK: User Input Modeling
    enum UserInput {
        case dismissProfileAction
        case showLogOutScreenAction
        case dismissLogOutScreenAction
    }

    private let userInputSubject = PassthroughSubject<UserInput, Never>()

    func userInput(_ input: UserInput) {
        userInputSubject.send(input)
    }
}

extension ProfileScreen: LogOutScreenListener {
    func cancelLogout() {
        userInputSubject.send(.dismissLogOutScreenAction)
    }
}
