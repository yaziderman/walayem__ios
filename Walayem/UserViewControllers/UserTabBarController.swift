//
//  MainTabBarController.swift
//  Walayem
//
//  Created by Inception on 5/24/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

enum UIUserInterfaceIdiom : Int {
    case unspecified

    case phone // iPhone and iPod touch style UI
    case pad // iPad style UI
}

class UserTabBarController: UITabBarController{

    var session : String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = UserDefaults.standard.string(forKey: UserDefaultsKeys.SESSION_ID)

        NotificationCenter.default.addObserver(self, selector: #selector(setBadge(_:)), name: NSNotification.Name(rawValue: "showOrderDetail"), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(setUpTabSeletion(_:)), name: NSNotification.Name(rawValue: "UpdateTabNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showOrderDetail(_:)), name: NSNotification.Name(rawValue: "OrderStateNotification"), object: nil)
        setupTabBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileTitle) , name: NSNotification.Name(rawValue: Utils.NOTIFIER_KEY), object: nil);
        
//        let session = UserDefaults.standard.string(forKey: UserDefaultsKeys.SESSION_ID)

        updateProfileTitle()
        StaticLinker.mainVC = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProfileTitle()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateProfileTitle()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateProfileTitle()
    }
    
    
    
    @objc func updateProfileTitle() {
        
        if(session == nil)
        {
            self.tabBar.items![4].title = "Log In"
//            self.tabBar.items![4].image?.imageAsset = UIImage(named:"login_grey.png")
        }
        else
        {
            self.tabBar.items![4].title = "Profile"
        }
        
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
        if let tabItem = self.tabBar.items?[4]{
            tabItem.badgeColor = UIColor.colorPrimary
            tabItem.badgeValue = "*"
        }
    }
 
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        StaticLinker.previosSeletedTab = self.selectedIndex

        print("--------oooooooooooooooooo-------\(StaticLinker.previosSeletedTab)")
        
        switch UIDevice.current.userInterfaceIdiom {
           case .phone:
               // It's an iPhone
            print("phone----------------------------------------------------------------------")
            
            
            if self.selectedIndex == 4 {

//                let session = UserDefaults.standard.string(forKey: UserDefaultsKeys.SESSION_ID)
//                if(session != nil){
//                    if let currentViewController = self.selectedViewController as? UISplitViewController{
//                       guard let orderVC = UIStoryboard.init(name: "Profile", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileTableViewController") as? ProfileTableViewController else {
//                           fatalError("Unexpected view controller")
//                       }
//                       let navigationVC = UINavigationController(rootViewController: orderVC)
//                       currentViewController.showDetailViewController(navigationVC, sender: self)
//                    }
//                }
            }
           case .pad:
           print("pad")
               // It's an iPad
           
//           if self.selectedIndex == 4 {
//
//                           let session = UserDefaults.standard.string(forKey: UserDefaultsKeys.SESSION_ID)
//                           if(session != nil){
//           //                    if let currentViewController = self.selectedViewController as? UISplitViewController{
//                                  guard let orderVC = UIStoryboard.init(name: "Profile", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileTableViewController") as? ProfileTableViewController else {
//                                      fatalError("Unexpected view controller")
//                                  }
//                                  let navigationVC = UINavigationController(rootViewController: orderVC)
//           //                       currentViewController.showDetailViewController(navigationVC, sender: self)
//           //                    }
//                           }
//                       }
            
//           if item.title == "Profile" {
//                        selectedIndex = 4
//           }
//           else if item.title == "History" {
//                    selectedIndex = 3
//           }
        //        self.selectedIndex = 3
//           if self.selectedIndex == 3 {
//                if let currentViewController = self.selectedViewController as? UISplitViewController{
//                    guard let orderVC = UIStoryboard.init(name: "Order", bundle: Bundle.main).instantiateViewController(withIdentifier: "OrderNav") as? OrderTableViewController else {
//                        fatalError("Unexpected view controller")
//                    }
//                    let navigationVC = UINavigationController(rootViewController: orderVC)
//                    currentViewController.showDetailViewController(navigationVC, sender: self)
//                }
//
//            }
            
//            if self.selectedIndex == 4 {
//                if let currentViewController = self.selectedViewController as? UISplitViewController{
//                    guard let orderVC = UIStoryboard.init(name: "Profile", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileTableViewController") as? ProfileTableViewController else {
//                        fatalError("Unexpected view controller")
//                    }
//                    let navigationVC = UINavigationController(rootViewController: orderVC)
//                    currentViewController.showDetailViewController(navigationVC, sender: self)
//                }
//
//            }
        
            
           case .unspecified:
           print("unspecified")
                   // Uh, oh! What could it be?
            case .tv:
            print("tv")
            case .carPlay:
            print("carplay")
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
