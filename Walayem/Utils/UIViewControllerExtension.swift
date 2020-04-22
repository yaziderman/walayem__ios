//
//  UIViewControllerExtension.swift
//  Walayem
//
//  Created by Inception on 5/27/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import FirebaseMessaging
var user: User?

extension UIViewController{
    
    
    func onSessionExpired(showSkip: Bool = true) {
        
       logout()
        User().clearUserDefaults()
        DatabaseHandler().clearDatabase()
        OdooClient.destroy()
        
        let viewController : UIViewController = UIStoryboard(name: "User", bundle: nil).instantiateInitialViewController()!
        
        let navigationController : UINavigationController = UINavigationController.init(rootViewController: viewController);
        
        navigationController.setNavigationBarHidden(true, animated: false)
        if #available(iOS 13.0, *) {
            navigationController.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        StaticLinker.loginNav = navigationController
        StaticLinker.showSkip = showSkip
        
        self.present(navigationController, animated: true, completion: nil)
    }
 
    private func logout(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let client = OdooClient.sharedInstance()
        client.logout(completionHandler: { (result, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let error = error{
                let errmsg = error.userInfo[NSLocalizedDescriptionKey] as? String
                print(errmsg!)
                return
            }
            user = User().getUserDefaults()
            Messaging.messaging().unsubscribe(fromTopic: "alli")
            Messaging.messaging().unsubscribe(fromTopic: "\(user!.partner_id!)i")
            Messaging.messaging().unsubscribe(fromTopic: "alluseri")
            User().clearUserDefaults()
            OdooClient.destroy()
            StaticLinker.mainVC?.selectedIndex = 0
            Utils.notifyRefresh()

            
        })
    }
    
}
