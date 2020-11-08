import Foundation

// Instantiate a Root which requires no real dependency.
let root = RootComponent(dependency: EmptyComponent())
print(root.name)

// LevelOne can only be instantiated with a component like root, which satisfies its dependencies.
let levelOne = LevelOneComponent(dependency: root)
print(levelOne.name)

// LevelTwo can only be instantiated with a component like LevelOne, which satisfies its dependencies.
let levelTwo = LevelTwoComponent(dependency: levelOne)

// LevelTwo can be exposed to other Application code exposing only a subset of its dependencies. 
let levelTwoDepPassedToConsumerAtThisLevel: LevelTwoViewModelDependencies = levelTwo
print(levelTwoDepPassedToConsumerAtThisLevel.rootName)

// LevelThree can only be instantiated with a component like LevelTwo, which satisfies its dependencies.
let levelThree = LevelThreeComponent(dependency: levelTwo)
levelThree.show()
