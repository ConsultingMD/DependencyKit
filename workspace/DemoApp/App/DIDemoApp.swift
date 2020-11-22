import SwiftUI

@main
struct DIDemoApp: App {
    @StateObject private var usage = DIUsage()
    var body: some Scene {
        WindowGroup {
            ContentView(usage: usage)
        }
    }
}
