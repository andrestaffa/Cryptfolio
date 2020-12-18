//
//  NotificationManager.swift
//  Cryptfolio
//
//  Created by Andre Staffa on 2020-12-17.
//  Copyright © 2020 Andre Staffa. All rights reserved.
//

import Foundation


public class NotificationManager {
    
    public static let notificationCenter = UNUserNotificationCenter.current();
    
    public static func askPermission() -> Void {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge, .carPlay, .announcement];
        notificationCenter.requestAuthorization(options: options) { (didAllow, error) in
            if let error = error { print(error.localizedDescription); } else {
                if (!didAllow) { print("User did not allow notifications"); } else {
                    print("User HAS allowed notifications");
                }
            }
        }
    }
    
    public static func scheduleNotification() -> Void {
        let content = UNMutableNotificationContent();
        content.title = "Don't miss out!";
        content.body = "Check on the performance of your portfolio!";
        content.sound = UNNotificationSound.default;
        content.badge = 1;
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: false);
        let request = UNNotificationRequest(identifier: UserDefaultKeys.dailyReminder, content: content, trigger: trigger);
        notificationCenter.add(request) { (error) in
            if let error = error { print("Notifcation Error: \(error.localizedDescription)"); } else {
                print("Successfuly showed the notifications")
            }
        }
    }
    
    
}
