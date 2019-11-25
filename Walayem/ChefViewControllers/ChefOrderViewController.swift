//
//  ChefOrderTableViewController.swift
//  Walayem
//
//  Created by MAC on 5/17/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class ChefOrderViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    lazy var pendingViewController : PendingOrderTableViewController = {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PendingOrderTableVC") as? PendingOrderTableViewController else {
            fatalError("Unexpected view controller")
        }
        
        self.addViewControllerAsChild(childViewController: viewController)
        return viewController
    }()
    
    lazy var completedViewController : CompletedOrderTableViewController = {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CompletedOrderTVC") as? CompletedOrderTableViewController else {
            fatalError("Unexpected view controller")
        }
        viewController.state = CompletedOrderTableViewController.STATE_COMPLETED
        self.addViewControllerAsChild(childViewController: viewController)
        return viewController
    }()
    
    lazy var cancelledViewController : CompletedOrderTableViewController = {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CompletedOrderTVC") as? CompletedOrderTableViewController else {
            fatalError("Unexpected view controller")
        }
        viewController.state = CompletedOrderTableViewController.STATE_CANCELLED
        self.addViewControllerAsChild(childViewController: viewController)
        return viewController
    }()
    
    let orderStates = ["Pending", "Completed", "Cancelled"]
    let orderStateColors = [UIColor.peach, UIColor.colorPrimary, UIColor.rosa]
    var selectedState = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        updateView()
        setupTabBar(nav: self.navigationController!)
    }
    func setupTabBar(nav: UINavigationController){
        nav.navigationBar.setValue(true, forKey: "hidesShadow")
        nav.navigationBar.layer.shadowColor = UIColor.black.cgColor
        nav.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 1)
        nav.navigationBar.layer.shadowRadius = 5
        nav.navigationBar.layer.shadowOpacity = 0.1
        nav.navigationBar.layer.masksToBounds = false
        nav.navigationBar.layer.shadowPath = UIBezierPath(roundedRect: (navigationController?.navigationBar.layer.bounds)!, cornerRadius: 6).cgPath
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.navigationController?.tabBarItem.badgeValue = nil
    }
    
    // MARK: Private methods
    
    private func updateView(){
        pendingViewController.view.isHidden = selectedState != 0
        completedViewController.view.isHidden = selectedState != 1
        cancelledViewController.view.isHidden = selectedState != 2
    }
    
    private func addViewControllerAsChild(childViewController: UITableViewController){
        addChildViewController(childViewController)
        
        containerView.addSubview(childViewController.view)
        childViewController.view.frame = containerView.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        childViewController.didMove(toParentViewController: self)
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

extension ChefOrderViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return orderStates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderStateCollectioViewCell", for: indexPath) as? FoodCategCollectionViewCell else {
            fatalError("Unexpected cell")
        }
        cell.titleLabel.text = orderStates[indexPath.row]
        cell.iconImageView.image = UIImage(named: "chefOrder")?.withRenderingMode(.alwaysTemplate)
        cell.iconImageView.tintColor = orderStateColors[indexPath.row]
        if indexPath.row == selectedState{
            cell.titleLabel.textColor = UIColor.steel
            cell.iconImageView.isHidden = false
        }else{
            cell.titleLabel.textColor = UIColor.silverTen
            cell.iconImageView.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedState = indexPath.row
        collectionView.reloadData()
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        updateView()
    }
}
