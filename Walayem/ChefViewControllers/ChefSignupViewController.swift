//
//  ChefSignupViewController.swift
//  Walayem
//
//  Created by MACBOOK PRO on 5/6/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import FirebaseMessaging
import FirebaseAuth

class ChefSignupViewController: UIViewController, UITextFieldDelegate{
    
    // MARK: Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameIndicator: UIImageView!
    @IBOutlet weak var emailIndicator: UIImageView!
    @IBOutlet weak var phoneIndicator: UIImageView!
    @IBOutlet weak var passwordIndicator: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var nameView: UIStackView!
    @IBOutlet weak var emailView: UIStackView!
    @IBOutlet weak var phoneView: UIStackView!
    @IBOutlet weak var passwordView: UIStackView!
    
    var emailVerified: Bool = false
    var nameVerified: Bool = false
    var phoneVerified: Bool = false
    var passwordVerified: Bool = false
    var emiratesIDAdded: Bool = false
    
    var progressAlert: UIAlertController?
    
    // MARK: Actions
    
    @IBAction func cancel(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signup(_ sender: Any) {
        
        if(nameTextField.text!.isEmpty || emailTextField.text!.isEmpty ||
            phoneTextField.text!.isEmpty ||
            passwordTextField.text!.isEmpty)
        {
            self.showMessagePrompt("All the fields are mandatory.")
            return;
        }
        
        if(!nameVerified)
        {
            self.showMessagePrompt("Invalid name.")
            return;
        }
        else if(!emailVerified)
        {
            self.showMessagePrompt("Invalid email.")
            return;
        }
        else if(!phoneVerified)
        {
            self.showMessagePrompt("Phone number should be valid and start with 971.")
            return;
        }
        else if(!passwordVerified)
        {
            self.showMessagePrompt("Password must be at least 6 characters.")
            return;
        }
        
        let name = nameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let phone = phoneTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        let params: [String : Any] = ["name": name,
                                      "login": email,
                                      "password": password,
                                      "confirm_password": password,
                                      "is_chef": true]
        
        
        progressAlert = showProgressAlert()
        
        RestClient().request(WalayemApi.signup, params) { (result, error) in
            if error != nil{
                self.progressAlert?.dismiss(animated: false, completion: {
                    let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                    self.showMessagePrompt(errmsg)
                })
                return
            }
            let record = result!["result"] as! [String: Any]
            if let errmsg = record["error"] as? String{
                self.progressAlert?.dismiss(animated: false, completion: {
                    self.showMessagePrompt(errmsg)
                })
                return
            }
            else{
                PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil, completion: { (verificationID, error) in
                    if let error = error {
                        self.progressAlert?.dismiss(animated: false, completion: {
                            self.showMessagePrompt(error.localizedDescription)
                        })
                        return
                    }
                    UserDefaults.standard.set(verificationID, forKey: UserDefaultsKeys.FIREBASE_VERIFICATION_ID)
                })
            }
            
            let data = record["data"] as! [String: Any]
            let sessionId: String = data["session_id"] as! String
            UserDefaults.standard.set(sessionId, forKey: UserDefaultsKeys.SESSION_ID)
            self.loadUserDetails()
        }
        
        
        

//        progressAlert = showProgressAlert()
//        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil, completion: { (verificationID, error) in
//            if let error = error {
//                self.progressAlert?.dismiss(animated: false, completion: {
//                    self.showMessagePrompt(error.localizedDescription)
//                })
//                return
//            }
//            UserDefaults.standard.set(verificationID, forKey: UserDefaultsKeys.FIREBASE_VERIFICATION_ID)
            
            
//            RestClient().request(WalayemApi.signup, params) { (result, error) in
//                if error != nil{
//                    self.progressAlert?.dismiss(animated: false, completion: {
//                        let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
//                        self.showMessagePrompt(errmsg)
//                    })
//                    return
//                }
//                let record = result!["result"] as! [String: Any]
//                if let errmsg = record["error"] as? String{
//                    self.progressAlert?.dismiss(animated: false, completion: {
//                        self.showMessagePrompt(errmsg)
//                    })
//                    return
//                }
//                let data = record["data"] as! [String: Any]
//                let sessionId: String = data["session_id"] as! String
//                UserDefaults.standard.set(sessionId, forKey: UserDefaultsKeys.SESSION_ID)
//                self.loadUserDetails()
//            }
//        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        signUpButton.layer.cornerRadius = 12
        signUpButton.layer.masksToBounds = false
        addImageInsideTextField()
    
        passwordTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        phoneTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        nameIndicator.tintColor = UIColor.silver
        emailIndicator.tintColor = UIColor.silver
        phoneIndicator.tintColor = UIColor.silver
        passwordIndicator.tintColor = UIColor.silver
        
        updateSignupButtonState()
    }

    override func viewWillLayoutSubviews() {
        addBottomBorder()
    }
   
    // MARK: Private methods
    
