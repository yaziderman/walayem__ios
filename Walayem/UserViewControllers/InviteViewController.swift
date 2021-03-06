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
        
        RestClient().request(WalayemApi.invite, params, { (result, error) in
            activityIndicator.stopAnimating()
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                print (errmsg)
                return
            }
            let alert = UIAlertController(title: "Success", message: "Invitation successfully sent", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    private func showActivityIndicator() -> UIActivityIndicatorView{
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
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
