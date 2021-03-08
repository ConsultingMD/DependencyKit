import Combine
import DependencyKit
import Foundation
import NetworkClient

class DIUsage: ObservableObject {
    var disposeBag = [AnyCancellable]()
    init() {}
    
    func diagnostic() -> [String] {
        var output: [String] = []
        let root = RootResource(injecting: NilResource())
        let levelOne = root.levelOneResource
        let levelTwo = levelOne.levelTwoResource
        print(levelTwo.explicitPassthrough)
        print(levelTwo.modified)
        print(levelTwo.recreated)
        //print(levelTwo.implicitPassthrough)
        output.append(
            """
                init
            """)
//        root.networkClient.get(url: URL(string: "https://google.com")!)
//            .sink { _ in }
//                receiveValue: { _ in }
//            .store(in: &disposeBag)
        return output
    }
}
