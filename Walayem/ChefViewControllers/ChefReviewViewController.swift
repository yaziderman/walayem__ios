//
//  ChefReviewViewController.swift
//  Walayem
//
//  Created by Inception on 6/24/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import FirebaseMessaging

class ChefReviewViewController: UIViewController {

    @IBAction func skipPressed(_ sender: Any) {
        Utils.SHOW_NEWDISH = true;

        self.performSegue(withIdentifier: "ChefMainSegue", sender: sender)
    }
    // MARK: Properties
    
    @IBOutlet weak var supportButton: UIButton!
    @IBOutlet weak var remindView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var user: User?
    
    
    // MARK: Actions
    
    @IBAction func changeNotificationState(_ sender: UISwitch) {
        if sender.isOn{
            Messaging.messaging().subscribe(toTopic: "V\(user!.partner_id!)i")
        }else{
            Messaging.messaging().unsubscribe(fromTopic: "V\(user!.partner_id!)i")
        }
    }
    
    @IBAction func contactSupport(_ sender: UIButton) {
        var email = UserDefaults.standard.string(forKey: "ContactEmail")
        
        if(email == nil)
        {
            email = "walayem@gmail.com"
        }
        
        let url = URL(string: "mailto:\(email!)")
        if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url!)
        }
    }
    
    @IBAction func logout(_ sender: UIButton) {
        let alert = UIAlertController(title: "Log out", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { (action) in
            self.logout()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = CGRect(x: sender.bounds.midX, y: sender.bounds.minY, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.down]
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = User().getUserDefaults()
        supportButton.layer.cornerRadius = 15
        supportButton.layer.masksToBounds = true
        
        NotificationCenter.default.addObserver(self, selector:#selector(checkChefVerification), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        checkChefVerification()
    }
    
    override func viewWillLayoutSubviews() {
        remindView.addTopBorderWithColor(color: .silver, width: 1)
        remindView.addBottomBorderWithColor(color: .silver, width: 1)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Private methods
    
    private func showMainView(){
        self.view.addSubview(mainView)
        mainView.frame = self.view.bounds
        mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @objc private func checkChefVerification(){
        activityIndicator.startAnimating()
        mainView.removeFromSuperview()
        
        let fields = ["is_chef_verified"]
        OdooClient.sharedInstance().read(model: "res.partner", ids: [user!.partner_id!], fields: fields) { (result, error) in
            self.activityIndicator.stopAnimating()
            if let _ = error{
                if self.user!.isChefVerified{
                    self.performSegue(withIdentifier: "ChefMainSegue", sender: self)
                }else{
                    self.showMainView()
                    
                }
                return
            }
            let records = result!["result"] as! [Any]
            guard let record = records[0] as? [String: Any] else {
                return
            }
            let isChefVerified = record["is_chef_verified"] as! Bool
            UserDefaults.standard.set(isChefVerified, forKey: UserDefaultsKeys.IS_CHEF_VERIFIED)
            if isChefVerified{
                self.performSegue(withIdentifier: "ChefMainSegue", sender: self)
            }else{
                self.showMainView()
            }
        }
    }
    
    private func logout(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let client = OdooClient.sharedInstance()
        client.logout(completionHandler: { (result, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let error = error{
                let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
                self.showMessagePrompt(title: "cannot logout", msg: errmsg)
                return
            }
            
            Messaging.messaging().unsubscribe(fromTopic: "alli")
            Messaging.messaging().unsubscribe(fromTopic: "\(self.user!.partner_id!)i")
            Messaging.messaging().unsubscribe(fromTopic: "alluseri")
            User().clearUserDefaults()
            DatabaseHandler().clearDatabase()
            OdooClient.destroy()
            
            let viewController : UIViewController = UIStoryboard(name: "User", bundle: nil).instantiateInitialViewController()!
            self.present(viewController, animated: true, completion: nil)
        })
    }
    
    private func showMessagePrompt(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
