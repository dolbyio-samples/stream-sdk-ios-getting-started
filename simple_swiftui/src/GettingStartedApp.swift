import SwiftUI

@main
struct GettingStartedApp: App {
    
    let coordinator = CoordinatorImpl()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                coordinator.mainMenuScreen()
            }
        }
    }
}
