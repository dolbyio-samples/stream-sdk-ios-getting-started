import Foundation
import MillicastSDK
import AVFoundation
import AVFAudio
import OSLog

// MARK:  SubscriptionManager

protocol SubscriptionManager {
    func subscribe() -> Subscription
}

final class SubscriptionManagerImpl: SubscriptionManager {
        
    init() { }
    
    func subscribe() -> Subscription {
        return SubscriptionImpl()
    }
}

// MARK: - Subscription

protocol SubscriptionDelegate: AnyObject {
    func videoTrackCreated(_ videoTrack: MCVideoTrack) async
}

protocol Subscription: AnyObject {
    var delegate: SubscriptionDelegate? { get set }
    func start() async throws
    func stop() async throws
}

private final class SubscriptionImpl: Subscription {
    
    weak var delegate: SubscriptionDelegate?
    
    private var subscriber: MCSubscriber?
        
    func start() async throws {
        
        // ---------------------------------------------------------
        // 1. Configure the audio session
        // ---------------------------------------------------------

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .videoChat,
            options: [.mixWithOthers, .allowBluetoothA2DP]
        )
        try session.setActive(true)

        // ---------------------------------------------------------
        // 2. Create a subscriber
        // ---------------------------------------------------------
        
        let subscriber = MCSubscriber()

        // Keep a reference to the subscriber
        self.subscriber = subscriber

        Task {
            for await track in subscriber.tracks() {
                switch track {
                case .audio(track: let audioTrack, mid: _):
                    audioTrack.enable(true)
                case .video(track: let videoTrack, mid: _):
                    videoTrack.enable(true)
                    await self.delegate?.videoTrackCreated(videoTrack)
                }
            }
        }
        
        // ---------------------------------------------------------
        // 3. Set up credentials
        // ---------------------------------------------------------

        let credentials = MCSubscriberCredentials()
        credentials.accountId =  "<#accout_id#>"; // The ID of your Dolby.io Real-time Streaming account
        credentials.streamName = "<#stream_name#>"; // The name of the stream you want to subscribe to
        credentials.apiUrl
            = "https://director.millicast.com/api/director/subscribe"; // The subscribe API URL

        try await subscriber.setCredentials(credentials)

        //---------------------------------------------------------
        // 4. Connect to the Dolby.io backend
        // ---------------------------------------------------------
        
        try await subscriber.connect()
            
        // ---------------------------------------------------------
        // 5. Configure the viewer by setting your preferred options
        // ---------------------------------------------------------

        let subscriberOptions = MCClientOptions()

//        subscriberOptions.pinnedSourceId
//            = "MySource"; // The main source that will be received by the default media stream
//        subscriberOptions.multiplexedAudioTrack
//            = 3; // Enables audio multiplexing and denotes the number of audio tracks to receive
//                 // as Voice Activity Detection (VAD) multiplexed audio
//        subscriberOptions.excludedSourceId
//            = [ "excluded" ] // Audio streams that should not be included in the multiplex, for
//                             // example your own audio stream

        // Set the selected options
        
        // ---------------------------------------------------------
        // 6. Subscribe to the streamed content
        // ---------------------------------------------------------

            try await subscriber.subscribe(with: subscriberOptions)
    }
    
    func stop() async throws {
        
        let session = AVAudioSession.sharedInstance()
        try session.setActive(false)

        try await subscriber?.unsubscribe()
        try await subscriber?.disconnect()
    }
}
