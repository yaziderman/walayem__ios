//
//  UIViewControllerExtension.swift
//  Walayem
//
//  Created by Inception on 5/27/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

extension UIViewController{
    
    func onSessionExpired() {
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
        self.present(navigationController, animated: true, completion: nil)
    }
    
}
