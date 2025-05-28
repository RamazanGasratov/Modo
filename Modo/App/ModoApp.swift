//
//  ModoApp.swift
//  Modo
//
//  Created by Рамазан Гасратов on 06.05.2025.
//

import SwiftUI
import UserNotifications
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        NotificationManager.shared.requestAuthorization()
    }

    // Этот метод позволит уведомлениям срабатывать, даже когда ваше окно на переднем плане
    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      willPresent notification: UNNotification,
      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}

@main
struct ModoApp: App {
    @State var timer = "0:00"
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarExtraContent()
        } label: {
            MenuBarExtraView(
                timer: $timer
            )
        }
    }
}



