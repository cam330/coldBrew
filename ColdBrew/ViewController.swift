//
//  ViewController.swift
//  ColdBrew
//
//  Created by Cameron Wilcox on 1/4/17.
//  Copyright © 2017 Cameron Wilcox. All rights reserved.
//

import UIKit
import UserNotifications


class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    var isGrantedNotificationAccess:Bool = false
    var timeArray: NSArray = [3.0,5.0,10.0]
    var timer = 86400
    var countdownTimer = Timer()
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var coffeeButton: UIButton!
    var timeAtPress: Date!
    
    
    
    @IBAction func send10SecNotification(_ sender: UIButton) {
        if sender.titleLabel?.text == "Start My Coffee" {
            print("SHOULD NT GO")
            sender.setTitle("Stop Brewing", for: UIControlState.normal)
            
            if isGrantedNotificationAccess{
                
                timeAtPress = Date()
                let timeEnding = timeAtPress.timeIntervalSince1970 + 57600
                let toDate = NSDate(timeIntervalSince1970: timeEnding)
                print(toDate)
                
                countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.countdown), userInfo: nil, repeats: true)
                
                //add notification code here
                for i in 0 ..< timeArray.count {
                    
                    //Set the content of the notification
                    let content = UNMutableNotificationContent()
                    content.title = "Shake"
                    content.subtitle = "Your coldbrew coffee is ready to shake"
                    content.body = "Your cold brew will be ready at \(toDate)"
                    
                    //Set the trigger of the notification -- here a timer.
                    let trigger = UNTimeIntervalNotificationTrigger(
                        timeInterval: timeArray[i] as! TimeInterval,
                        repeats: false)
                    
                    //Set the request for the notification from the above
                    let request = UNNotificationRequest(
                        identifier: "\(i).second.message",
                        content: content,
                        trigger: trigger
                    )
                    
                    
                    //Add the notification to the currnet notification center
                    UNUserNotificationCenter.current().add(
                        request, withCompletionHandler: nil)
            }
        }
        } else {
            
            sender.setTitle("Start My Coffee", for: UIControlState.normal)
            countdownTimer.invalidate()
            timer = 86400
            UserDefaults.standard.setValue(Date(), forKey: "time")
            UserDefaults.standard.setValue(86400, forKey: "timer")
            
        }
}
    
    func countdown() {
        timer -= 1
        let (h, m, s) = self.secondsToHoursMinutesSeconds(seconds: timer)
        print(timer)
        timeLabel.text = "\(h):\(m):\(s)"
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func myObserverMethod(notification : NSNotification) {
        print("Observer method called")
        if timer > 0 {
            print(timer)
            UserDefaults.standard.setValue(Date(), forKey: "time")
            UserDefaults.standard.setValue(timer, forKey: "timer")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timerTime = UserDefaults.standard.value(forKey: "timer") as! Double
        
        if (timerTime > 0 || timerTime != 86400){
            countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.countdown), userInfo: nil, repeats: true)
            self.willEnterForeground()

            print(timer)
            
            self.coffeeButton.setTitle("Stop Brewing", for: UIControlState.normal)
        }
        
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                self.isGrantedNotificationAccess = granted
        }
        )
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.myObserverMethod(notification:)), name:NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.myObserverMethod(notification:)), name:NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    // my selector that was defined above
    func willEnterForeground() {
        print("BACK HERE")
        let timeSince = UserDefaults.standard.value(forKey: "time")
        print("TIME SIN",timeSince!)
        
        let elapsed = Date().timeIntervalSince(timeSince as! Date) 
        print("TJSO", elapsed)
        
        let timerTime = UserDefaults.standard.value(forKey: "timer") as! Double
        let newTimer = CGFloat(timerTime) - CGFloat(elapsed)
        timer = Int(newTimer)
        print("New TIME", timer)
        
    }
}


