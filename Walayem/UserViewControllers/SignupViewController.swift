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

class SignupViewController: UIViewController, UITextFieldDelegate, GIDSignInDelegate {

    // MARK: Properties
    
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
    
    var emailVerified: Bool = false
    var nameVerified: Bool = false
    var phoneVerified: Bool = false
    var passwordVerified: Bool = false
    var image64: String?
    
    var progressAlert: UIAlertController?
    
    // MARK: Actions
    
    @IBAction func back(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    private func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signup(_ sender: UIButton) {
        if(!emailVerified)
        {
            self.showMessagePrompt("Invalid email.")
            return;
        }
        else if(!nameVerified)
        {
            self.showMessagePrompt("Invalid name.")
            return;
        }
        else if(!phoneVerified)
        {
            self.showMessagePrompt("Phone number should be valid and start with 971.")
            return;
        }
        else if(!passwordVerified)
        {
            self.showMessagePrompt("Password must be at least 4 characters.")
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
                                      "is_chef": false]
        
        progressAlert = showProgressAlert()
        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil, completion: { (verificationID, error) in
            if let error = error {
                self.progressAlert?.dismiss(animated: false, completion: {
                    self.showMessagePrompt(error.localizedDescription)
                })
                return
            }
            UserDefaults.standard.set(verificationID, forKey: UserDefaultsKeys.FIREBASE_VERIFICATION_ID)
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
                let data = record["data"] as! [String: Any]
                let sessionId: String = data["session_id"] as! String
                UserDefaults.standard.set(sessionId, forKey: UserDefaultsKeys.SESSION_ID)
                self.loadUserDetails()
            }
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
                        _ = responseDict["email"] as! String
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
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        signupButton.layer.cornerRadius = 12
        signupButton.layer.masksToBounds = false
        addImageInsideTextField()
        
        passwordTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        phoneTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        nameVerifyImageView.tintColor = UIColor.silver
        emailVerifyImageView.tintColor = UIColor.silver
        phoneVerifyImageView.tintColor = UIColor.silver
        passwordVerifyImageView.tintColor = UIColor.silver

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
            
            let records = result!["records"] as! [Any]
            if let record = records[0] as? [String : Any]{
                let partnerId = record["id"] as! Int
                let isImageSet = record["is_image_set"] as! Bool
                let user = User(record: record)
                self.saveUserInDevice(user: user, partnerId: partnerId)
                self.uploadImage(partnerId: partnerId, isImageSet: isImageSet)
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
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[indicator]-(-50)-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[indicator]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: views)
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
