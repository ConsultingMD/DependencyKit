import Foundation

// The entrypoint to the Demo Application.
// This Component has no requirements (annotated as EmptyDependency).
// It explicitly satisfies Level One's requirements (LevelOneDependency) providing fields conforming to DIName, and DIRootName.
// It also has other properties which might be used at the root level and/or satisfy requirements beyond Level One.
class RootComponent: Component<EmptyDependency>,
                     LevelOneDependency {
    let rootName = "Root"
    let name = "Root"
    let startupTime = Date(timeIntervalSince1970: 0)
    let finalThoughts = "Could this be less verbose?"
}
