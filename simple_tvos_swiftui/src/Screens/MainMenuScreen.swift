import SwiftUI

public struct MainMenuScreen: View {
    
    @Environment(\.coordinator) private var coordinator
    
    public var body: some View {
        List {
            NavigationLink("Subscriber") {
                coordinator.playerRequested()
            }
            Text("Publishing not supported yet on tvOS")
//            NavigationLink("Publisher") {
//                coordinator.recorderRequested()
//            }
        }
        .navigationTitle("Menu")
    }
}

protocol MainMenuScreenDelegate {
    func playerRequested() -> AnyView
    func recorderRequested() -> AnyView
}

#if SHOW_PREVIEW
#Preview {
   NavigationView {
       MainMenuScreen()
   }
   .environment(\.coordinator, previewCoordinator)
}
#endif
