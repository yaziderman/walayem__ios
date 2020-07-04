//
//  AppDelegate.swift
//  Walayem
//
//  Created by MAC on 4/16/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import UserNotifications

import FBSDKCoreKit
import FacebookCore
import GoogleSignIn
import Firebase
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let fcmMessageIDKey = "fcm.message_id"
    var firebaseToken: String = ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationBarAppearance = UINavigationBar.appearance()
        // Change navigationbar items color
        navigationBarAppearance.tintColor = UIColor.colorPrimary
        // Change tabbar icon color
        UITabBar.appearance().tintColor = UIColor.colorPrimary

        window?.backgroundColor = UIColor.white
        
        // CONFIGURE GOOGLE SIGNIN
        GIDSignIn.sharedInstance().clientID = "685466919055-mg1tqlbdomrl6spk56opmle5tm8gpbsk.apps.googleusercontent.com"
        // CONFIGURE FACEBOOK LOGIN
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        // CONFIGURE FIREBASE
        FirebaseApp.configure()
        registerRemoteNotification(application)
        GMSServices.provideAPIKey("AIzaSyCC9vvrCbOXkzgIlyJOWd-D2e-0eJivRHQ")
            //("AIzaSyDz2IN7uCHH4ehwiSITdGExTih5Hz07_0k")
        GMSPlacesClient.provideAPIKey("AIzaSyCC9vvrCbOXkzgIlyJOWd-D2e-0eJivRHQ")

//        GIDSignIn.sharedInstance()?.presentingViewController = self
        setRootViewController()
//        getContactDetails()
//        getChefSettings()'
        AreaFilter.setSharedFilter()
		#if DEBUG
		Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
		#endif
        return true
    }
    
	func shouldMoveToMainPage() {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		guard let vc = storyboard.instantiateViewController(withIdentifier: "UserTabBarController") as? UserTabBarController else {
			return
		}
//		let navigationController = UINavigationController(rootViewController: vc)
		window?.rootViewController = vc
		window?.makeKeyAndVisible()
	}
   
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let google = GIDSignIn.sharedInstance().handle(url)
        
        let facebook = ApplicationDelegate.shared.application(app, open: url, options: options)
        
        return google || facebook
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[fcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        // Print full message.
        print(userInfo)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AppEvents.activateApp()
    }
    

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func registerRemoteNotification(_ application: UIApplication){
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        // [END register_for_notifications]
    }

    // Private methods
    
    private func setRootViewController(){
        let isRegular = UserDefaults.standard.bool(forKey: UserDefaultsKeys.REGULAR_RUN)
        let session = UserDefaults.standard.string(forKey: UserDefaultsKeys.SESSION_ID)
        var storyboard: UIStoryboard?
        if !isRegular{
            storyboard = UIStoryboard(name: "WalkThrough", bundle: nil)
        }else if session == nil{
            storyboard = UIStoryboard(name: "Main", bundle: nil)
        }else{
            let isChef = UserDefaults.standard.bool(forKey: UserDefaultsKeys.IS_CHEF)
            if(isChef){
                storyboard = UIStoryboard(name: "ChefMain", bundle: nil)
            }else{
                storyboard = UIStoryboard(name: "Main", bundle: nil)
            }
        }
        window?.rootViewController = storyboard?.instantiateInitialViewController()        
        
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.REGULAR_RUN)
    }
    
    private func getContactDetails(){
        RestClient().request(WalayemApi.contact, [:], nil) { (result, error) in
            if let _ = error{
                return
            }
            let value = result!["result"] as! [String: Any]
            let record = value["data"] as! [String: Any]
            let email = record["email"] as? String ?? ""
            let facebook = record["facebook"] as? String ?? ""
            let instagram = record["instagram"] as? String ?? ""
            let phone = record["phone"] as? String ?? ""
            let website = record["website"] as? String ?? ""
            
            let userDefaults = UserDefaults.standard
            userDefaults.set(email, forKey: "ContactEmail")
            userDefaults.set(facebook, forKey: "ContactFacebook")
            userDefaults.set(instagram, forKey: "ContactInstagram")
            userDefaults.set(phone, forKey: "ContactNumber")
            userDefaults.set(website, forKey: "ContactUrl")
            userDefaults.synchronize()
        }
    }
    
    private func getChefSettings(){
        RestClient().request(WalayemApi.getChefSettings, [:], nil) { (result, error) in
            if let _ = error{
                return
            }
            
            let a = 0;
        }
    }

}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
//         Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[fcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        UIApplication.shared.applicationIconBadgeNumber += 1
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateBadgeNotification"), object: nil, userInfo: userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[fcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        UIApplication.shared.applicationIconBadgeNumber += 1
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateBadgeNotification"), object: nil, userInfo: userInfo)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OrderStateNotification"), object: nil, userInfo: userInfo)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateTabNotification"), object: nil, userInfo: userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        
        // Note: This callback is fired at each app startup and whenever a new token is generated.
//        Utils.sendFirebaseTokenToServer(token: fcmToken)
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}

