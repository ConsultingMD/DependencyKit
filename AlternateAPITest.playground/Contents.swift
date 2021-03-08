import UIKit

let root = RootResource(injecting: NilResource())
let levelOne = root.levelOneResource
let levelTwo = levelOne.levelTwoResource
print(levelTwo.explicitPassthrough)
print(levelTwo.modified)
print(levelTwo.recreated)
//print(levelTwo.implicitPassthrough)
