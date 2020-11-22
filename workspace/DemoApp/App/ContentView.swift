import SwiftUI

struct ContentView: View {
    @ObservedObject var usage: DIUsage
    var body: some View {
        _ = usage.multiModuleTest()
        let diagnostic = usage.diagnostic()
        return Text(diagnostic.joined(separator: "\n"))
            .padding()
    }
}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
