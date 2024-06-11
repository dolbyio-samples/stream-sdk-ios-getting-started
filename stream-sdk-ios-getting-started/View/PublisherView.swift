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
    MCVideoSwiftUIView(renderer: .accelerated(renderer))
      .onVideoSizeChange { newSize in
        print("Video size changed: \(newSize)")
      }
    Spacer()
    Button("Publish") {
      Task {
        try await viewModel.publish()
      }
    }
  }
}

#Preview {
    PublisherView()
}
