//
//  MainTabBarController.swift
//  Walayem
//
//  Created by Inception on 5/24/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class UserTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(setBadge(_:)), name: NSNotification.Name(rawValue: "UpdateBadgeNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showOrderDetail(_:)), name: NSNotification.Name(rawValue: "OrderStateNotification"), object: nil)
        setupTabBar()
    }
    
    func setupTabBar(){
        //hide divider
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().backgroundColor = UIColor.white
        
        
        //show shadow
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        tabBar.layer.shadowRadius = 5
        tabBar.layer.shadowOpacity = 0.15
        tabBar.layer.masksToBounds = false
    }
    // MARK: Private methods
    
    @objc private func setBadge(_ notification : Notification){
        if let tabItem = self.tabBar.items?[3]{
            tabItem.badgeColor = UIColor.colorPrimary
            tabItem.badgeValue = "*"
        }
    }
    
    @objc private func showOrderDetail(_ notification : Notification){
        let status = notification.userInfo![AnyHashable("status")] as! String
        if status == "other"{
            return
        }
        let orderId = notification.userInfo![AnyHashable("order_id")] as! String

        if status == "rate"{
            self.selectedIndex = 1
            guard let chefRatingVC = UIStoryboard.init(name: "Chef", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChefRatingVC") as? ChefRatingViewController else {
                fatalError("Unexpected view controller")
            }
            if let currentViewController = self.selectedViewController as? UINavigationController{
                currentViewController.present(chefRatingVC, animated: true, completion: nil)
            }
        }else{
            self.selectedIndex = 3
            if let currentViewController = self.selectedViewController as? UISplitViewController{
                guard let orderVC = UIStoryboard.init(name: "Order", bundle: Bundle.main).instantiateViewController(withIdentifier: "OrderVC") as? OrderViewController else {
                    fatalError("Unexpected view controller")
                }
                orderVC.orderId = Int(orderId)
                let navigationVC = UINavigationController(rootViewController: orderVC)
                currentViewController.showDetailViewController(navigationVC, sender: self)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
