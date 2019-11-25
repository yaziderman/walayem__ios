//
//  UpdateProfileViewController.swift
//  Walayem
//
//  Created by Inception on 6/1/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import os.log

class UpdateProfileViewController: UITableViewController {

    // MARK: Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    var user: User?
    
    // MARK: Actions
    
    @IBAction func unwindToProfile(sender: UIStoryboardSegue){
        if let sourceVC = sender.source as? ChangeNameViewController, let user = sourceVC.user{
            self.user = user
            nameLabel.text = user.name
        }else if let sourceVC = sender.source as? ChangePhoneViewController, let user = sourceVC.user{
            self.user = user
            phoneLabel.text = user.phone
        }
        if let navigationVC = self.splitViewController?.viewControllers.first as? UINavigationController, let chefProfileVC = navigationVC.topViewController as? ChefProfileTableViewController{
            chefProfileVC.user = self.user
            chefProfileVC.updateUI()
        }
        if let navigationVC = self.splitViewController?.viewControllers.first as? UINavigationController, let profileVC = navigationVC.topViewController as? ProfileTableViewController{
            profileVC.user = self.user
            profileVC.updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        Utils.setupNavigationBar(nav: self.navigationController!)
        updateUI()
    }
    
    // MARK: Private methods
    
    private func updateUI(){
        if let user = user{
            nameLabel.text = user.name
            emailLabel.text = user.email
            phoneLabel.text = user.phone
        }
    }
    
    // MARK: TableView delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let _ = UserDefaults.standard.string(forKey: "authToken"), indexPath.row == 4{
            return 0
        }
        //remove update emirates id row if not chef
//        if !UserDefaults.standard.bool(forKey: UserDefaultsKeys.IS_CHEF) && indexPath.row == 3{
        
        if indexPath.row == 3{
            return 0
        }
        return 70
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? ""{
        case "ChangeNameVCSegue":
            guard let destinationVC = segue.destination as? ChangeNameViewController else {
                fatalError("Unexpected destination \(segue.identifier)")
            }
            destinationVC.user = user
        case "ChangePhoneVCSegue":
            guard let destinationVc = segue.destination as? ChangePhoneViewController else {
                fatalError("Unexpected destination \(segue.identifier)")
            }
            destinationVc.user = user
        case "ChangePasswordVCSegue":
            os_log("Change password segue", log: .default, type: .debug)
            
        case "UpdateEmiratesIDSegue":
            os_log("Change emirates id segue", log: .default, type: .debug)
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }

}
