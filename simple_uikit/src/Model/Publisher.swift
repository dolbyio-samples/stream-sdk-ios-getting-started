import Foundation
import MillicastSDK
import AVFAudio
import OSLog

protocol PublisherDelegate: AnyObject {
    func didPublish(track: MCVideoTrack) async
}

final class Publisher {
    
    weak var delegate: PublisherDelegate?
    
    private var publisher: MCPublisher!
    private var videoSource: MCVideoSource!
    private var videoTrack: MCVideoTrack?
    
    private var audioSessionConfigured: Bool = false

    init() { }
    
    func start() async throws {
        
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
            let audioSource = audioSources[0]
            audioTrack = audioSource.startCapture() as? MCAudioTrack
        }
        
        // Create a video track
        var videoTrack : MCVideoTrack? = nil
        if
            let videoSources = MCMedia.getVideoSources(), // Get an array of available video sources
            !videoSources.isEmpty // There is at least one video source
        {
            // Choose the preferred video source
            let videoSource = videoSources[0]
            
            // Get capabilities of the available video sources, such as
            // width, height, and frame rate of the video sources
            guard let capabilities = videoSource.getCapabilities() else {
              fatalError("No capability is available!") // In production replace with a throw
            }
            
            let capability = capabilities[0] // Get the first capability
            videoSource.setCapability(capability)
            
            // Start video recording and create a video track
            videoTrack = videoSource.startCapture() as? MCVideoTrack
        }
        
        // ---------------------------------------------------------
        // 2. Create the Millicast publisher
        // ---------------------------------------------------------

        // Create a publisher object
        let publisher = MCPublisher()
        
        self.publisher = publisher
        
        
        // ---------------------------------------------------------
        // 3. Authenticate using the Director API
        // ---------------------------------------------------------

        // Get the credentials structure from your publisher instance, fill it in,
        // and set the modified credentials
        let credentials = MCPublisherCredentials()
        credentials.streamName = "<#stream_name#>" // The name of the stream you want to publish
        credentials.token = "<#token#>" // The publishing token
        credentials.apiUrl = "https://director.millicast.com/api/director/publish" // The publish API URL

        try await publisher.setCredentials(credentials)
        
        try await publisher.connect()

        // ---------------------------------------------------------
        // 4. Configure your publishing session
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
//        publisherOptions.sourceId = "MySource"
//        publisherOptions.dtx = true
        
        // Enable stereo
        publisherOptions.stereo = true
        
        
        // ---------------------------------------------------------
        // 5. Add the audio and video track
        // ---------------------------------------------------------

        if let videoTrack = videoTrack {
            await publisher.addTrack(with: videoTrack)
        }
        if let audioTrack = audioTrack {
            await publisher.addTrack(with: audioTrack)
        }
        
        // ---------------------------------------------------------
        // 6. Start publishing
        // ---------------------------------------------------------

        try await publisher.publish(with: publisherOptions)
        
        if let videoTrack = videoTrack {
            await delegate?.didPublish(track: videoTrack)
        }

        // Keep a reference to the video track
        self.videoTrack = videoTrack
    }
    
    func stop() async throws {
        try await publisher.unpublish()
        try await publisher.disconnect()
        let session = AVAudioSession.sharedInstance()
        try session.setActive(false)
    }

}
