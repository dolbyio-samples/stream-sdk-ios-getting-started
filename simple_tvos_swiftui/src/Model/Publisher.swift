import Foundation
import MillicastSDK
import AVFAudio
import OSLog

// ####################################################################
// Publishing is currently not supported !!!
// ####################################################################

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
    
    private var audioSessionConfigured: Bool = false

    fileprivate init() { }
    
    func start() throws {
        // Copy from the iOS examples
    }
    
    func stop() throws {
        // Copy from the iOS examples
    }

}
