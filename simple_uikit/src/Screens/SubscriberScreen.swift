import UIKit
import MillicastSDK

class SubscriberViewController: UIViewController {
    
    private lazy var presenter: UIKitSubscriptionPresenter = {
       UIKitSubscriptionPresenter(
        subscriptionManager: SubscriptionManagerImpl(),
        rendererView: rendererView
       )
    }()
    
    @IBOutlet weak var rendererView: RendererView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.subscribe()
    }
}

class UIKitSubscriptionPresenter: SubscriptionPresenter {
    
    private let rendererView: RendererView
    
    init(subscriptionManager: SubscriptionManager, rendererView: RendererView) {
        self.rendererView = rendererView
        super.init(subscriptionManager: subscriptionManager)
    }
    
    @MainActor
    override func videoTrackCreated(_ videoTrack: MCVideoTrack) async {
        self.rendererView.diplayTrack(track: videoTrack)
    }
}
