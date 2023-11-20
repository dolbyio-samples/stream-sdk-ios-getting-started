import SwiftUI
import MillicastSDK

typealias Coordinator =
    MainMenuScreenDelegate &
    SubscriberScreenDelegate &
    PublisherScreenDelegate

struct CoordinatorEnvironmentKey: EnvironmentKey {
    static let defaultValue: Coordinator = CoordinatorImpl()
}

extension EnvironmentValues {
    var coordinator: Coordinator {
        get { self[CoordinatorEnvironmentKey.self] }
        set { self[CoordinatorEnvironmentKey.self] = newValue }
    }
}

final class CoordinatorImpl {
    private(set) lazy var subscriptionManager: SubscriptionManager = SubscriptionManagerImpl()
    private(set) lazy var publisherManager: PublisherManager = PublisherManagerImpl()
}

extension CoordinatorImpl: MainMenuScreenDelegate {
    
    func playerRequested() -> AnyView {
        return AnyView(erasing: SubscriberScreen(
            subscriptionPresenter: SwiftUISubscriptionPresenter(
                subscriptionManager: subscriptionManager
            )
        ))
    }
    
    func recorderRequested() -> AnyView {
        return AnyView(erasing: PublisherScreen(
            presenter: SwiftUIPublisherPresenter(
                publisherManager: publisherManager
            )
        ))
    }
}

extension CoordinatorImpl: SubscriberScreenDelegate, PublisherScreenDelegate {
    func millicastVideoView(track: MCVideoTrack, mirror: Bool) -> AnyView {
        return AnyView(erasing: MillicastVideoView(track:track, mirror:mirror))
    }
}

#if SHOW_PREVIEW

open class PreviewCoordinator: Coordinator {
    
    private(set) lazy var subscriptionManager: SubscriptionManager
        = SubscriptionManagerImpl()
    
    private(set) lazy var publisherManager: PublisherManager = PublisherManagerImpl()
    
    func playerRequested() -> AnyView {
        AnyView(erasing: EmptyView())
    }
    
    func recorderRequested() -> AnyView {
        AnyView(erasing: EmptyView())
    }
    
    func subscriptionSetupScreenDone(
        accountId: String,
        streamName: String,
        credentialsApiUrl: String,
        token: String
    ) -> AnyView {
        AnyView(erasing: EmptyView())
    }
    
    func millicastVideoView(track: MCVideoTrack, mirror: Bool) -> AnyView {
        AnyView(erasing: EmptyView())
    }
    
    func publisherSetupScreenDone(
        streamName: String,
        apiUrl: String,
        token: String
    ) -> AnyView {
        AnyView(erasing: EmptyView())
    }

}

let previewCoordinator = PreviewCoordinator()

#endif
