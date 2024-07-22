//
//  aatravelappApp.swift
//  aatravelapp
//
//  Created by Arteom Avetissian on 6/30/24.
//

import SwiftUI
import GoogleSignIn

@main
struct aatravelappApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

