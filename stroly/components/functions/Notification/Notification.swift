//
//  Notification.swift
//  stroly
//
//  Created by 大沼優希人 on 2024/01/19.
//

import Foundation
import UserNotifications

// 通知の許可を求めるメソッド
func requestNotificationAuthorization() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            print("Notification Authorization Error: \(error)")
        }
    }
}

// 毎週土曜日の通知をスケジュールするメソッド
func scheduleWeeklySaturdayNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Storly"
    content.body = "散歩に行きましょう！"
    content.sound = UNNotificationSound.default
    
    var dateComponents = DateComponents()
    dateComponents.weekday = 6  // 1が日曜日、7が土曜日
    dateComponents.hour = 10   // 午前10時
    dateComponents.minute = 00  // 0分
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    
    let request = UNNotificationRequest(identifier: "weeklySaturdayNotification", content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error)")
        }
    }
}

func checkUserDefaultsForFalseAndScheduleNotification() {
    let userDefaults = UserDefaults.standard
    let allEntries = userDefaults.dictionaryRepresentation()

    // UserDefaultsに保存されている全てのキーと値のペアをループで確認
    for (key, value) in allEntries {
        if let boolValue = value as? Bool, boolValue == false {
            // Bool型の値がfalseである場合、通知をスケジュール
            scheduleNotificationForKey(key)
            break // 1つ見つかればループを抜ける
        }
    }
}

// userDefaultsにfalseがある場合は、朝9時に通知を出す
private func scheduleNotificationForKey(_ key: String) {
    let content = UNMutableNotificationContent()
    content.title = "Stroly"
    content.body = "近くに開放していないピンがあります。"
    content.sound = UNNotificationSound.default
    var dateComponents = DateComponents()
        dateComponents.hour = 9  // 朝9時

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    let request = UNNotificationRequest(identifier: "UserDefaultsNotification-\(key)", content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling notification for key \(key): \(error)")
        }
    }
}
