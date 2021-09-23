import Combine
import Foundation


protocol SupportScreenListener: AnyObject {
    func cancelSupport()
}

final class SupportScreen: EXView {

    private let supportIdentifier: SupportIdentifier
    /* private — visible to test lifecycle */ weak var resourceForTesting: AnyObject?
    /* private — visible to test lifecycle */  weak var resourcesInjectedForTesting: AnyObject?
    private weak var listener: SupportScreenListener?

    init(supportIdentifier: SupportIdentifier,
         resourceForTesting: AnyObject?,
         resourcesInjectedForTesting: AnyObject?,
         listener: SupportScreenListener?) {
        self.supportIdentifier = supportIdentifier
        self.resourceForTesting = resourceForTesting
        self.resourcesInjectedForTesting = resourcesInjectedForTesting
        self.listener = listener
    }

    /// MARK: View Lifecycle Behavior
    private var cancellables = Set<AnyCancellable>()

    override func didPush() {
        let supportIdentifier = supportIdentifier

        userInputSubject
            .filter { $0 == .supportAction }
            .flatMap { _ in
                Just(supportIdentifier)
            }
            .sink(receiveCompletion: { _ in },
                  receiveValue: { identifier in
                switch identifier {
                case .loggedInUser(_):
                    print("Call +1 (800) 555-1337 for deluxe service support")
                case .anonymousUser:
                    print("Call +1 (800) 555-1336 for service support")
                }
            }).store(in: &cancellables)

        userInputSubject
            .filter { $0 == .cancelSupportAction }
            .sink { _ in
                self.listener?.cancelSupport()
            }.store(in: &cancellables)
    }

    override func willPop() {
        super.willPop()
        cancellables.forEach { $0.cancel() }
    }

    /// MARK: User Input Modeling
    enum UserInput {
        case supportAction
        case cancelSupportAction
    }

    private let userInputSubject = PassthroughSubject<UserInput, Never>()

    func userInput(_ input: UserInput) {
        userInputSubject.send(input)
    }

}
