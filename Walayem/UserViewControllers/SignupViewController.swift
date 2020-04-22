//
//  SignupViewController.swift
//  Walayem
//
//  Created by MAC on 4/17/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import FacebookCore
import FacebookLogin
import FBSDKLoginKit
import GoogleSignIn
import FirebaseMessaging
import FirebaseAuth
import BetterSegmentedControl

class SignupViewController: UIViewController, UITextFieldDelegate, GIDSignInDelegate {

    // MARK: Properties
    
    @IBOutlet weak var customerView: UIStackView!
    @IBOutlet weak var chefView: UIStackView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var nameView: UIStackView!
    @IBOutlet weak var emailView: UIStackView!
    @IBOutlet weak var phoneView: UIStackView!
    @IBOutlet weak var passwordView: UIStackView!
    
    @IBOutlet weak var nameVerifyImageView: UIImageView!
    @IBOutlet weak var emailVerifyImageView: UIImageView!
    @IBOutlet weak var phoneVerifyImageView: UIImageView!
    @IBOutlet weak var passwordVerifyImageView: UIImageView!

    @IBOutlet weak var chefNameTextField: UITextField!
    @IBOutlet weak var chefEmailTextField: UITextField!
    @IBOutlet weak var chefPhoneTextField: UITextField!
    @IBOutlet weak var chefPasswordTextField: UITextField!
    
    @IBOutlet weak var chefNameVerifyImageView: UIImageView!
    @IBOutlet weak var chefEmailVerifyImageView: UIImageView!
    @IBOutlet weak var chefPhoneVerifyImageView: UIImageView!
    @IBOutlet weak var chefPasswordVerifyImageView: UIImageView!
    
    @IBOutlet weak var chefNameView: UIStackView!
    @IBOutlet weak var chefEmailView: UIStackView!
    @IBOutlet weak var chefPhoneView: UIStackView!
    @IBOutlet weak var chefPasswordView: UIStackView!
    
    
    var emailVerified: Bool = false
    var nameVerified: Bool = false
    var phoneVerified: Bool = false
    var passwordVerified: Bool = false
    
    var chefEmailVerified: Bool = false
    var chefNameVerified: Bool = false
    var chefPhoneVerified: Bool = false
    var chefPasswordVerified: Bool = false
    
    var image64: String?
    
    var isChef: Bool = false
    
    var progressAlert: UIAlertController?
    
    @IBOutlet weak var btnCustomer: UIButton!
    @IBOutlet weak var btnChef: UIButton!
    // MARK: Actions
    
