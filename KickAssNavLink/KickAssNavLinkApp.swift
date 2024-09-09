//
//  KickAssNavLinkApp.swift
//  KickAssNavLink
//
//  Created by Infinite Novice on 8/24/24.
//

import SwiftUI
import OSLog


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
    var navLinkModel = NavLinkModel.shared
    var log = Logger(subsystem: "KickAssNavLink", category: "AppDelegate")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: .alert) { granted, error in
            if let error = error {
                self.log.error("User notifications error: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    self.log.info("Registered for remote notifications")
                }
            }
        }
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .badge])
        self.log.info("Foreground notification")
        self.navLinkModel.fetchPublished()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        self.log.info("Background notification")
        self.navLinkModel.fetchPublished()
    }
}

