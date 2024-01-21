//
//  strolyApp.swift
//  stroly
//
//  Created by 長濱聖英 on 2023/11/03.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct strolyApp: App {
    let persistenceController = PersistenceController.shared
    
    //    var sharedModelContainer: ModelContainer = {
    //            let schema = Schema([
    //                MyPosts.self,
    //            ])
    //            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    //
    //            do {
    //                return try ModelContainer(for: schema, configurations: [modelConfiguration])
    //            } catch {
    //                fatalError("Could not create ModelContainer: \(error)")
    //            }
    //        }()
    
    var body: some Scene {
        WindowGroup {
            LaunchScreen()
                .onAppear {
                    // アプリ起動時に通知の許可を求める
                    requestNotificationAuthorization()
                    // 毎週土曜日の通知をスケジュールする
                    scheduleWeeklySaturdayNotification()
                }
        }
        .modelContainer(for: [MyPosts.self, Friends.self])
    }
    
//    // UserDefaultsをチェックして条件に応じた通知をスケジュールするメソッド
//     func checkUserDefaultsAndScheduleNotification() {
//         let userDefaults = UserDefaults.standard
//         let imageUrlKey =
//         
//         // UserDefaultsからBool値を取得
//         let isFalse = userDefaults.bool(forKey: imageUrlKey) == false
//
//         // Bool値がfalseの場合、通知をスケジュール
//         if isFalse {
//             let content = UNMutableNotificationContent()
//             content.title = "Stroly"
//             content.body = "近くに未開放のピンがあります。"
//             content.sound = UNNotificationSound.default
//
//             let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//             let request = UNNotificationRequest(identifier: "UserDefaultsNotification", content: content, trigger: trigger)
//             
//             UNUserNotificationCenter.current().add(request) { error in
//                 if let error = error {
//                     print("Error scheduling notification: \(error)")
//                 }
//             }
//         }
//     }
}
