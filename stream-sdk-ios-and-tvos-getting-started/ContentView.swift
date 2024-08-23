//
//  ContentView.swift
//  stream-sdk-ios-getting-started
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            List {
#if !os(tvOS)
                NavigationLink("Publisher") {
                    PublisherView()
                }
#endif
                NavigationLink("Subscriber") {
                    SubscriberView()
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
