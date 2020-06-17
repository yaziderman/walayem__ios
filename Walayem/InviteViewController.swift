//
//  InviteViewController.swift
//  Walayem
//
//  Created by MAC on 4/24/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class InviteViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var sendButton: UIButton!
    
    var user: User?
    
    // MARK: Actions
    
    @IBAction func sendInvitation(_ sender: UIButton){
        let alert  = UIAlertController(title: "Invite", message: "Enter the email of your friend you want to invite.", preferredStyle: .alert)
        alert.addTextField { (emailTextField: UITextField) in
            emailTextField.placeholder = "Enter email"
            emailTextField.keyboardType = .emailAddress
        }
        
        alert.addAction(UIAlertAction(title: "Invite", style: .default, handler: { (action) in
            if let email = alert.textFields![0].text{
                self.sendInvitation(email: email)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Invite"
        user = User().getUserDefaults()
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        } 
    }
    
    override func viewWillLayoutSubviews() {
        sendButton.roundCorners([.topLeft, .topRight], radius: 20)
    }

    // MARK: Private methods
    
    private func sendInvitation(email: String){
        let activityIndicator = showActivityIndicator()
        let params: [String: Any] = ["partner_id": user?.partner_id as Any, "friend_email": email]
        
        RestClient().request(WalayemApi.invite, params, self, { (result, error) in
            activityIndicator.stopAnimating()
            var message = "Something went wrong!"
            var title = "Error"
            
            if let error = error{
                message = error.userInfo[NSLocalizedDescriptionKey] as! String
            }
            if let res = result , let value = res["result"] as? [String: Any]{
                if let msg = value["message"] as? String{
                title = "Success"
                message = msg
                }
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            
            
            
//            if error != nil{
//                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
//                print (errmsg)
//                return
//            }
//            let alert = UIAlertController(title: "Success", message: "Invitation successfully sent", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
//                self.navigationController?.popViewController(animated: true)
//            }))
//            self.present(alert, animated: true, completion: nil)
        })
    }
    
    private func showActivityIndicator() -> UIActivityIndicatorView{
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        
        let rightBarButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = rightBarButton
        activityIndicator.startAnimating()
        
        return activityIndicator
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
