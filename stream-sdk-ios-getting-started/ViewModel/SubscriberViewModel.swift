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
        if let asVideo = track.asVideo() {
          try await asVideo.enable(renderer: renderer)
        }
        
        if let asAudio = track.asAudio() {
          try await asAudio.enable()
        }
      }
    }
    
    // 5. connect and subscribe
    try await subscriber.connect()
    try await subscriber.subscribe()
  }
}
