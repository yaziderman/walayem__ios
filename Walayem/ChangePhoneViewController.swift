//
//  ChangePhoneViewController.swift
//  Walayem
//
//  Created by  Rohan Shrestha on 6/2/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import FirebaseAuth

class ChangePhoneViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var phoneVerifyIcon: UIImageView!
    @IBOutlet weak var phoneView: UIStackView!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet var verifyView: UIView!
    
    var user: User?
    var verificationID: String!
    var phoneVerified = false
    
    // MARK: Actions
    
    @IBAction func verify(_ sender: UIButton) {
        let countryCode = "+971"
        let phoneNumber = countryCode + (phoneTextField.text ?? "")
        
        let alert = UIAlertController(title: "", message: "Is \(phoneNumber) your phone number?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Verify", style: .default, handler: { (action) in
            let activityIndicator = self.showActivityIndicator()
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil, completion: { (verificationID, error) in
                activityIndicator.stopAnimating()
                if let error = error {
                    self.showMessagePrompt(error.localizedDescription)
                    return
                }
                self.verificationID = verificationID
                self.verifyView.frame = self.view.bounds
                self.verifyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.view.addSubview(self.verifyView)
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popOverController = alert.popoverPresentationController{
            popOverController.sourceView = sender
            popOverController.sourceRect = CGRect(x: sender.bounds.midX, y: sender.bounds.maxY, width: 0, height: 0)
            popOverController.permittedArrowDirections = [.up]
        }
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func updatePhone(_ sender: UIButton) {
        let activityIndicator = showActivityIndicator()
        let verificationCode = codeTextField.text ?? ""
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            activityIndicator.stopAnimating()
            if let _ = error {
                return
            }
            self.sendPhoneToServer(authResult!.user.phoneNumber!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        phoneTextField.delegate = self
        codeTextField.delegate = self
        phoneTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged) 
        codeTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        phoneTextField.becomeFirstResponder()
        
        updateVerifyButtonState()
        updateUpdateButtonState()
        Utils.setupNavigationBar(nav: self.navigationController!)
                
        phoneTextField.textColor = UIColor.textColor
        phoneTextField.placeHolderColor = UIColor.placeholderColor
        

        
        codeTextField.textColor = UIColor.textColor
        codeTextField.placeHolderColor = UIColor.placeholderColor
    }
    
    override func viewWillLayoutSubviews() {
        phoneView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
        codeTextField.addBottomBorderWithColor(color: UIColor.silver, width: 1)
    }

    // MARK: Private methods
    
    private func setViews(){
        
        let phoneImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 18 + 2, height: 20))
        phoneImageView.image = UIImage(named: "phone")
//        phoneImageView.contentMode = .left
        
        let prefix = UILabel(frame: CGRect(x: 30, y:0, width: 40, height: 20))
        prefix.text = "+971 -"
        prefix.sizeToFit()
        prefix.textColor = UIColor.textColor
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20 + 65, height: 20))
        
        leftView.addSubview(phoneImageView)
        leftView.addSubview(prefix)
        leftView.contentMode = .left
        
        
        phoneTextField.leftViewMode = .always
//        phoneTextField.leftView = phoneImageView + prefix
        
        phoneTextField.leftView = leftView
//        phoneTextField.leftViewMode = .always
        
        
        verifyButton.layer.cornerRadius = 15
        verifyButton.layer.masksToBounds = true
        updateButton.layer.cornerRadius = 15
        updateButton.layer.masksToBounds = true
        
        phoneVerifyIcon.tintColor = .silver
    }
    
    @objc private func textFieldDidChange(_ sender: UITextField){
        if sender == phoneTextField{
            let phone = phoneTextField.text ?? ""
            if Verification.isValidPhoneNumber(phone){
                phoneVerifyIcon.tintColor = UIColor.colorPrimary
                phoneVerified = true
            }else {
                phoneVerifyIcon.tintColor = UIColor.silver
                phoneVerified = false
            }
            updateVerifyButtonState()
        } else if sender == codeTextField{
            updateUpdateButtonState()
        }
    }
    
    private func updateVerifyButtonState(){
        if phoneVerified{
            verifyButton.isEnabled = true
            verifyButton.alpha = 1
        }else{
            verifyButton.isEnabled = false
            verifyButton.alpha = 0.3
        }
    }
    
    private func updateUpdateButtonState(){
        let code = codeTextField.text ?? ""
        if code.count == 6{
            updateButton.isEnabled = true
            updateButton.alpha = 1
        }else{
            updateButton.isEnabled = false
            updateButton.alpha = 0.3
        }
    }
    
    private func sendPhoneToServer(_ phone: String){
        
      let values: [String: Any] = ["is_number_verified": true, "phone": phone]
        
        let activityIndicator = showActivityIndicator()
        OdooClient.sharedInstance().write(model: "res.partner", ids: [user!.partner_id!], values: values) { (result, error) in
            activityIndicator.stopAnimating()
            if let error = error{
                let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
                print (errmsg)
                return
            }
            UserDefaults.standard.set(phone, forKey: UserDefaultsKeys.PHONE)
            self.user?.phone = phone
            self.performSegue(withIdentifier: "UpdateProfileUnwindSegue", sender: self)
        }
    }
    
    private func showActivityIndicator() -> UIActivityIndicatorView{
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        
        let rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        activityIndicator.startAnimating()
        
        return activityIndicator
    }
    
    private func showMessagePrompt(_ message : String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    
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
