//
//  ContentView.swift
//  IosStudy
//
//  Created by mathmaster on 8/5/24.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationStack {
            NavigationLink(destination: SocialLoginContentView()) {
                Text("Social Login")
            }
            NavigationLink(destination: ScrollContentView()) {
                Text("Scroll")
            }
            NavigationLink(destination: SwiftDataContentView()) {
                Text("SwiftData")
            }
        }
    }
}

#Preview {
    ContentView()
}
