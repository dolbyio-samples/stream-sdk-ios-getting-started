import UIKit
import MillicastSDK

class PublisherViewController: UIViewController {
    
    private lazy var presenter: UIKitPublisherPresenter = {
        UIKitPublisherPresenter(
            publisherManager: PublisherManagerImpl(),
            rendererView: rendererView
        )
    }()
    
    @IBOutlet weak var rendererView: RendererView!
        
    @IBAction func didPressStartPublishing(_ sender: Any) {
        presenter.publish()
    }
    
}

class UIKitPublisherPresenter: PublisherPresenter {

    let rendererView: RendererView
    
    init(publisherManager: PublisherManager, rendererView: RendererView) {
        self.rendererView = rendererView
        super.init(publisherManager: publisherManager)
    }
    
    override func didPublish(track: MCVideoTrack) {
        DispatchQueue.main.async {
            self.rendererView.diplayTrack(track: track)
        }
    }
}
