//
//  ChangePasswordViewController.swift
//  Walayem
//
//  Created by Inception on 6/1/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    @IBOutlet weak var oldPwdTextField: UITextField!
    @IBOutlet weak var newPwdTextField: UITextField!
    @IBOutlet weak var oldVerifyIcon: UIImageView!
    @IBOutlet weak var newVerifyIcon: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var oldView: UIStackView!
    @IBOutlet weak var newView: UIStackView!
    
    var oldVerified = false
    var newVerified = false
    
    // MARK: Actions
    
    @IBAction func submit(_ sender: UIButton) {
        let oldPwd = oldPwdTextField.text ?? ""
        let newPwd = newPwdTextField.text ?? ""
        
        let activityIndicator = showActivityIndicator()
        OdooClient.sharedInstance().change_password(oldPassword: oldPwd, newPassword: newPwd) { (result, error) in
            activityIndicator.stopAnimating()
            if let error = error{
                let errorMsg = error.userInfo[NSLocalizedDescriptionKey] as! String
                self.showAlert(title: "Cannot change password", msg: errorMsg)
                return
            }
            guard let result = result, let value = result["result"] as? [String: Any] else{
                return
            }
            if let error = value["error"] as? String{
                self.showAlert(title: "Error", msg: error)
            }else{
				self.showAlert(title: "Success", msg: result["message"] as? String ?? "Password Updated Successfully.")
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        
        oldPwdTextField.delegate = self
        newPwdTextField.delegate = self
        oldPwdTextField.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        newPwdTextField.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        Utils.setupNavigationBar(nav: self.navigationController!)
        updateSubmitButtonState()
        
        oldPwdTextField.textColor = UIColor.textColor
        oldPwdTextField.placeHolderColor = UIColor.placeholderColor
        
        newPwdTextField.textColor = UIColor.textColor
        newPwdTextField.placeHolderColor = UIColor.placeholderColor
    }
    
    override func viewWillLayoutSubviews() {
        oldView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
        newView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
    }
    
    // MARK: Private methods
    
    private func setupViews(){
        oldPwdTextField.addImageAtLeft(UIImage(named: "lock"))
        newPwdTextField.addImageAtLeft(UIImage(named: "lock"))
//=======
//        let lockImageView1 = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 10, height: 20))
//        lockImageView1.image = UIImage(named: "lock")
//        lockImageView1.contentMode = .left
//        oldPwdTextField.leftViewMode = .always
//        oldPwdTextField.leftView = lockImageView1
//
//        let lockImageView2 = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 10, height: 20))
//        lockImageView2.image = UIImage(named: "lock")
//        lockImageView2.contentMode = .left
//        newPwdTextField.leftViewMode = .always
//        newPwdTextField.leftView = lockImageView2
//>>>>>>> Production
        
        submitButton.layer.cornerRadius = 15
        submitButton.layer.masksToBounds = true
        
        oldVerifyIcon.tintColor = .silver
        newVerifyIcon.tintColor = .silver
    }
    
    private func updateSubmitButtonState(){
        if newVerified && oldVerified{
            submitButton.isEnabled = true
            submitButton.alpha = 1
        } else {
            submitButton.isEnabled = false
            submitButton.alpha = 0.3
        }
    }
    
    private func logout(){
        OdooClient.sharedInstance().logout { (result, error) in
            self.onSessionExpired()
        }
    }
    
    private func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
			if title == "Success" {
				self.logout()
			} else {
				alert.dismiss(animated: true, completion: nil)
			}
		}))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showActivityIndicator() -> UIActivityIndicatorView{
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        let rightBarButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.setRightBarButton(rightBarButton, animated: true)
        activityIndicator.startAnimating()
        
        return activityIndicator
    }
    
    // MARK: UITextFieldDelegate
    
    @objc private func textFieldDidChange(sender: UITextField){
        switch sender{
        case oldPwdTextField:
            let password = oldPwdTextField.text ?? ""
            if Verification.isValidPassword(password){
                oldVerifyIcon.tintColor = UIColor.colorPrimary
                oldVerified = true
            }else{
                oldVerifyIcon.tintColor = UIColor.silver
                oldVerified = false
            }
        case newPwdTextField:
            let password = newPwdTextField.text ?? ""
            if Verification.isValidPassword(password){
                newVerifyIcon.tintColor = UIColor.colorPrimary
                newVerified = true
            }else{
                newVerifyIcon.tintColor = UIColor.silver
                newVerified = false
            }
        default:
            fatalError("Invalid textField")
        }
        updateSubmitButtonState()
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
