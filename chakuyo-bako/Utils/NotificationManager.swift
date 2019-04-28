//
//  NotificationManager.swift
//  chakuyo-bako
//
//  Created by Matsuno Shunya on 2019/04/28.
//  Copyright © 2019年 Matsuno Shunya. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject {
    
    override init() {
        super.init()
    }
    
    public func notificationDisconnect() {
        // 通知の設定！
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.title = "Chakuyo-bakoとの接続が切れました"
        content.body = "大変です！Chakuyo-bakoを見失いました！近くにChakuyo-bakoがいるか確認してください。"
        // タイマーの時間（秒）をセット
        let timer = 1
        // ローカル通知リクエストを作成
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timer), repeats: false)
        let identifier = NSUUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request){ (error : Error?) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    
}
