import XCTest
import Combine
import DependencyKit

final class DependencyKitTests: XCTestCase {
    
    func testUsage() {
        var rootResource: TestRootResource! = TestRootResource()
        var appResource: AppResource! = AppResource(injecting: rootResource!)
        weak var rootRef = rootResource
        weak var appRef = appResource
        let appDelegate: EXAppDelegate = EXAppDelegate()
        // Push the root view to trigger the view lifecycle calls and and subscriptions
        // for 'userInput' observation.
        appDelegate.push(rootView: appResource.buildAppStartScreen())
        rootResource = nil
        appResource = nil

        // Despite not directly being owned by us, the app delegate, or the screens
        // the resources must exist through closure retains in order to build things.
        XCTAssertNotNil(rootRef)
        XCTAssertNotNil(appRef)

        // Repeatedly: Assert the top view of the view stack, and then navigate given it.
        // Simulate and follow the user journey through login, a profile view, some screen
        // dismissals, and a logout.
        appDelegate.top(as: AppStartScreen.self)
            .userInput(.goToLoginAction)
        appDelegate.top(as: LogInScreen.self).userInput(
            .submit(email: "any@example.com", password: "any"))
        appDelegate.top(as: HomeScreen.self)
            .userInput(.showProfileAction)
        appDelegate.top(as: ProfileScreen.self)
            .userInput(.dismissProfileAction)
        appDelegate.top(as: HomeScreen.self)
            .userInput(.showLogOutScreenAction)
        appDelegate.top(as: LogOutScreen.self)
            .userInput(.cancelLogoutAction)
        appDelegate.top(as: HomeScreen.self)
            .userInput(.showProfileAction)
        appDelegate.top(as: ProfileScreen.self)
            .userInput(.showLogOutScreenAction)
        appDelegate.top(as: LogOutScreen.self)
            .userInput(.logOutAction)
        _ = appDelegate.top(as: LogInScreen.self)
        // We've now navigated through all the screens.

        // Pop the root view to end view lifecycle based 'userInput' subscriptions.
        appDelegate.popRootView()

        // No screens exist. Our Resources should all be gone.
        XCTAssertNil(rootRef)
        XCTAssertNil(appRef)
        // Note: We don't have access to test the LoggedInResource.

    }


    static var allTests = [
        ("testUsage", testUsage),
    ]
}

private final class TestRootResource: Resource<NilResource, ()>,
                                      AppRequirements {
    let appVersion = "0.0.1"
    let appDomain = URL(string: "https://example.com")!
}

extension EXAppDelegate {

    func top<T>(as: T.Type) -> T {
        XCTAssertNotNil(rootView?.lastChild() as? T)
        return rootView!.lastChild() as! T
    }
}

extension EXViewType {
    func lastChild() -> EXViewType {
        if let child = displayedChild {
            return child.lastChild()
        } else {
            return self
        }
    }
}
