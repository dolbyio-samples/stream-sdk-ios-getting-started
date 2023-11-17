import Foundation
import MillicastSDK
import AVFAudio
import OSLog

// MARK: PublisherManager

protocol PublisherManager {
    func publish() -> Publisher
}

final class PublisherManagerImpl: PublisherManager {
    
    func publish() -> Publisher {
        return PublisherImpl()
    }
}

// MARK: - Publisher

protocol PublisherDelegate: AnyObject {
    func didPublish(track: MCVideoTrack)
}

protocol Publisher: AnyObject {
    var delegate: PublisherDelegate? { set get }
    func start() throws
    func stop() throws
}

private final class PublisherImpl: Publisher {
    
    weak var delegate: PublisherDelegate?
    
    private var publisher: MCPublisher!
    private var videoSource: MCVideoSource!
    private var videoTrack: MCVideoTrack?
    private var audioSource: MCAudioSource!
    private var audioSessionConfigured: Bool = false

    fileprivate init() { }
    
    func start() throws {
        
        // ---------------------------------------------------------
        // 1. Capture audio and video
        // ---------------------------------------------------------

        // Configure the audio session for capturing
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .videoChat,
            options: [.mixWithOthers, .allowBluetooth, .allowBluetoothA2DP]
        )
        try session.setActive(true)

        // Create an audio track
        var audioTrack : MCAudioTrack? = nil
        if
            let audioSources = MCMedia.getAudioSources(), // Get an array of audio sources
            !audioSources.isEmpty // There is at least one audio source
        {
            // Choose the preferred audio source and start capturing
            audioSource = audioSources[0]
            audioTrack = audioSource.startCapture() as? MCAudioTrack
        } else {
            print("There are no audio sources!")
        }
        
        // Create a video track
        var videoTrack : MCVideoTrack? = nil
        if
            let videoSources = MCMedia.getVideoSources(), // Get an array of available video sources
            !videoSources.isEmpty // There is at least one video source
        {
            // Choose the preferred video source
            videoSource = videoSources[0];
            print(videoSource.getName()!)
            
            // Get capabilities of the available video sources, such as
            // width, height, and frame rate of the video sources
            guard let capabilities = videoSource.getCapabilities() else {
              fatalError("No capability is available!") // In production replace with a throw
            }
            
            let capability = capabilities[0]; // Get the first capability
            videoSource.setCapability(capability);
            
            // Start video recording and create a video track
            videoTrack = videoSource.startCapture() as? MCVideoTrack
        } else {
            print("There are no video sources!")
        }
        
        // ---------------------------------------------------------
        // 2. Publish a stream
        // ---------------------------------------------------------

        // Create a publisher object
        let publisher = MCPublisher.create()
        
        self.publisher = publisher
        
        // Set this class instance as listener of the publisher
        publisher.setListener(self)
        
        // Get the credentials structure from your publisher instance, fill it in,
        // and set the modified credentials
        let credentials = MCPublisherCredentials()
        credentials.streamName = "<stream_name>"; // The name of the stream you want to publish
        credentials.token = "<pub_token>"; // The publishing token
        credentials.apiUrl
            = "https://director.millicast.com/api/director/publish"; // The publish API URL

        publisher.setCredentials(credentials);
        
        // ---------------------------------------------------------
        // 3. Configure your publishing session
        // ---------------------------------------------------------

        let publisherOptions = MCClientOptions()
        
        // Get a list of supported codecs
        if let audioCodecs = MCMedia.getSupportedAudioCodecs() {
            // Choose the preferred audio codec
            publisherOptions.audioCodec = audioCodecs[0]
            
        } else {
            print("No audio codecs available!") // In production replace with proper error handling
        }
        
        if let videoCodecs = MCMedia.getSupportedVideoCodecs() {
            // Choose the preferred video codec
            publisherOptions.videoCodec = videoCodecs[0]
            
        } else {
            print("No video codecs available!") // In production replace with proper error handling
        }

        // To use multi-source, set a source ID of the publisher and
        // enable discontinuous transmission
        publisherOptions.sourceId = "MySource"
        publisherOptions.dtx = true
        
        // Enable stereo
        publisherOptions.stereo = true
        
        // Set the selected options to the publisher
        publisher.setOptions(publisherOptions)
        
        // ---------------------------------------------------------
        // 4. Add the audio and video track
        // ---------------------------------------------------------

        if let videoTrack = videoTrack {
            publisher.add(videoTrack)
        }
        if let audioTrack = audioTrack {
            publisher.add(audioTrack)
        }
                
        // ---------------------------------------------------------
        // 5. Authenticate using the Director API
        // ---------------------------------------------------------

        guard publisher.connect() else {
            fatalError("Connection error could not connect.") // In production replace with a throw
        }
        
        // Keep a reference to the video track
        self.videoTrack = videoTrack
    }
    
    func stop() throws {
        publisher.unpublish()
        publisher.disconnect()
        let session = AVAudioSession.sharedInstance()
        try session.setActive(false)
    }

}

extension PublisherImpl: MCPublisherListener {
    
    // MARK: Lifecycle
    
    func onConnected() {
      
        // ---------------------------------------------------------
        // 6. Start publishing
        // ---------------------------------------------------------

        publisher.publish()
    }
    
    func onPublishing() { 
        // Inform presenter that the video track has been published
        if let videoTrack = videoTrack {
            delegate?.didPublish(track: videoTrack)
        }
    }
    
    func onActive() { }
    
    func onViewerCount(_ count: Int32) { }
    
    func onInactive() { }

    func onDisconnected() { }

    func onStatsReport(_ report: MCStatsReport) { }

    // MARK: Error handling
    
    func onConnectionError(_ status: Int32, withReason reason: String) {
        os_log(.error, log: log, "Connection error status: %i reason: %s", status, reason)
    }
    
    func onPublishingError(_ error: String!) {
        os_log(.error, log: log, "Publishing error: %s", error)
    }
    
    func onSignalingError(_ message: String) {
        os_log(.error, log: log, "Signaling error: %s", message)
    }
}
