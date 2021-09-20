import Foundation

// EXView, Example View, is intended to simulate the fundamentals of
// a view framework's lifecycle methods.
//
// Note: `willPop`/`didPush` map more closely to UIKit's embedded view controller
// `willMove(toParent:)` methods than the `viewWillAppear(_:)` display lifecycle.

protocol EXViewType {
    func push(child: EXViewType)
    func popChild()
    func didPush()
    func willPop()
    var displayedChild: EXViewType? { get }
}

open class EXView: EXViewType {

    var displayedChild: EXViewType?

    func push(child: EXViewType) {
        if displayedChild != nil {
            fatalError("EXView only supports one child view.")
        }
        displayedChild = child
        /* call OS to update screen here */
        child.didPush()
    }

    func popChild() {
        displayedChild?.willPop()
        /* call OS to update screen here */
        displayedChild = nil
    }

    open func didPush() {}

    open func willPop() {
        popChild()
    }

}

final class EXAppDelegate {

    var rootView: EXViewType?

    func push(rootView: EXViewType) {
        self.rootView = rootView
        rootView.didPush()
    }

    func popRootView() {
        rootView?.willPop()
        rootView = nil
    }

}
