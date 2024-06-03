import Foundation
import OSLog
import MillicastSDK


// MARK: Subscriber

class SubscriptionPresenter: SubscriptionDelegate {
    
    private var subscription: Subscription?

    func subscribe() {
        Task {
            do {
                let subscription = Subscription()
                self.subscription = subscription
                subscription.delegate = self
                try await subscription.start()
            } catch {
                os_log(.error, log: log, "SubscriptionPresenter: could not start the subscriber: %s", error.localizedDescription)
            }
        }
    }
    
    func unsubscribe() {
        Task {
            do {
                try await subscription?.stop()
                subscription?.delegate = nil
                subscription = nil
            } catch {
                os_log(.error, log: log, "SubscriptionPresenter: could not stop the subscriber: %s", error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func videoTrackCreated(_ videoTrack: MCVideoTrack) async { }
}

// MARK: - Publisher

class PublisherPresenter: PublisherDelegate {
    
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
    func didPublish(track: MCVideoTrack) async { }
}
