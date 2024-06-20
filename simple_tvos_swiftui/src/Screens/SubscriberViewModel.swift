import Foundation
import OSLog
import MillicastSDK

protocol SubscriberViewModelType: ObservableObject {
    associatedtype T
    var track: T? { get set }
    func subscribe()
    func unsubscribe()
}

final class SubscriberViewModel: SubscriberViewModelType, SubscriptionDelegate {
    
    @Published var track: MCVideoTrack?
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
    func videoTrackCreated(_ videoTrack: MCVideoTrack) async {
        track = videoTrack
    }
}
