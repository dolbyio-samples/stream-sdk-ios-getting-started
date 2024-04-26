import AVKit
import Foundation
import MillicastSDK
import SwiftUI
import OSLog

private class MCIosVideoRendererObserver: NSObject, MCIosVideoRendererDelegate, ObservableObject {
    
    @Published var size: CGSize
    
    init(iosRenderer: MCIosVideoRenderer) {
        size = CGSize(fw: iosRenderer.getWidth(), fh: iosRenderer.getHeight())
        super.init()
        iosRenderer.delegate = self
    }
    func didChangeVideoSize(_ size: CGSize) {
        self.size = size
    }
}

struct MillicastVideoView: View {

    let track: MCVideoTrack
    let mirror: Bool
        
    private let iosRenderer: MCIosVideoRenderer
    @ObservedObject private var iosRendererObserver: MCIosVideoRendererObserver
    
    init(track: MCVideoTrack, mirror: Bool) {
        iosRenderer = MCIosVideoRenderer(colorRangeExpansion: false)
        iosRendererObserver = MCIosVideoRendererObserver(iosRenderer: iosRenderer)
        self.track = track
        self.mirror = mirror
    }
    var body: some View {
        GeometryReader { geometry in
            let vidoeRendererFrame = calculateVideoRendererFrame(geometry: geometry)
            VStack {
                Spacer().frame(height: vidoeRendererFrame.origin.y)
                HStack {
                    Spacer().frame(width: vidoeRendererFrame.origin.x)
                    VideoRenderer(iosRenderer: iosRenderer, track: track, mirror: mirror)
                        .frame(
                            width: vidoeRendererFrame.size.width,
                            height: vidoeRendererFrame.size.height
                        )
                    Spacer()
                }
                Spacer()
            }
        }
    }
    
    func calculateVideoRendererFrame(geometry: GeometryProxy) -> CGRect {
        
        os_log(.debug, log: log, "MillicastVideoView: innerViewFrame(geometry: GeometryProxy) started")
        
        var rendererSize = iosRendererObserver.size
        let parentSize = geometry.size

        os_log(.debug, log: log, "MillicastVideoView: rendererSize width: %f, height %f", rendererSize.width, rendererSize.height)
        
        os_log(.debug, log: log, "MillicastVideoView: parentSize width: %f, height %f", parentSize.width, parentSize.height)
        
        if rendererSize.width <= 0 { rendererSize.width = 1 }
        if rendererSize.height <= 0 { rendererSize.height = 1 }
        
        let rendererAspectRatio = rendererSize.aspectRatio()
        let parentAspectRatio = parentSize.aspectRatio()

        let frame: CGRect
        if rendererAspectRatio > parentAspectRatio {
            let viewSize = CGSize(
                width: parentSize.height / rendererAspectRatio,
                height: parentSize.height
            )
            let viewOrigin = CGPoint(x: (parentSize.width - viewSize.width) / 2, y: 0)
            frame = CGRect(origin: viewOrigin, size: viewSize)
        } else {
            let viewSize = CGSize(
                width: parentSize.width,
                height: parentSize.width * rendererAspectRatio
            )
            let viewOrigin = CGPoint(x: 0, y: (parentSize.height - viewSize.height) / 2)
            frame = CGRect(origin: viewOrigin, size: viewSize)
        }
        
        os_log(.debug, log: log, "MillicastVideoView: viewSize width: %f, height %f", frame.size.width, frame.size.height)
        return frame
    }
}

private class ContainerUIView: UIView {
    init(childView: UIView) {
        super.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        childView.frame = self.bounds
        childView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(childView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func replaceChildView(newView: UIView) {
        for view in subviews {
            view.removeFromSuperview()
        }
        newView.frame = bounds
        newView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(newView)
    }
}

private struct VideoRenderer: UIViewRepresentable {
    
    private let iosRenderer: MCIosVideoRenderer
    private let iosRendererView: UIView

    init(iosRenderer: MCIosVideoRenderer, track: MCVideoTrack, mirror: Bool) {
        self.iosRenderer = iosRenderer
        guard let rendererView = iosRenderer.getView() else {
            fatalError("Could not retrieve view from renderer.")
        }
        iosRendererView = rendererView
        iosRendererView.contentMode = .scaleAspectFit
        if mirror {
            iosRendererView.transform = CGAffineTransformMakeScale(-1, 1)
        } else {
            iosRendererView.transform = .identity
        }
        track.add(iosRenderer)
    }

    func makeUIView(context: Context) -> UIView {
        return ContainerUIView(childView: iosRendererView)
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let containerView = uiView as? ContainerUIView {
            containerView.replaceChildView(newView: iosRendererView)
        }
        print("updateUIView")
    }
}

private extension CGSize {
    
    init(fw: Float, fh: Float) {
        self.init(width: CGFloat(fw), height: CGFloat(fh))
    }
    
    func aspectRatio() -> CGFloat {
        return height / width
    }
}
