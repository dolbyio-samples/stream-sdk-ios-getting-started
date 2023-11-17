import Foundation
import OSLog
import MillicastSDK


// MARK: Subscriber

class SubscriptionPresenter: SubscriptionDelegate {
    
    private let subscriptionManager: SubscriptionManager
    private var subscription: Subscription?

    init(subscriptionManager: SubscriptionManager) {
        self.subscriptionManager = subscriptionManager
    }
    
    func subscribe() {
        Task {
            do {
                let subscription = subscriptionManager.subscribe()
                self.subscription = subscription
                subscription.delegate = self
                try subscription.start()
            } catch {
                os_log(.error, log: log, "SubscriptionPresenter: could not start the subscriber: %s", error.localizedDescription)
            }
        }
    }
    
    func unsubscribe() {
        do {
            try subscription?.stop()
            subscription?.delegate = nil
            subscription = nil
        } catch {
            os_log(.error, log: log, "SubscriptionPresenter: could not stop the subscriber: %s", error.localizedDescription)
        }
    }
    
    func videoTrackCreated(_ videoTrack: MCVideoTrack) { }
}

// MARK: - Publisher

// ####################################################################
// Publishing is currently not supported !!!
// ####################################################################

class PublisherPresenter: PublisherDelegate {
    
    private let publisherManager: PublisherManager
    private var publisher: Publisher?
    
    init(publisherManager: PublisherManager) {
        self.publisherManager = publisherManager
    }
    
    func publish() {
        Task {
            do {
                let publisher = publisherManager.publish()
                self.publisher = publisher
                publisher.delegate = self
                try publisher.start()
            } catch {
                os_log(.error, log: log, "PublisherPresenter: could not start the publisher: %s", error.localizedDescription)
            }
        }
    }
    
    func unpublish() {
        do {
            try publisher?.stop()
            publisher?.delegate = nil
            publisher = nil
        } catch {
            os_log(.error, log: log, "PublisherPresenter: could not stop the publisher: %s", error.localizedDescription)
        }
    }
    
    func didPublish(track: MCVideoTrack) { }
}