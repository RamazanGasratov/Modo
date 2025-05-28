//
//  NotificationManager.swift
//  Modo
//
//  Created by Рамазан Гасратов on 28.05.2025.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Ошибка при запросе уведомление:", error)
            } else if !granted {
                print("Пользователь запретил уведомления")
            }
        }
    }
    
    func scheduleTimerFinishedNotification(for event: TimerEvent) {
        let content = UNMutableNotificationContent()
        content.title = "Tаска закрыта"
        content.subtitle = event.title
        content.body = event.notes ?? ""
        content.sound = .default
 
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.6, repeats: false)
        let request = UNNotificationRequest(
            identifier: event.id,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Не удалось запланировать уведомление:", error)
            }
        }
    }
}
