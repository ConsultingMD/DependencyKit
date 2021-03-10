import SwiftUI

struct HeightPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct ContentView: View {
    @ObservedObject var usage: DIUsage
    @State var diagnostic: String
    var body: some View {
        ScrollView {
            TextEditor(text: $diagnostic)
                .font(Font.custom("Monaco", size: 14))
                .lineSpacing(7.0)
                .padding(.all, 0)
        }
        .padding(.all, 0)
    }
}