    private func addImageInsideTextField(){
        let userImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 10, height: 20))
        userImageView.image = UIImage(named: "user")
        userImageView.contentMode = .left
        userImageView.tintColor = UIColor.colorPrimary
        nameTextField.leftViewMode = .always
        nameTextField.leftView = userImageView
        
        let emailImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 10, height: 20))
        emailImageView.image = UIImage(named: "email")
        emailImageView.contentMode = .left
        emailTextField.leftViewMode = .always
        emailTextField.leftView = emailImageView
        
        let phoneImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 10, height: 20))
        phoneImageView.image = UIImage(named: "phone")
        phoneImageView.contentMode = .left
        phoneTextField.leftViewMode = .always
        phoneTextField.leftView = phoneImageView
        
        let lockImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 10, height: 20))
        lockImageView.image = UIImage(named: "lock")
        lockImageView.contentMode = .left
        passwordTextField.leftViewMode = .always
        passwordTextField.leftView = lockImageView
    }
    
    private func addBottomBorder(){
        nameView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
        emailView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
        phoneView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
        passwordView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
    }
    
    private func updateSignupButtonState(){
//        if nameVerified && emailVerified && passwordVerified{
//            signUpButton.isEnabled = true
//            signUpButton.alpha = 1
//        }else{
//            signUpButton.isEnabled = false
//            signUpButton.alpha = 0.3
//        }
    }
    
    private func verifyPhone(_ phone: String){
        
    }
    
    private func loadUserDetails(){
        let fields = ["id", "name", "is_chef", "is_chef_verified", "kitchen_id", "email"]
        
        OdooClient.sharedInstance().searchRead(model: "res.partner", domain: [], fields: fields, offset: 0, limit: 1, order: "name ASC") { (result, error) in
            self.progressAlert?.dismiss(animated: true, completion: {
                if error != nil{
                    let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                    print (errmsg)
                    return
                }
                
                let records = result!["records"] as! [Any]
                if let record = records[0] as? [String : Any]{
                    let partnerId = record["id"] as! Int
                    let user = User(record: record)
                    self.subscribeToFirebaseTopics(partnerId)
                    self.saveUserInDevice(user: user, partnerId: partnerId)
                }
            })
        }
    }
    
    private func saveUserInDevice(user: User, partnerId: Int){
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(user.name, forKey: UserDefaultsKeys.NAME)
        userDefaults.set(user.email, forKey: UserDefaultsKeys.EMAIL)
        userDefaults.set(user.isChef, forKey: UserDefaultsKeys.IS_CHEF)
        userDefaults.set(partnerId, forKey: UserDefaultsKeys.PARTNER_ID)
        
        userDefaults.synchronize()
        
        performSegue(withIdentifier: "VerifyPhoneSegue", sender: self)
    }
    
    private func subscribeToFirebaseTopics(_ partnerId: Int){
        Messaging.messaging().subscribe(toTopic: "alli")
        Messaging.messaging().subscribe(toTopic: "\(partnerId)i")
        Messaging.messaging().subscribe(toTopic: "allchefi")
       
    }
    
    private func showMessagePrompt(_ message: String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: false, completion: nil)
    }
    
    private func showProgressAlert() -> UIAlertController{
        let alert = UIAlertController(title: "Signing up", message: "Please wait...", preferredStyle: .alert)
        
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(indicator)
        
        let views = ["pending" : alert.view, "indicator" : indicator]
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[indicator]-(-50)-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[indicator]|", options: NSLayoutConstraint.FormatOptions.alignAllCenterX, metrics: nil, views: views)
        alert.view.addConstraints(constraints)
        
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        
        present(alert, animated: false, completion: nil)
        
        return alert
    }
    
    // MARK: UITextFieldDelegate
    
    @objc private func textFieldDidChange(_ sender : UITextField){
        switch sender{
        case nameTextField:
            let name = nameTextField.text ?? ""
            if Verification.isValidName(name){
                nameIndicator.tintColor = UIColor.colorPrimary
                nameVerified = true
            }else{
                nameIndicator.tintColor = UIColor.silver
                nameVerified = false
            }
        case emailTextField:
            
            emailTextField.text = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let email = emailTextField.text ?? ""
            if Verification.isValidEmail(email){
                emailIndicator.tintColor = UIColor.colorPrimary
                emailVerified = true
            }else{
                emailIndicator.tintColor = UIColor.silver
                emailVerified = false
            }
        case phoneTextField:
            let phone = phoneTextField.text ?? ""
            if Verification.isValidPhoneNumber(phone){
                phoneIndicator.tintColor = UIColor.colorPrimary
                phoneVerified = true
            }else{
                phoneIndicator.tintColor = UIColor.silver
                phoneVerified = false
            }
        case passwordTextField:
            let password = passwordTextField.text ?? ""
            if Verification.isValidPassword(password){
                passwordIndicator.tintColor = UIColor.colorPrimary
                passwordVerified = true
            }else{
                passwordIndicator.tintColor = UIColor.silver
                passwordVerified = false
            }
        default:
            print ("TextField does not exist")
        }

        updateSignupButtonState()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}
