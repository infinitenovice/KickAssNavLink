//
//  KickAssNavLinkApp.swift
//  KickAssNavLink
//
//  Created by Infinite Novice on 8/24/24.
//

import SwiftUI
//import CloudKit


@main
struct KickAssNavLinkApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var cloudKitModel = CloudKitModel.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: .alert) { granted, error in
            if let error = error {
                self.cloudKitModel.setErrorMessage(message: "User notifications error: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    self.cloudKitModel.setStatusMessage(message: "Registered for remote notifications")
                }
            }
        }
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .badge])
        self.cloudKitModel.setStatusMessage(message: "Foreground notification")
        self.cloudKitModel.fetch()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        self.cloudKitModel.setStatusMessage(message: "Background notification")
        self.cloudKitModel.fetch()
    }
}

