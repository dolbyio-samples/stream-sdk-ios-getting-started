import MillicastSDK
import SwiftUI
import OSLog

struct PublisherScreen<VM: PublisherViewModelType, MVV: View>: View {
    
    @ObservedObject private var viewModel: VM
    private let millicastVideoView: (_ track: VM.T, _ mirror: Bool) -> MVV

    init(
        viewModel: VM,
        millicastVideoView: @escaping (_ track: VM.T, _ mirror: Bool) -> MVV
    ) {
        self.viewModel = viewModel
        self.millicastVideoView = millicastVideoView
    }
    
    var body: some View {
        VStack {
            Spacer()
            if let track = viewModel.track {
                millicastVideoView(track, false).padding()
            } else {
                EmptyView()
            }
            Spacer()
            Button("Publish") {
                viewModel.publish()
            }
        }
        .navigationTitle("Publisher")
    }
}


#if SHOW_PREVIEW

private final class PublisherViewModel_Preview: PublisherViewModelType {
    var track: Int?
    func publish() { }
    func unpublish() { }
}

#Preview {
    NavigationView {
        PublisherScreen(
            viewModel: PublisherViewModel_Preview(),
            millicastVideoView: { _, _ in Text("Video view").background(Color.red) }
        )
    }
}

#endif
