//
//  SubscriberView.swift
//  stream-sdk-ios-getting-started
//

import SwiftUI
import MillicastSDK

struct SubscriberView: View {
    @StateObject var viewModel: SubscriberViewModel
    @State var renderer: MCAcceleratedVideoRenderer
    init() {
        let renderer = MCAcceleratedVideoRenderer()
        _viewModel = StateObject(wrappedValue: .init(renderer: renderer))
        
        self.renderer = renderer
    }
    var body: some View {
        VStack {
            MCVideoSwiftUIView(renderer: .accelerated(renderer))
                .onVideoSizeChange { newSize in
                    print("Video size changed: \(newSize)")
                }
            Spacer()
            Button(!viewModel.isSubscribed ? "Subscribe" : "Unsubscribe") {
                Task {
                    if !viewModel.isSubscribed {
                        try await viewModel.subscribe()
                    } else {
                        try await viewModel.unsubscribe()
                    }
                }
            }
        }
        .onDisappear {
            Task {
                if viewModel.isSubscribed {
                    try await viewModel.unsubscribe()
                }
            }
        }
    }
}

#Preview {
    SubscriberView()
}
