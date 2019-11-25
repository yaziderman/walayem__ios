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
        self.present(viewController, animated: true, completion: nil)
    }
    
}
