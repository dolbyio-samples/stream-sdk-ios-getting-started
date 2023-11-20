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
    func videoTrackCreated(_ videoTrack: MCVideoTrack)
}

protocol Subscription: AnyObject {
    var delegate: SubscriptionDelegate? { get set }
    func start() throws
    func stop() throws
}

private final class SubscriptionImpl: Subscription {
    
    weak var delegate: SubscriptionDelegate?
    
    private var subscriber: MCSubscriber?
        
    func start() throws {
        
        // ---------------------------------------------------------
        // 1. Create a subscriber object and configure the audio session
        // ---------------------------------------------------------

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playback,
            mode: .videoChat,
            options: [.mixWithOthers, .allowBluetooth, .allowBluetoothA2DP]
        )
        try session.setActive(true)

        guard let subscriber = MCSubscriber.create() else {
            fatalError("Could not create subscriber.") // In production replace with a throw
        }

        // Keep a reference to the subscriber
        self.subscriber = subscriber

        // ---------------------------------------------------------
        // 2. Listen to the subscriber
        // ---------------------------------------------------------
        
        subscriber.setListener(self)
        
        // ---------------------------------------------------------
        // 3. Set up credentials
        // ---------------------------------------------------------

        let credentials = MCSubscriberCredentials()
        credentials.accountId =  "<account_id>"; // The ID of your Dolby.io Real-time Streaming account
        credentials.streamName = "<stream_name>"; // The name of the stream you want to subscribe to
        credentials.apiUrl
            = "https://director.millicast.com/api/director/subscribe"; // The subscribe API URL

        guard subscriber.setCredentials(credentials) else {
            fatalError("Could not set credentials.") // In production replace with a throw
        }

        // ---------------------------------------------------------
        // 4. Configure the viewer by setting your preferred options
        // ---------------------------------------------------------

        let subscriberOptions = MCClientOptions()

        subscriberOptions.pinnedSourceId 
            = "MySource"; // The main source that will be received by the default media stream
        subscriberOptions.multiplexedAudioTrack 
            = 3; // Enables audio multiplexing and denotes the number of audio tracks to receive
                 // as Voice Activity Detection (VAD) multiplexed audio
        subscriberOptions.excludedSourceId
            = [ "excluded" ] // Audio streams that should not be included in the multiplex, for
                             // example your own audio stream

        // Set the selected options
        subscriber.setOptions(subscriberOptions);
        
        
        //---------------------------------------------------------
        // 5. Connect to the Dolby.io backend
        // ---------------------------------------------------------
        
        guard subscriber.connect() else {
            fatalError("Could not connect.") // In production replace with a throw
        }
    }
    
    func stop() throws {
        
        let session = AVAudioSession.sharedInstance()
        try session.setActive(false)

        subscriber?.unsubscribe()
        subscriber?.disconnect()
    }
}

extension SubscriptionImpl: MCSubscriberListener {
    
    func onConnected() { 
        
        // ---------------------------------------------------------
        // 6. Subscribe to the streamed content
        // ---------------------------------------------------------

        guard subscriber?.subscribe() == true else {
            fatalError("Could not subscribe.") // In production replace with a throw
        }
    }
    
    func onStatsReport(_ report: MCStatsReport) { }
    
    func onViewerCount(_ count: Int32) { }
    
    func onSubscribed() { }
    
    func onVideoTrack(_ track: MCVideoTrack, withMid mid: String) {
        track.enable(true)
        DispatchQueue.main.async {
            self.delegate?.videoTrackCreated(track)
        }
    }
    
    func onAudioTrack(_ track: MCAudioTrack, withMid mid: String) {
        track.enable(true)
    }
    
    func onActive(_ streamId: String, tracks: [String], sourceId: String) { }
    
    func onInactive(_ streamId: String, sourceId: String) { }
    
    func onStopped() { }
    
    func onVad(_ mid: String, sourceId: String) { }
    
    func onLayers(_ mid: String, activeLayers: [MCLayerData], inactiveLayers: [MCLayerData]) { }
    
    func onDisconnected() { 
        subscriber?.setListener(nil)
        subscriber = nil
    }
    
    func onConnectionError(_ status: Int32, withReason reason: String) {
        os_log(.error, log: log, "SubscriberManager: has received a connection error with status: %i, reason: %s", status, reason)
    }
    
    func onSubscribedError(_ reason: String) {
        os_log(.error, log: log, "SubscriberManager: has received a subscribed error with statusreason: %s", reason)
    }
    
    func onSignalingError(_ message: String) {
        os_log(.error, log: log, "SubscriberManager: has received a signalig error: %s", message)
    }
}
