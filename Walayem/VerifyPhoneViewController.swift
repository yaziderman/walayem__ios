//
//  VerifyPhoneViewController.swift
//  Walayem
//
//  Created by Inception on 6/17/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import FirebaseAuth

class VerifyPhoneViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var user: User?
    
    // MARK: Actions
    
    @IBAction func skip(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: "You can update your phone number later from profile page.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Skip", style: .destructive, handler: { (action) in
            if self.user!.isChef{
                self.performSegue(withIdentifier: "VerifyEmiratesVCSegue", sender: self)
            }else{
                Utils.notifyRefresh()
                self.dismiss(animated: false) {
                    StaticLinker.signupVC?.dismiss(animated: false, completion: {
                        StaticLinker.loginVC?.dismiss(animated: false, completion: {
                            StaticLinker.loginNav?.dismiss(animated: false, completion: nil)
                        })
                    })
                }
//                self.performSegue(withIdentifier: "MainSegue", sender: self)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popOverController = alert.popoverPresentationController{
            popOverController.sourceView = sender
            popOverController.sourceRect = CGRect(x: sender.bounds.minX, y: sender.bounds.minY, width: 0, height: 0)
            popOverController.permittedArrowDirections = [.down]
        }
        present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = User().getUserDefaults()
        activityIndicator.hidesWhenStopped = true
        
        codeTextField.delegate = self
        codeTextField.becomeFirstResponder()
        codeTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
        codeTextField.textColor = UIColor.textColor
        codeTextField.placeHolderColor = UIColor.placeholderColor
    }
    
    // MARK: Private methods
    
    @objc private func keyboardWillShow(notification: Notification){
        if let userInfo = notification.userInfo{
            guard let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else{
                fatalError("Cannot convert to CGRect")
            }
            if self.view.frame.height == UIScreen.main.bounds.height{
                UIView.animate(withDuration: 0.5) {
                    self.view.frame.size.height -= keyboardFrame.height
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification){
        self.view.frame.size.height = UIScreen.main.bounds.height
    }
    
    @objc private func textFieldDidChange(_ sender: UITextField){
        let code = codeTextField.text ?? ""
        
        if code.count == 6{
            guard let verificationID = UserDefaults.standard.string(forKey: UserDefaultsKeys.FIREBASE_VERIFICATION_ID) else {
                return
            }
            
            activityIndicator.startAnimating()
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    self.activityIndicator.stopAnimating()
                    self.showMessagePrompt(error.localizedDescription)
                    return
                }
                self.sendPhoneToServer(authResult!.user.phoneNumber!)
            }
        }
    }
    
    private func sendPhoneToServer(_ phone: String){
      
        let values: [String: Any] = ["is_number_verified": true, "phone": phone]
        
        OdooClient.sharedInstance().write(model: "res.partner", ids: [user!.partner_id!], values: values) { (result, error) in
            self.activityIndicator.stopAnimating()
            if let error = error{
                let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
                self.showMessagePrompt(errmsg)
                return
            }
            UserDefaults.standard.set(phone, forKey: UserDefaultsKeys.PHONE)
            if self.user!.isChef{
                self.performSegue(withIdentifier: "VerifyEmiratesVCSegue", sender: self)
            }else{
//                self.performSegue(withIdentifier: "MainSegue", sender: self)
                
                Utils.notifyRefresh()
                self.dismiss(animated: false) {
                    StaticLinker.signupVC?.dismiss(animated: false, completion: {
                        StaticLinker.loginVC?.dismiss(animated: false, completion: {
                            StaticLinker.loginNav?.dismiss(animated: false, completion: nil)
                        })
                    })
                }
            }
        }
    }
    
    private func showMessagePrompt(_ message : String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        let newLength = text.count + string.count - range.length
        return newLength <= 6
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
