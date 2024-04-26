import MillicastSDK
import SwiftUI

struct PublisherScreen: View {
    
    @ObservedObject private var presenter: SwiftUIPublisherPresenter
    @Environment(\.coordinator) private var coordinator
    
    init(presenter: SwiftUIPublisherPresenter) {
        self.presenter = presenter
    }
    
    var body: some View {
        VStack {
            Spacer()
            if let track = presenter.track {
                coordinator.millicastVideoView(track: track, mirror: false).padding()
            } else {
                EmptyView()
            }
            Spacer()
            Button("Start publishing") {
                presenter.publish()
            }
        }
        .navigationTitle("Publisher")
    }
}

protocol PublisherScreenDelegate {
    func millicastVideoView(track: MCVideoTrack, mirror: Bool) -> AnyView
}


class SwiftUIPublisherPresenter: PublisherPresenter, ObservableObject {
    
    @Published var track: MCVideoTrack?
    
    override func didPublish(track: MCVideoTrack) {
        DispatchQueue.main.async {
            self.track = track
        }
    }
}

#if SHOW_PREVIEW
#Preview {
    NavigationView {
        PublisherScreen(
            presenter: SwiftUIPublisherPresenter(
                publisherManager: previewCoordinator.publisherManager
            )
        )
    }
    .environment(\.coordinator, previewCoordinator)
}
#endif
