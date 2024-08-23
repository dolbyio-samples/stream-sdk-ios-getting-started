//
//  PublisherViewModel.swift
//  stream-sdk-ios-getting-started
//

import Foundation
import AVFoundation
import MillicastSDK

@MainActor
class PublisherViewModel: ObservableObject {
    
    // This renderer is the adapter that receives frames from the video track
    // and provides it to an attached view.
    private var renderer: MCVideoRenderer
    private var publisher: MCPublisher = .init()

    private var videoTrack: MCVideoTrack?
    private var audioTrack: MCAudioTrack?
    @Published private(set) var isPublishing: Bool = false

    init(renderer: MCVideoRenderer) {
        self.renderer = renderer
    }
    
    func publish() async throws {
        // 1. Configure the audio session for recording and playback
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default)
        try audioSession.setActive(true)
        
        // 2. Set the credentials
        let credentials = MCPublisherCredentials()
        credentials.token = <#publishingToken#>
        credentials.streamName = <#streamName#>
        credentials.apiUrl = "https://director.millicast.com/api/director/publish"
        try await publisher.setCredentials(credentials)
        
        // 3. Capture the first video/audio source available.
        // IMPORTANT: Make sure your app provides camera/mic permissions.
        // Otherwise, the startCapture call will crash.
        let videoSources = MCMedia.getVideoSources()
        guard let videoSource = videoSources.first else {
            fatalError("No Video sources available")
        }
        
        // 3.a (Optional) Select the capabilities of the video
        // source (before attempting to capture)
        for capability in videoSource.getCapabilities() {
            if capability.width < 4032 && capability.height < 3024 {
                videoSource.setCapability(capability)
                break
            }
        }
        
        guard let videoTrack = videoSource.startCapture() as? MCVideoTrack else {
            fatalError("Could not capture video track")
        }
        
        let audioSources = MCMedia.getAudioSources()
        guard let audioSource = audioSources.first, 
                let audioTrack = audioSource.startCapture() as? MCAudioTrack else {
            fatalError("No Audio sources available")
        }
        
        // 3.b Attach a renderer to display the local video track
        videoTrack.add(self.renderer)
        
        // 3.c Keep a reference to the tracks. Otherwise,
        // they will be destroyed and the feed won't work.
        self.videoTrack = videoTrack
        self.audioTrack = audioTrack
        
        // 3.d Attach those tracks to the publisher for publishing.
        await publisher.addTrack(with: videoTrack)
        await publisher.addTrack(with: audioTrack)
        
        // 4. connect and publish
        try await publisher.connect()
        try await publisher.publish()
        
        isPublishing = true
    }
    
    func unpublish() async throws {
        // 1. unpublish
        try await publisher.unpublish()

        // 2. disconnect the websocket connection with the millicast server
        try await publisher.disconnect()

        videoTrack = nil
        audioTrack = nil
        isPublishing = false
    }
}