    @IBOutlet weak var lbSocialSignUp: UILabel!
    @IBOutlet weak var socialPanel: UIStackView!
    @IBOutlet weak var vDivider: UIView!
    
    
    @IBAction func back(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    private func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signup(_ sender: Any) {
        
        if(!self.isChef)
        {
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
                self.showMessagePrompt("Password must be at least 6  characters.")
                return;
            }

            let countryCode = "+971"
            let name = nameTextField.text ?? ""
            let email = emailTextField.text ?? ""
            let phone = countryCode + (phoneTextField.text ?? "")
            let password = passwordTextField.text ?? ""
            
            let params: [String : Any] = ["name": name,
                                          "login": email,
                                          "password": password,
                                          "confirm_password": password,
                                          "is_chef": false]
            
            
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
                    self.showMessagePrompt(errmsg)
                    return
                }
                else {
                    PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil, completion: { (verificationID, error) in

                        Utils.setUserDefaults(value: verificationID ?? "", key: UserDefaultsKeys.FIREBASE_VERIFICATION_ID)
                        
                            if let error = error {
                                self.progressAlert?.dismiss(animated: false, completion: {
                                    self.showMessagePrompt(error.localizedDescription)
                                })
                                return
                            }
                            print("VERRRRR---- :\(verificationID)")
                        })
                }
                
                
                let data = record["data"] as! [String: Any]
                let sessionId: String = data["session_id"] as! String
                UserDefaults.standard.set(sessionId, forKey: UserDefaultsKeys.SESSION_ID)
                self.loadUserDetails()
            }

        }
        else{
    // MARK: Chef SIGN UP
            let session = UserDefaults.standard.string(forKey: UserDefaultsKeys.SESSION_ID)
            if (session == nil){
                
                if(chefNameTextField.text!.isEmpty || chefEmailTextField.text!.isEmpty ||
                    chefPhoneTextField.text!.isEmpty ||
                    chefPasswordTextField.text!.isEmpty)
                {
                    self.showMessagePrompt("All the fields are mandatory.")
                    return;
                }
                    
                if(!chefNameVerified)
                {
                    self.showMessagePrompt("Invalid name.")
                    return;
                }
                else if(!chefEmailVerified)
                {
                    self.showMessagePrompt("Invalid email.")
                    return;
                }
                else if(!chefPhoneVerified)
                {
                    self.showMessagePrompt("Phone number should be valid and start with 971.")
                    return;
                }
                else if(!chefPasswordVerified)
                {
                    self.showMessagePrompt("Password must be at least 6 characters.")
                    return;
                }
                let countryCode = "+971"
                let name = chefNameTextField.text ?? ""
                let email = chefEmailTextField.text ?? ""
                let phone = countryCode + (chefPhoneTextField.text ?? "")
                let password = chefPasswordTextField.text ?? ""
                
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
//                                self.progressAlert?.dismiss(animated: false, completion: {
////                                    self.showMessagePrompt(error.localizedDescription)
//                                })
                                print(error.localizedDescription)
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
            } else {
                self.logout()
            }
            
        }
        
        
    }
    
    
       private func logout(){
            let client = OdooClient.sharedInstance()
            client.logout(completionHandler: { (result, error) in
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error{
                    let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
//                    self.showAlert(title: "cannot logout", msg: errmsg)
                    User().clearUserDefaults()
                    OdooClient.destroy()
                    return
                }
                let userId = UserDefaults.standard.integer(forKey: UserDefaultsKeys.PARTNER_ID)
                Messaging.messaging().unsubscribe(fromTopic: "alli")
                Messaging.messaging().unsubscribe(fromTopic: "\(userId)i")
                Messaging.messaging().unsubscribe(fromTopic: "alluseri")
                User().clearUserDefaults()
                OdooClient.destroy()
                
                StaticLinker.mainVC?.selectedIndex = 0
//                Utils.notifyRefresh()
                self.signup(self)
            })
        
            
        }
    
    @IBAction func signupViaFb(_ sender: UIButton) {
        let loginManager = LoginManager()
        loginManager.logOut()
        loginManager.logIn(permissions: [.publicProfile, .email], viewController: self) { (loginResult) in
            switch loginResult{
            case .failed(let error):
                print (error)
            case .cancelled:
                print ("User cancelled login")
            case .success( _, _, let accessToken):
                
                self.progressAlert = self.showProgressAlert()
                let myGraphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture.width(400), gender"], tokenString:accessToken.tokenString, version: Settings.defaultGraphAPIVersion, httpMethod: .get)
                myGraphRequest.start(completionHandler: { (connection, result, error) in
                    if let res = result {
                        var responseDict = res as! [String:Any]
                        _ = responseDict["name"] as! String
//                        _ = responseDict["email"] as! String
                        _ = responseDict["id"] as! String
                        let pictureDict = responseDict["picture"] as! [String:Any]
                        let imageDict = pictureDict["data"] as! [String:Any]
                        let imageUrl = imageDict["url"] as! String
                        if responseDict["id"] != nil{
                            // download image from facebook
                            let image_url = URL(string: imageUrl)
                            ImageDownloader.default.downloadImage(with: image_url!, options: [], progressBlock: nil, completionHandler: { (image, error, url, data) in
                                self.image64 = Utils.encodeImage(image!)
                            })
                        }
                        self.sendFbData(token: accessToken.tokenString)
                    }
                    else
                    {
                        self.showMessagePrompt("Unable to get Profile information From facebook")
                        print("Graph Request Failed: \(error ?? error.debugDescription as! Error)")
                    }
                }
                )}
        }
    }
    
    @IBAction func signupViaGoogle(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
        
        // Add try-catch here
        
//        GIDSignIn.sharedInstance()?.uidelegate = self
//        try this GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        signupButton.layer.cornerRadius = 12
        signupButton.layer.masksToBounds = false
        addImageInsideTextField()
        
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        phoneTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        passwordTextField.delegate = self
        emailTextField.delegate = self
        
        nameVerifyImageView.tintColor = UIColor.silver
        emailVerifyImageView.tintColor = UIColor.silver
        phoneVerifyImageView.tintColor = UIColor.silver
        passwordVerifyImageView.tintColor = UIColor.silver
        
        
        chefNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        chefEmailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        chefPhoneTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        chefPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        chefPasswordTextField.delegate = self
        chefEmailTextField.delegate = self
        
        chefNameVerifyImageView.tintColor = UIColor.silver
        chefEmailVerifyImageView.tintColor = UIColor.silver
        chefPhoneVerifyImageView.tintColor = UIColor.silver
        chefPasswordVerifyImageView.tintColor = UIColor.silver

        updateSignupButtonState()
        
        self.btnCustomer.layer.borderWidth = 1
        self.btnChef.layer.borderWidth = 1
        
        self.btnCustomer.layer.borderColor = UIColor.colorPrimary.cgColor
        self.btnChef.layer.borderColor = UIColor.colorPrimary.cgColor
        
        nameTextField.placeHolderColor = UIColor.placeholderColor
        nameTextField.textColor = UIColor.textColor
        
        emailTextField.placeHolderColor = UIColor.placeholderColor
        emailTextField.textColor = UIColor.textColor
        
        phoneTextField.placeHolderColor = UIColor.placeholderColor
        phoneTextField.textColor = UIColor.textColor
        
        passwordTextField.placeHolderColor = UIColor.placeholderColor
        passwordTextField.textColor = UIColor.textColor
        
        chefNameTextField.placeHolderColor = UIColor.placeholderColor
        chefNameTextField.textColor = UIColor.textColor
        
        chefEmailTextField.placeHolderColor = UIColor.placeholderColor
        chefEmailTextField.textColor = UIColor.textColor
        
        chefPhoneTextField.placeHolderColor = UIColor.placeholderColor
        chefPhoneTextField.textColor = UIColor.textColor
        
        chefPasswordTextField.placeHolderColor = UIColor.placeholderColor
        chefPasswordTextField.textColor = UIColor.textColor
        
        
        StaticLinker.signupVC = self
        
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
        
        let phoneImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 0, height: 20))
        phoneImageView.image = UIImage(named: "phone")
        phoneImageView.contentMode = .left
        
        let prefix = UILabel(frame: CGRect(x: 18, y:0, width: 40, height: 20))
        prefix.text = "+971 -"
        prefix.sizeToFit()
        prefix.textColor = UIColor.textColor
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20 + 50, height: 20))
        
        leftView.addSubview(phoneImageView)
        leftView.addSubview(prefix)
        leftView.contentMode = .left
        
        phoneTextField.leftView = leftView
        phoneTextField.leftViewMode = .always
        phoneTextField.placeholder = "50XXXXXXX"
        
