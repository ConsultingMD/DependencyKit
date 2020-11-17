//
//  ContentView.swift
//  Shared
//
//  Created by az on 2020-11-17.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        let usage = DIUsage()
        let diagnostic = usage.diagnostic()
        return Text(diagnostic.joined(separator: "\n"))
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
