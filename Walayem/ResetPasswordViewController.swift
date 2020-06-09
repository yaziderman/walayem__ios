//
//  ResetPasswordViewController.swift
//  Walayem
//
//  Created by MAC on 4/18/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailVerifyImageView: UIImageView!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var emailView: UIStackView!
    
    
    // MARK: Actions
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func request(_ sender: UIButton) {
        let activityIndicator = showActivityIndicator()
        requestButton.isEnabled = false
        
        let email = emailTextField.text ?? ""
        let params = ["login": email]
        
        RestClient().request(WalayemApi.changePassword, params) { (result, error) in
            activityIndicator.stopAnimating()
            self.requestButton.isEnabled = true
            var message = "Something went wrong!"
            var title = "Error"
            if let error = error{
                
                message = error.userInfo[NSLocalizedDescriptionKey] as! String
            
//                let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
//                let alert = UIAlertController(title: "Error", message: errmsg, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//                return
                
            }
            if let res = result , let value = res["result"] as? [String: Any]{
                if let msg = value["message"] as? String{
                   title = "Success"
                message = msg
                }
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)}))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestButton.layer.cornerRadius = 12
        requestButton.layer.masksToBounds = false
        
<<<<<<< HEAD
        emailTextField.addImageAtLeft(UIImage(named: "email"))
=======
        let emailImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 10, height: 20))
        emailImageView.image = UIImage(named: "email")
        emailImageView.contentMode = UIView.ContentMode.left
        emailTextField.leftViewMode = .always
        emailTextField.leftView = emailImageView
>>>>>>> Production
        
        emailTextField.delegate = self
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        requestButton.isEnabled = false
        requestButton.alpha = 0.3
        
        Utils.setupNavigationBar(nav: self.navigationController!)
        
        emailTextField.textColor = UIColor.textColor
        emailTextField.placeHolderColor = UIColor.placeholderColor
    }
    
    override func viewWillLayoutSubviews() {
         emailView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
    }

    // MARK: Private methods
    
    private func showActivityIndicator() -> UIActivityIndicatorView{
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        
        let rightBarItem = UIBarButtonItem(customView: activityIndicator)
        navigationItem.rightBarButtonItem = rightBarItem
        
        activityIndicator.startAnimating()
        return activityIndicator
    }

   
    // MARK: UITextFieldDelegate
    
    @objc private func textFieldDidChange(_ sender: UITextField){
        let email = emailTextField.text ?? ""
        if Verification.isValidEmail(email){
            emailVerifyImageView.tintColor = UIColor.colorPrimary
            requestButton.isEnabled = true
            requestButton.alpha = 1
        }else{
            emailVerifyImageView.tintColor = UIColor.silver
            requestButton.isEnabled = false
            requestButton.alpha = 0.3
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
