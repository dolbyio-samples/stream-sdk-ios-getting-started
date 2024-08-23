//
//  SubscriberViewModel.swift
//  stream-sdk-ios-getting-started
//

import Foundation
import AVFoundation
import MillicastSDK

@MainActor
class SubscriberViewModel: ObservableObject {
    
    // This renderer is the adapter that receives frames from the video track
    // and provides it to an attached view.
    private var renderer: MCVideoRenderer
    
    private var subscriber: MCSubscriber?
    @Published private(set) var isSubscribed: Bool = false
    
    init(renderer: MCVideoRenderer) {
        self.renderer = renderer
    }
    
    func subscribe() async throws {
        // 1. Configure the audio session for playback
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default)
        try audioSession.setActive(true)
        
        // 2. Create a subscriber
        let subscriber = MCSubscriber()
        self.subscriber = subscriber
        
        // 3. Set the credentials
        let credentials = MCSubscriberCredentials()
        credentials.accountId = <#accountId#>
        credentials.streamName = <#streamName#>
        credentials.apiUrl = "https://director.millicast.com/api/director/subscribe"
        
        try await subscriber.setCredentials(credentials)
        
        // 4. Create a task to observe events on the subscriber, such as receiving tracks
        Task {
            // In a multi view scenario, you might be receiving
            // multiple audio/video tracks, therefore you should
            // use a unique renderer for each video track, i.e. only
            // enabling the video track with a unique renderer.
            for await track in subscriber.rtsRemoteTrackAdded() {
                if let videoTrack = track.asVideo() {
                    try await videoTrack.enable(renderer: renderer)
                    
                    Task {
                        for await activity in videoTrack.activity() {
                            switch activity {
                            case .inactive:
                                // 4a. Optional.
                                // The SDK automatically restores the state of the track when it transitions to `active` from an `inactive` state.
                                // You can optionally disable the video track when it becomes inactive. This step is optional. This gives you control on when to enable the track when it comes back active.
                                try await videoTrack.disable()
                                
                            case .active:
                                // 4b. Optional.
                                // If you choose to disable a track when it became inactive, you have to enable the video track back after it is active again.
                                // At any point in time when you wish to start receive video from the track, call -
                                try await videoTrack.enable(renderer: renderer)
                            }
                        }
                    }
                } else if let audioTrack = track.asAudio() {
                    try await audioTrack.enable()
                    
                    Task {
                        for await activity in audioTrack.activity() {
                            switch activity {
                            case .inactive:
                                // 4c. Optional.
                                // The SDK automatically restores the state of the track when it
                                // transitions to `active` from an `inactive` state.
                                // You can optionally disable the audio track when it becomes inactive,
                                // so that the responsibility is on you to enable the track
                                // when it becomes active.
                                try await audioTrack.disable()
                                
                            case .active:
                                // 4d. Optional.
                                // At any point in time where you wish to play audio from the track
                                try await audioTrack.enable()
                            }
                        }
                    }
                }
            }
        }
        
        // 5. connect and subscribe
        try await subscriber.connect()
        try await subscriber.subscribe()
        
        isSubscribed = true
    }
    
    func unsubscribe() async throws {
        // 1. Unsubscribe to the session
        try await subscriber?.unsubscribe()
        
        // 2. Disconnect the websocket connection to the server
        try await subscriber?.disconnect()
        
        isSubscribed = false
    }
}