//        phoneTextField.leftView = phoneImageView
        
        let lockImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 10, height: 20))
        lockImageView.image = UIImage(named: "lock")
        lockImageView.contentMode = .left
        passwordTextField.leftViewMode = .always
        passwordTextField.leftView = lockImageView
        
        
        let chefUserImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 10, height: 20))
        chefUserImageView.image = UIImage(named: "user")
        chefUserImageView.contentMode = .left
        chefUserImageView.tintColor = UIColor.colorPrimary
        chefNameTextField.leftViewMode = .always
        chefNameTextField.leftView = chefUserImageView
        
        let chefEmailImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 10, height: 20))
        chefEmailImageView.image = UIImage(named: "email")
        chefEmailImageView.contentMode = .left
        chefEmailTextField.leftViewMode = .always
        chefEmailTextField.leftView = chefEmailImageView
        
        let chefPhoneImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 0, height: 20))
        chefPhoneImageView.image = UIImage(named: "phone")
        chefPhoneImageView.contentMode = .left
        //
        
        let prefix2 = UILabel(frame: CGRect(x: 18, y:0, width: 40, height: 20))
        prefix2.text = "+971 -"
        prefix2.sizeToFit()
        prefix2.textColor = UIColor.textColor

        let leftView2 = UIView(frame: CGRect(x: 0, y: 0, width: 20 + 50, height: 20))

        leftView2.addSubview(chefPhoneImageView)
        leftView2.addSubview(prefix2)
        leftView2.contentMode = .left
        
        
        chefPhoneTextField.leftViewMode = .always
        chefPhoneTextField.leftView = leftView2
        chefPhoneTextField.placeholder = "50XXXXXXX"
        
        let chefLockImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 10, height: 20))
        chefLockImageView.image = UIImage(named: "lock")
        chefLockImageView.contentMode = .left
        chefPasswordTextField.leftViewMode = .always
        chefPasswordTextField.leftView = chefLockImageView
    }
    
    private func addBottomBorder(){
        nameView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
        emailView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
        phoneView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
        passwordView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
        chefNameView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
        chefEmailView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
        chefPhoneView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
        chefPasswordView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
    }
    
    private func updateSignupButtonState(){
//        if nameVerified && emailVerified && passwordVerified{
//            signupButton.isEnabled = true
//            signupButton.alpha = 1
//        }else{
//            signupButton.isEnabled = false
//            signupButton.alpha = 0.3
//        }
    }
    
    private func sendFbData(token: String){
        let url = "\(WalayemApi.BASE_URL)/auth_oauth/apisignin?state=%7B%22p%22%3A+2%2C+%22d%22%3A+%22\(WalayemApi.DB_NAME)%22%2C+%22r%22%3A+%22http%253A%252F%252F\(WalayemApi.BASE_URL.replacingOccurrences(of: "http://", with: ""))%252Fweb%22%7D&access_token=\(token)&expires_in=5486"
        
        Alamofire.request(url, method: .get).validate().responseJSON { (response) in
            if response.result.isSuccess{
                let value = response.result.value as! [String : Any]
                if let sessionId = value["result"] as? String
                {
                UserDefaults.standard.set(sessionId, forKey: "sessionId")
                self.loadUserDetails()
                }
                else
                {
                    self.progressAlert?.dismiss(animated: false, completion: {
                        self.showMessagePrompt("An account with the provided email address already exists.")
                    })
                }
            }else{
                self.progressAlert?.dismiss(animated: false, completion: {
                    self.showMessagePrompt("An account with the provided email address already exists.")
                })
            }
        }
    }
    
    private func sendGoogleData(token: String){
        let url = "\(WalayemApi.BASE_URL)/auth_oauth/apisignin?state=%7B%22p%22:+3,+%22r%22:+%22http%253A%252F%252F\(WalayemApi.BASE_URL.replacingOccurrences(of: "http://", with: ""))%252Fweb%22,+%22d%22:+%22\(WalayemApi.DB_NAME)%22%7D&access_token=\(token)&token_type=Bearer&expires_in=3600"
        
        Alamofire.request(url, method: .get).validate().responseJSON { (response) in
            if response.result.isSuccess{
                let value = response.result.value as! [String : Any]
                if let sessionId = value["result"] as? String
                {
                UserDefaults.standard.set(sessionId, forKey: "sessionId")
                self.loadUserDetails()
                }
                else
                {
                    self.progressAlert?.dismiss(animated: false, completion: {
                        self.showMessagePrompt("An account with the provided email address already exists.")
                    })
                }
            }else{
                self.progressAlert?.dismiss(animated: false, completion: {
                    self.showMessagePrompt("An account with the provided email address already exists.")
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (StaticLinker.chefLoginFromHome){
            self.btnCustomer.isEnabled = false
            self.onChef(self)
            StaticLinker.chefLoginFromHome = false
        }
    }
    
    private func loadUserDetails(){
        let fields = ["id", "name", "is_chef", "is_chef_verified", "kitchen_id", "email", "is_image_set"]
        
        OdooClient.sharedInstance().searchRead(model: "res.partner", domain: [], fields: fields, offset: 0, limit: 1, order: "name ASC") { (result, error) in
            if error != nil{
                self.progressAlert?.dismiss(animated: false, completion: {
                    let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                    print (errmsg)
                })
                return
            }
            
            let records = result!["records"] as? [Any]
            
            if records!.count > 0 {
                if(!self.isChef)
                {
                    if records![0] != nil{
                        if let record = records![0] as? [String : Any]{
                            let partnerId = record["id"] as! Int
                            let isImageSet = record["is_image_set"] as! Bool
                            let user = User(record: record)
                            self.saveUserInDevice(user: user, partnerId: partnerId)
                            self.uploadImage(partnerId: partnerId, isImageSet: isImageSet)
                        }
                    }
                }
                else
                {   do{
                    if let record = records![0] as? [String : Any]{
                        let partnerId = record["id"] as! Int
                        let user = User(record: record)
                        self.subscribeToFirebaseTopics(partnerId)
                        self.saveUserInDevice(user: user, partnerId: partnerId)
                    }
                    }
                catch{
                    
                    }
                }
            }
        }
    }
    
    private func uploadImage(partnerId: Int, isImageSet: Bool){
        if let image = image64, !isImageSet{
            let values : [String : Any] = ["image": image, "is_image_set": true]
            OdooClient.sharedInstance().write(model: "res.partner", ids: [partnerId], values: values) { (result, error) in
                self.progressAlert?.dismiss(animated: false, completion: {
                     self.performSegue(withIdentifier: "VerifyPhoneSegue", sender: self)
                })
            }
        }else{
            self.progressAlert?.dismiss(animated: false, completion: {
                self.performSegue(withIdentifier: "VerifyPhoneSegue", sender: self)
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
        
        if(self.isChef)
        {
            self.progressAlert?.dismiss(animated: false, completion: {
                self.performSegue(withIdentifier: "VerifyPhoneSegue", sender: self)
            })

//            self.performSegue(withIdentifier: "VerifyPhoneSegue", sender: self)
        }
    }
    
    private func subscribeToFirebaseTopics(_ partnerId: Int){
        Messaging.messaging().subscribe(toTopic: "alli")
        Messaging.messaging().subscribe(toTopic: "\(partnerId)i")
        Messaging.messaging().subscribe(toTopic: "alluseri")
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
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[indicator]-(-50)-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: views as [String : Any])
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[indicator]|", options: NSLayoutConstraint.FormatOptions.alignAllCenterX, metrics: nil, views: views as [String : Any])
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
                nameVerifyImageView.tintColor = UIColor.colorPrimary
                nameVerified = true
            }else{
                nameVerifyImageView.tintColor = UIColor.silver
                nameVerified = false
            }
        case emailTextField:
            emailTextField.text = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let email = emailTextField.text ?? ""
            if Verification.isValidEmail(email){
                emailVerifyImageView.tintColor = UIColor.colorPrimary
                emailVerified = true
            }else{
                emailVerifyImageView.tintColor = UIColor.silver
                emailVerified = false
            }
        case phoneTextField:
            let phone = phoneTextField.text ?? ""
            if Verification.isValidPhoneNumber(phone){
                phoneVerifyImageView.tintColor = UIColor.colorPrimary
                phoneVerified = true
            }else{
                phoneVerifyImageView.tintColor = UIColor.silver
                phoneVerified = false
            }
        case passwordTextField:
            let password = passwordTextField.text ?? ""
            if Verification.isValidPassword(password){
                passwordVerifyImageView.tintColor = UIColor.colorPrimary
                passwordVerified = true
            }else{
                passwordVerifyImageView.tintColor = UIColor.silver
                passwordVerified = false
            }
            

        case chefNameTextField:
            let name = chefNameTextField.text ?? ""
            if Verification.isValidName(name){
                chefNameVerifyImageView.tintColor = UIColor.colorPrimary
                chefNameVerified = true
            }else{
                chefNameVerifyImageView.tintColor = UIColor.silver
                chefNameVerified = false
            }
        case chefEmailTextField:
            chefEmailTextField.text = chefEmailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let email = chefEmailTextField.text ?? ""
            if Verification.isValidEmail(email){
                chefEmailVerifyImageView.tintColor = UIColor.colorPrimary
                chefEmailVerified = true
            }else{
                chefEmailVerifyImageView.tintColor = UIColor.silver
                chefEmailVerified = false
            }
        case chefPhoneTextField:
            let phone = chefPhoneTextField.text ?? ""
            if Verification.isValidPhoneNumber(phone){
                chefPhoneVerifyImageView.tintColor = UIColor.colorPrimary
                chefPhoneVerified = true
            }else{
                chefPhoneVerifyImageView.tintColor = UIColor.silver
                chefPhoneVerified = false
            }
        case chefPasswordTextField:
            let password = chefPasswordTextField.text ?? ""
            if Verification.isValidPassword(password){
                chefPasswordVerifyImageView.tintColor = UIColor.colorPrimary
                chefPasswordVerified = true
            }else{
                chefPasswordVerifyImageView.tintColor = UIColor.silver
                chefPasswordVerified = false
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
    
    //MARK: GIDSignInUIDelegate
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: GIDSignInDelegate
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            progressAlert = showProgressAlert()
            //let userId = user.userID
            //let idToken = user.authentication.idToken
            //let fullName = user.profile.name
            //let givenName = user.profile.givenName
            //let familyName = user.profile.familyName
            //let email = user.profile.email
            let accessToken = user.authentication.accessToken
            
            // download image forom google
            let imageUrl = user.profile.imageURL(withDimension: 400)
            ImageDownloader.default.downloadImage(with: imageUrl!, options: [], progressBlock: nil, completionHandler: { (image, error, url, data) in
                self.image64 = Utils.encodeImage(image!)
            })
            sendGoogleData(token: accessToken!)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    // MARK: - Action handlers    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func onCustomer(_ sender: Any) {
        self.btnCustomer.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        self.btnChef.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        
        self.btnCustomer.setTitleColor(UIColor.white, for: .normal)
        self.btnCustomer.backgroundColor = .colorPrimary
        self.btnChef.setTitleColor(UIColor.colorPrimary, for: .normal)
        self.btnChef.backgroundColor = .white
        
        self.isChef = false
        self.chefView.isHidden = true
        self.customerView.isHidden = false
        
        self.lbSocialSignUp.isHidden = false
        self.socialPanel.isHidden = false
        self.vDivider.isHidden = false
    }
    
    @IBAction func onChef(_ sender: Any) {
        
//        onChef(sender)
        self.btnCustomer.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.btnChef.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)

        self.btnChef.setTitleColor(UIColor.white, for: .normal)
        self.btnChef.backgroundColor = .colorPrimary

        self.btnCustomer.setTitleColor(UIColor.colorPrimary, for: .normal)
        self.btnCustomer.backgroundColor = .white

        self.isChef = true
        self.chefView.isHidden = false
        self.customerView.isHidden = true

        self.lbSocialSignUp.isHidden = true
        self.socialPanel.isHidden = true
        self.vDivider.isHidden = true
    }
    
    func onChefButtonPressed(_ sender: Any){
        
        self.btnCustomer.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.btnChef.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
       
        self.btnChef.setTitleColor(UIColor.white, for: .normal)
        self.btnChef.backgroundColor = .colorPrimary

        self.btnCustomer.setTitleColor(UIColor.colorPrimary, for: .normal)
        self.btnCustomer.backgroundColor = .white

        self.isChef = true
        self.chefView.isHidden = false
        self.customerView.isHidden = true
           
        self.lbSocialSignUp.isHidden = true
        self.socialPanel.isHidden = true
        self.vDivider.isHidden = true
    }
    
}
