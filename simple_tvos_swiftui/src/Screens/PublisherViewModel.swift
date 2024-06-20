import Foundation
import OSLog
import MillicastSDK

protocol PublisherViewModelType: ObservableObject {
    associatedtype T
    var track: T? { get set }
    func publish()
    func unpublish()
}

class PublisherViewModel: PublisherViewModelType, PublisherDelegate {
    
    @Published var track: MCVideoTrack?
    
    private var publisher: Publisher?
    
    func publish() {
        Task {
            do {
                let publisher = Publisher()
                self.publisher = publisher
                publisher.delegate = self
                try await publisher.start()
            } catch {
                os_log(.error, log: log, "PublisherPresenter: could not start the publisher: %s", error.localizedDescription)
            }
        }
    }
    
    func unpublish() {
        Task {
            do {
                try await publisher?.stop()
                publisher?.delegate = nil
                publisher = nil
            } catch {
                os_log(.error, log: log, "PublisherPresenter: could not stop the publisher: %s", error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func didPublish(track: MCVideoTrack) async {
        DispatchQueue.main.async {
            self.track = track
        }
    }
}
