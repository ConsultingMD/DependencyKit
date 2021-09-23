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

        // Despite not directly being owned by us, the app delegate, or the screens,
        // these resources must exist through builder closure retains — and are used
        // to build screens.
        XCTAssertNotNil(rootRef)
        XCTAssertNotNil(appRef)

        // Repeatedly: Assert the top view of the view stack, and then navigate given it.
        // Simulate and follow the user journey through login, a profile view, some screen
        // dismissals, and a logout.
        appDelegate.top(assertingAs: AppStartScreen.self)
            .userInput(.goToSupportAction)

        // Use testing hooks on the support screen to check assumptions about Resources
        let supportScreen = appDelegate.top(assertingAs: SupportScreen.self)
        weak var supportResourceOneRef = supportScreen.resourceForTesting
        XCTAssertNil(supportResourceOneRef, "the support resource, passed to the support screen for testing, is never captured and so should be nil")
        weak var appRefViaSupportScreen = supportScreen.resourcesInjectedForTesting
        XCTAssert(appRefViaSupportScreen! === appRef! as AnyObject, "The support screen is given a reference to its resource's injected for testing. That should match the app resource reference.")
        supportScreen.userInput(.cancelSupportAction)
        appDelegate.top(assertingAs: AppStartScreen.self)
            .userInput(.goToLoginAction)
        appDelegate.top(assertingAs: LogInScreen.self)
            .userInput(.submit(email: "any@example.com", password: "any"))
        appDelegate.top(assertingAs: HomeScreen.self)
            .userInput(.showSupportAction)

        // Use testing hooks on the support screen to check assumptions about Resources
        let supportScreen2 = appDelegate.top(assertingAs: SupportScreen.self)
        weak var supportResourceTwoRef = supportScreen2.resourceForTesting
        XCTAssertNil(supportResourceTwoRef, "the support resource, passed to the support screen for testing, is never captured and so should be nil")
        weak var loggedInResourceRefViaSupportScreen = supportScreen.resourcesInjectedForTesting
        XCTAssertNotNil(loggedInResourceRefViaSupportScreen, "The support screen is given a reference to its resource's injected for testing. That should be the logged in resource—which is captured in builders and should be non-nil.")
        appDelegate.top(assertingAs: SupportScreen.self)
            .userInput(.cancelSupportAction)

        // Continue navigating through screens.
        appDelegate.top(assertingAs: HomeScreen.self)
            .userInput(.showProfileAction)
        appDelegate.top(assertingAs: ProfileScreen.self)
            .userInput(.dismissProfileAction)
        appDelegate.top(assertingAs: HomeScreen.self)
            .userInput(.showLogOutScreenAction)
        appDelegate.top(assertingAs: LogOutScreen.self)
            .userInput(.cancelLogoutAction)
        appDelegate.top(assertingAs: HomeScreen.self)
            .userInput(.showProfileAction)
        appDelegate.top(assertingAs: ProfileScreen.self)
            .userInput(.showLogOutScreenAction)
        appDelegate.top(assertingAs: LogOutScreen.self)
            .userInput(.logOutAction)
        _ = appDelegate.top(assertingAs: LogInScreen.self)
        // We've now navigated through all the screens.

        // Pop the root view to end view lifecycle based 'userInput' subscriptions.
        appDelegate.popRootView()

        // No screens exist.
        // Our previously retained Resources should all have been released when their
        // capturing builders were released (with their owning screens).
        XCTAssertNil(rootRef)
        XCTAssertNil(appRef)
        XCTAssertNil(loggedInResourceRefViaSupportScreen)
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

    func top<T>(assertingAs: T.Type) -> T {
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
