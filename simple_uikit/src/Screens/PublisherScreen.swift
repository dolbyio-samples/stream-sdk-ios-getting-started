import UIKit
import MillicastSDK

class PublisherViewController: UIViewController {
    
    private lazy var presenter: UIKitPublisherPresenter = {
        UIKitPublisherPresenter(rendererView: rendererView)
    }()
    
    @IBOutlet weak var rendererView: RendererView!
        
    @IBAction func didPressStartPublishing(_ sender: Any) {
        presenter.publish()
    }
    
}

class UIKitPublisherPresenter: PublisherPresenter {

    let rendererView: RendererView
    
    init(rendererView: RendererView) {
        self.rendererView = rendererView
        super.init()
    }
    
    @MainActor
    override func didPublish(track: MCVideoTrack) async {
        self.rendererView.diplayTrack(track: track)
    }
}
