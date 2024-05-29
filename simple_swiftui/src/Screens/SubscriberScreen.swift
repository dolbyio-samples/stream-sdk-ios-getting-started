import MillicastSDK
import SwiftUI
import OSLog

struct SubscriberScreen<VM: SubscriberViewModelType, MVV: View>: View {
        
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
            if let track = viewModel.track {
                millicastVideoView(track, false).padding()
            } else {
                ProgressView()
            }
        }
        .onAppear(perform: {
            viewModel.subscribe()
        })
        .onDisappear(perform: {
            viewModel.unsubscribe()
        })
        .navigationTitle("Subscriber")
    }
}

#if SHOW_PREVIEW

private final class SubscriberViewModel_Preview: SubscriberViewModelType {
    @Published var track: Int? = 1
    func subscribe() {}
    func unsubscribe() {}
}

#Preview {
    NavigationView {
        SubscriberScreen(
            viewModel: SubscriberViewModel_Preview(),
            millicastVideoView: { (_, _) in Text("Video view").background(Color.red) }
        )
    }
}

#endif
