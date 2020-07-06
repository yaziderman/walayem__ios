//
//  ChefTabController.swift
//  Walayem
//
//  Created by Inception on 5/24/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class ChefTabController: UITabBarController {

    private var profileVCIsShown = false
	
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.selectedIndex)
        print("viewDidLoad 1  \(self.selectedIndex)")
        NotificationCenter.default.addObserver(self, selector: #selector(setBadge(_:)), name: NSNotification.Name(rawValue: "UpdateBadgeNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showOrderDetail(_:)), name: NSNotification.Name(rawValue: "OrderStateNotification"), object: nil)
        setupTabBar()
        
        if(Utils.SHOW_NEWDISH)
        {
            self.selectedIndex = 1
        }
        
        
    }

    func setupTabBar(){
        //hide divider
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().backgroundColor = UIColor.init(light: .white, dark: .black)
        
        
        //show shadow
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        tabBar.layer.shadowRadius = 5
        tabBar.layer.shadowOpacity = 0.15
        tabBar.layer.masksToBounds = false
    }

    @objc private func setBadge(_ notification : Notification){
        if let tabItem = self.tabBar.items?[0]{
            tabItem.badgeColor = UIColor.colorPrimary
            tabItem.badgeValue = "*"
        }
    }
    
    @objc private func showOrderDetail(_ notification : Notification){
        let state = notification.userInfo![AnyHashable("status")] as! String
        if state == "verified"{
            return
        }
        let orderId = notification.userInfo![AnyHashable("order_id")] as! String
        self.selectedIndex = 0
        guard let chefOrderDetailVC = UIStoryboard.init(name: "ChefOrders", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChefOrderDetailVC") as? ChefOrderDetailViewController else {
            fatalError("Unexpected view controller")
        }
        chefOrderDetailVC.orderId = Int(orderId)
        chefOrderDetailVC.orderState = OrderState(rawValue: state)!
        if let currentViewController = self.selectedViewController as? UINavigationController{
            currentViewController.pushViewController(chefOrderDetailVC, animated: true)
        }
    
    }
	
    override func viewDidAppear(_ animated: Bool) {
//        if self.selectedIndex == 2 {
//            if let currentViewController = self.selectedViewController as? UISplitViewController{
//               guard let orderVC = UIStoryboard.init(name: "ChefProfile", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChefProfileTableViewController") as? ChefProfileTableViewController else {
//                   fatalError("Unexpected view controller")
//               }
//               let navigationVC = UINavigationController(rootViewController: orderVC)
//               currentViewController.showDetailViewController(navigationVC, sender: self)
//            }
//        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

            print("viewDidLoad  tabBar  \(self.selectedIndex)")
            switch UIDevice.current.userInterfaceIdiom {
               case .phone:
                   // It's an iPhone
                print("It's an iPhone")
               
               case .pad:
               print("pad")
                   // It's an iPad
               
               
               if tabBar.items?.firstIndex(of: tabBar.selectedItem!) == 2 {

                      if let currentViewController = self.selectedViewController as? UISplitViewController{
                         guard let orderVC = UIStoryboard.init(name: "ChefProfile", bundle: Bundle.main).instantiateViewController(withIdentifier: "ChefProfileTableViewController") as? ChefProfileTableViewController else {
                             fatalError("Unexpected view controller")
                         }
                         let navigationVC = UINavigationController(rootViewController: orderVC)
                         currentViewController.showDetailViewController(navigationVC, sender: self)
                      }
              }

               case .unspecified:
               print("unspecified")
                       // Uh, oh! What could it be?
                case .tv:
                print("tv")
                case .carPlay:
                print("carplay")
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
