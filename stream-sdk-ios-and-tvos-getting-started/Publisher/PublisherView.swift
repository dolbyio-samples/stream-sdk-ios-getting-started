//
//  PublisherView.swift
//  stream-sdk-ios-getting-started
//

import SwiftUI
import MillicastSDK

struct PublisherView: View {
    @StateObject var viewModel: PublisherViewModel
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
            Button(!viewModel.isPublishing ? "Publish" : "Unpublish") {
                Task {
                    if !viewModel.isPublishing {
                        try await viewModel.publish()
                    } else {
                        try await viewModel.unpublish()
                    }
                }
            }
        }
        .onDisappear {
            Task {
                if viewModel.isPublishing {
                    try await viewModel.unpublish()
                }
            }
        }
    }
}

#Preview {
    PublisherView()
}
