import SwiftUI

public struct MainMenuScreen<SV: View, PV: View>: View {

    private let subscriberView: () -> SV
    private let publisherView: () -> PV
    
    init(
        subscriberView: @escaping @autoclosure () -> SV,
        publisherView: @escaping @autoclosure () -> PV
    ) {
        self.subscriberView = subscriberView
        self.publisherView = publisherView
    }
    public var body: some View {
        List {
            NavigationLink("Subscriber") {
                subscriberView()
            }
            NavigationLink("Publisher") {
                publisherView()
            }
        }
        .navigationTitle("Menu")
    }
}

#if SHOW_PREVIEW
#Preview {
   NavigationView {
       MainMenuScreen(subscriberView: EmptyView(), publisherView: EmptyView())
   }
}
#endif
