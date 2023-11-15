import MillicastSDK
import SwiftUI

struct SubscriberScreen: View {
    
    @StateObject private var subscriptionPresenter: SwiftUISubscriptionPresenter
    @Environment(\.coordinator) private var coordinator

    init(subscriptionPresenter: SwiftUISubscriptionPresenter) {
        _subscriptionPresenter = StateObject(wrappedValue: subscriptionPresenter)
    }
    
    var body: some View {
        VStack {
            if let track = subscriptionPresenter.track {
                coordinator.millicastVideoView(track: track, mirror: false).padding()
            } else {
                ProgressView()
            }
        }
        .onAppear(perform: {
            subscriptionPresenter.subscribe()
        })
        .onDisappear(perform: {
            subscriptionPresenter.unsubscribe()
        })
        .navigationTitle("Playback")
    }
}

protocol SubscriberScreenDelegate {
    func millicastVideoView(track: MCVideoTrack, mirror: Bool) -> AnyView
}

class SwiftUISubscriptionPresenter: SubscriptionPresenter, ObservableObject {
    
    @Published var track: MCVideoTrack?
    
    override func videoTrackCreated(_ videoTrack: MCVideoTrack) {
        track = videoTrack
    }
}

#if SHOW_PREVIEW
#Preview {
    NavigationView {
        SubscriberScreen(subscriptionPresenter: SwiftUISubscriptionPresenter(
            subscriptionManager: previewCoordinator.subscriptionManager
        ))
    }
    .environment(\.coordinator, previewCoordinator)
}
#endif
