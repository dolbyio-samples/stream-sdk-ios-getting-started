import UIKit
import MillicastSDK

class SubscriberViewController: UIViewController {
    
    private lazy var presenter: UIKitSubscriptionPresenter = {
       UIKitSubscriptionPresenter(rendererView: rendererView)
    }()
    
    @IBOutlet weak var rendererView: RendererView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.subscribe()
    }
}

class UIKitSubscriptionPresenter: SubscriptionPresenter {
    
    private let rendererView: RendererView
    
    init(rendererView: RendererView) {
        self.rendererView = rendererView
        super.init()
    }
    
    @MainActor
    override func videoTrackCreated(_ videoTrack: MCVideoTrack) async {
        self.rendererView.diplayTrack(track: videoTrack)
    }
}
