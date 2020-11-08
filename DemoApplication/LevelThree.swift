import Foundation

// Level Three requires a 'FinalThoughts' type.
protocol LevelThreeDependency: DependencyBase.LevelThree,
    DIFinalThoughts
{}

// The Component defines a methond on itself that isn't required by any downstream dependencies.
// The method has access to 'finalThoughts' which is defined only in RootComponent, and passed down through codegnenerated Fills.
class LevelThreeComponent<T: LevelThreeDependency>: Component<T> {

    func show() {
        print(dependency.finalThoughts)
    }

}
