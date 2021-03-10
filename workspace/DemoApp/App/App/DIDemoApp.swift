import SwiftUI

@main
struct DIDemoApp: App {
    @StateObject private var usage = DIUsage()
    var body: some Scene {
        WindowGroup {
            ContentView(usage: usage, diagnostic: usage.diagnostic().joined(separator: "\n"))
                .padding(.all, 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
