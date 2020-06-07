//
//  ContentViewController.swift
//  Walayem
//
//  Created by Naveed on 05/05/2020.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

var ContentViewControllerVC = ContentViewController()

class ContentViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    let db = DatabaseHandler()
    
    var pageViewController : UIPageViewController?
    var currentIndex : Int = 0
    
    var chefIds: [Int] = []
    var cartItemArray: [[CartItem]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        chefIds = db.getChefIdsFromCart()
        for item in chefIds {
            let chefs = db.getCartItemsByChefId(item)
            var tempArray: [CartItem] = []
            for chef in chefs {
                let cartItem = CartItem(opened: true, chef: chef, note: "")
                tempArray.append(cartItem)
            }
            self.cartItemArray.append(tempArray)
        }
//        Utils.setupNavigationBar(nav: self.navigationController!)
        
        ContentViewControllerVC = self
        pageViewController = storyboard?.instantiateViewController(withIdentifier: "PageViewController") as? UIPageViewController
        pageViewController!.dataSource = self
        pageViewController!.delegate = self
        
        let startingViewController: CartViewController = viewControllerAtIndex(index: currentIndex)!
        let viewControllers = [startingViewController]
        pageViewController!.setViewControllers(viewControllers , direction: .forward, animated: false, completion: nil)
        pageViewController!.view.frame = view.bounds
        
        addChild(pageViewController!)
        view.addSubview(pageViewController!.view)
        view.sendSubviewToBack(pageViewController!.view)
        pageViewController!.didMove(toParent: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //It will show the status bar again after dismiss
        UIApplication.shared.isStatusBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - UIPageViewControllerDataSource
    //1
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        var index: Int? = 0//(viewController as! CartViewController).pageIndex
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        index! -= 1
        return viewControllerAtIndex(index: index!)
    }
    
    //2
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index: Int? = 0//(viewController as! CartViewController).pageIndex
        if index == NSNotFound {
            return nil
        }
        index! += 1
        if (index == cartItemArray.count) {
            return nil
        }
        return viewControllerAtIndex(index: index!)
    }
    
    //3
    func viewControllerAtIndex(index: Int) -> CartViewController? {
        if cartItemArray.count == 0 || index >= cartItemArray.count {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let vc = storyboard?.instantiateViewController(withIdentifier: "CartViewController") as! CartViewController
//        vc.cartItems = getCartItemsForIndex(index)
//        vc.pageIndex = index
        currentIndex = index
        
//        vc.view.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        return vc
    }
    
    func getCartItemsForIndex(_ index: Int) -> [CartItem] {
        return self.cartItemArray[index]
    }
}
