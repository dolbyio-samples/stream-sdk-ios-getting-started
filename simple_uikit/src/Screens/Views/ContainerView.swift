import UIKit
import MillicastSDK

class RendererView: UIView {
    
    let renderer: MCIosVideoRenderer = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func diplayTrack(track: MCVideoTrack) {
        track.add(renderer)
        replaceChildView(newView: renderer.getView())
    }
    
    private func replaceChildView(newView: UIView) {
        for view in subviews {
            view.removeFromSuperview()
        }
        newView.frame = bounds
        newView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(newView)
    }
}
