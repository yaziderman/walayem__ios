//
//  Utils.swift
//  Walayem
//
//  Created by MAC on 4/20/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class Utils{
    public static var SHOW_NEWDISH = false
    public static var ADDED_FOODTYPE = ""
    public static var DELAY_TIME = 15
    
    public static var NOTIFIER_KEY = "NOTIFIER_KEY"
    
    
    static func formatDate(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return  dateFormatter.string(from: date!)
    }
    
    static func getMonthYear(_ date: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "MMM yyyy"
        return dateFormatter.string(from: date!)
    }
    
    static func getMonthDay(_ date: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "MMM dd"
        return dateFormatter.string(from: date!)
    }
    
    static func getDay(_ date: String) -> String{
        if date.isEmpty{
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: date)
        
        // Calculate time difference
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: date!)
        let date2 = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        
//        print("components.day=\(components.day ?? 2)")
        switch components.day! {
        case 0:
            return "Today"
        case 1:
            return "Yesterday"
        default:
            dateFormatter.dateFormat = "MMM dd yyyy"
            return dateFormatter.string(from: date!)
        }
    }
    
    static func getTime(_ date: String) -> String{
        if date.isEmpty{
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.date(from: date)
        
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date!)
    }
    
    static func encodeImage(_ image: UIImage) -> String?{
        let imageData = UIImagePNGRepresentation(image)
        return imageData?.base64EncodedString(options: .lineLength64Characters)
    }
    
    static func decodeImage(_ base64: String) -> UIImage?{
        let dataDecoded : Data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters)!
        return UIImage(data: dataDecoded)
    }
    
    static func getMonthName(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "MMMM"
        return  dateFormatter.string(from: date!)
    }
    static func getCurrentMonthAndYear() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let result = formatter.string(from: date)
        return result
    }
    
    static func setupNavigationBar(nav: UINavigationController){
        nav.navigationBar.setValue(true, forKey: "hidesShadow")
        nav.navigationBar.layer.shadowColor = UIColor.black.cgColor
        nav.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 1)
        nav.navigationBar.layer.shadowRadius = 5
        nav.navigationBar.layer.shadowOpacity = 0.1
        nav.navigationBar.layer.masksToBounds = false
        nav.navigationBar.layer.shadowPath = UIBezierPath(roundedRect: (nav.navigationBar.layer.bounds), cornerRadius: 6).cgPath
    }
    
    static func setupNavigationBarDiscover(nav: UINavigationController){
            nav.navigationBar.setValue(true, forKey: "hidesShadow")
    //        nav.navigationBar.layer.shadowColor = UIColor.black.cgColor
    //        nav.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 1)
    //        nav.navigationBar.layer.shadowRadius = 5
    //        nav.navigationBar.layer.shadowOpacity = 0.1
    //        nav.navigationBar.layer.masksToBounds = false
    //        nav.navigationBar.layer.shadowPath = UIBezierPath(roundedRect: (nav.navigationBar.layer.bounds), cornerRadius: 6).cgPath
        }
    
    static func showDelayAlert(context: UIViewController){

        let alert = UIAlertController(title: "", message: Utils.getDelayMsg(), preferredStyle: .alert)
        alert.setMessage(font: UIFont(name: "AvenirNextCondensed", size: 17), color: UIColor.black)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
            print("Continue pressed........ ")
            alert.dismiss(animated: true, completion: nil)
        }))
        
        context.present(alert, animated: true, completion: nil)
    }
    
    
    static func setUserDefaults(value: Any, key: String){
        let userDefaults = UserDefaults.standard
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    
    
    
    static func addChefInfoInNavigationBar(nav: UINavigationController){
    }
    
    
    static func getChefStartTime() -> Int {
        var startTime = UserDefaults.standard.integer(forKey: "chef_start_time")
        if(startTime == 0)
        {
            startTime = 7
        }
        
        return startTime;
    }

    static func getChefEndTime() -> Int {
        var endTime = UserDefaults.standard.integer(forKey: "chef_end_time")
        if(endTime == 0)
        {
            endTime = 23
//            endTime = 15
        }
        
        return endTime;

    }

    static func getMinHours() -> Int {
        var minHours = UserDefaults.standard.integer(forKey: "chef_min_hours")
        if(minHours == 0)
        {
            minHours = DELAY_TIME
        }
        
        return minHours;

    }
    
    static func getDelayMsg() -> String {
        return "Order delivery is available during day hours, after \(DELAY_TIME) hours from now.";
    }
    
    static func notifyRefresh() {
        NotificationCenter.default.post(name: NSNotification.Name.init(NOTIFIER_KEY), object: nil);
    }
    
//    static func showSorryAlertWithMessage(_ msg: String){
//        let alert = UIAlertController(title: "Sorry", message: msg, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//        present(alert, animated: true, completion: nil)
//    }
}
