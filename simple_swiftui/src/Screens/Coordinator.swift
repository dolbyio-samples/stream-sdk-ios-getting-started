import SwiftUI
import MillicastSDK

final class CoordinatorImpl {
    
    func mainMenuScreen() -> some View {
        return MainMenuScreen(
            subscriberView: self.createSubscriberScreen(),
            publisherView: self.createPublisherScreen()
        )
    }
    
    func createSubscriberScreen() -> some View {
        return SubscriberScreen(viewModel: SubscriberViewModel()) { track, mirror in
            self.millicastVideoView(track: track, mirror: mirror)
        }
    }
    
    func createPublisherScreen() -> some View {
        return PublisherScreen(viewModel: PublisherViewModel()) { track, mirror in
            self.millicastVideoView(track: track, mirror: mirror)
        }
    }
    
    func millicastVideoView(track: MCVideoTrack, mirror: Bool) -> some View {
        return MillicastVideoView(track:track, mirror:mirror)
    }
}
