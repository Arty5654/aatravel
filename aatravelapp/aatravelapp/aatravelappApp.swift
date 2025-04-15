import SwiftUI
import GoogleSignIn

@main
struct aatravelappApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var session = UserSession()

    var body: some Scene {
        WindowGroup {
            HomeView()  // Change this to HomeView
                .environmentObject(session)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
