//
//  LoginViewController.swift
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
import GoogleSignIn
import FirebaseMessaging
import FBSDKCoreKit

class LoginViewController: UIViewController, UITextFieldDelegate, GIDSignInDelegate {

    // MARK: Properties
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var emailVerifyImageView: UIImageView!
    @IBOutlet weak var passwordVerifyImageView: UIImageView!
    @IBOutlet weak var socialLoginView: UIStackView!
    @IBOutlet weak var socialLoginLabel: UILabel!
    
    @IBOutlet weak var showPass: UIButton!
    
    var emailVerified: Bool = false
    var passwordVerified: Bool = false
    var progressAlert: UIAlertController?
    var image64: String?
    var isChef = false
    
    @IBAction func showPassPressed(_ sender: Any) {
        if showPass.isEnabled{
            passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
            if (!passwordTextField.isSecureTextEntry){
                showPass.setImage(UIImage(named: "open_eye.png"), for: .normal)
                showPass.setImage(#imageLiteral(resourceName: "close_eye"), for: .normal)
            }else{
                showPass.setImage(#imageLiteral(resourceName: "open_eye"), for: .normal)
    //            #imageLiteral(resourceName: "close_eye")
            }
        }
        
    }
    
    // MARK: Actions
    
    @IBAction func back(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func login(_ sender: UIButton) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        progressAlert = showProgressAlert()
        OdooClient().authenticate(email: email, password: password, database: WalayemApi.DB_NAME) { (result, error) in
            if error != nil{
                self.progressAlert?.dismiss(animated: true, completion: {
                    self.showMessagePrompt("Passwords do not match")
                })
                return
            }
            
            let sessionId = result!["session_id"] as! String
            UserDefaults.standard.set(sessionId, forKey: UserDefaultsKeys.SESSION_ID)
            self.loadUserDetails()
        }
    }
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        
    }
    
    @IBAction func loginViaFacebook(_ sender: UIButton) {
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
                        let responseDict = res as! [String:Any]
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
    
    @IBAction func loginViaGoogle(_ sender: UIButton) {
        
        do {
            try  print ("I am in try block")//igniteRockets(fuel: 5000, astronauts: 1)
            
        } catch {
            print(error)
        }
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        
        setViews()
        passwordTextField.delegate = self
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        updateLoginButtonState()
        self.hideKeyboardWhenTappedAround()
        
        emailTextField.textColor = UIColor.textColor
        emailTextField.placeHolderColor = UIColor.placeholderColor
        
        passwordTextField.textColor = UIColor.textColor
        passwordTextField.placeHolderColor = UIColor.placeholderColor
        
        showPass.isEnabled = false
    }
    
    override func viewWillLayoutSubviews() {
        emailView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
        passwordView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
    }

    // MARK: Private methods
    
    private func setViews(){
        loginButton.layer.cornerRadius = 12
        loginButton.layer.masksToBounds = false
        
        let emailImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 10, height: 20))
        emailImageView.image = UIImage(named: "email")
        emailImageView.contentMode = UIViewContentMode.left
        emailTextField.leftViewMode = .always
        emailTextField.leftView = emailImageView
        
        let lockImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 10, height: 20))
        lockImageView.image = UIImage(named: "lock")
        lockImageView.contentMode = UIViewContentMode.left
        passwordTextField.leftViewMode = .always
        passwordTextField.leftView = lockImageView
        
        if isChef{
            socialLoginView.isHidden = true
            socialLoginLabel.isHidden = true
        }
    }
    
    private func updateLoginButtonState(){
        if emailVerified && passwordVerified{
            loginButton.isEnabled = true
            loginButton.alpha = 1
        }else{
            loginButton.isEnabled = false
            loginButton.alpha = 0.3
        }
    }
    
    private func sendFbData(token: String){
 let url = "\(WalayemApi.BASE_URL)/auth_oauth/apisignin?state=%7B%22p%22%3A+2%2C+%22d%22%3A+%22\(WalayemApi.DB_NAME)%22%2C+%22r%22%3A+%22http%253A%252F%252F\(WalayemApi.BASE_URL.replacingOccurrences(of: "http://", with: ""))%252Fweb%22%7D&access_token=\(token)&expires_in=5486"
        
        Alamofire.request(url, method: .get).validate().responseJSON { (response) in
            if response.result.isSuccess{
                let value = response.result.value as! [String : Any]
                if let sessionId = value["result"] as? String
                {
                UserDefaults.standard.set(sessionId, forKey: "sessionId")
                UserDefaults.standard.set(token, forKey: "authToken")
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
            print (response)
            if response.result.isSuccess{
                let value = response.result.value as! [String : Any]
                if let sessionId = value["result"] as? String
                {
                UserDefaults.standard.set(sessionId, forKey: "sessionId")
                UserDefaults.standard.set(token, forKey: "authToken")
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
        let fields = ["id", "name", "email", "phone", "is_chef", "is_chef_verified", "is_image_set"]
        
        OdooClient.sharedInstance().searchRead(model: "res.partner", domain: [], fields: fields, offset: 0, limit: 1, order: "name ASC") { (result, error) in
            if error != nil{
                let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                print (errmsg)
                self.progressAlert?.dismiss(animated: true, completion: {
                    self.showMessagePrompt("Passwords donot match")
                })
                return
            }
            
            let records = result!["records"] as! [Any]
            if let record = records[0] as? [String : Any]{
                let partnerId = record["id"] as! Int
                let isImageSet = record["is_image_set"] as! Bool
                let user = User(record: record)
                self.subscribeToFirebaseTopics(partnerId)
                self.saveUserInDevice(user: user, partnerId: partnerId)
                self.uploadImage(partnerId: partnerId, isChef: user.isChef, isImageSet: isImageSet)
            }
        }
    }
    
    private func uploadImage(partnerId: Int, isChef: Bool, isImageSet: Bool){
        if let image = image64, !isImageSet{
            let values : [String : Any] = ["image": image, "is_image_set": true]
            OdooClient.sharedInstance().write(model: "res.partner", ids: [partnerId], values: values) { (result, error) in
                self.progressAlert?.dismiss(animated: false, completion: {
                    if self.isChef || isChef{
                        self.performSegue(withIdentifier: "ChefMainSegue", sender: self)
                    }else{
                        Utils.notifyRefresh()
                        self.dismiss(animated: true) {
                            StaticLinker.loginVC?.dismiss(animated: false, completion: {
                                StaticLinker.loginNav?.dismiss(animated: false, completion: nil)
                            })
                        }
                    }
                })
            }
        }else{
            self.progressAlert?.dismiss(animated: false, completion: {
                if self.isChef || isChef{
                    self.performSegue(withIdentifier: "ChefMainSegue", sender: self)
                }else{
                    Utils.notifyRefresh()
                    self.dismiss(animated: true) {
                        StaticLinker.loginVC?.dismiss(animated: false, completion: {
                            StaticLinker.loginNav?.dismiss(animated: false, completion: nil)
                        })
                    }
                }
            })
        }
    }
    
    private func saveUserInDevice(user: User, partnerId: Int){
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(user.name, forKey: UserDefaultsKeys.NAME)
        userDefaults.set(user.email, forKey: UserDefaultsKeys.EMAIL)
        userDefaults.set(user.phone, forKey: UserDefaultsKeys.PHONE)
        userDefaults.set(user.isChef, forKey: UserDefaultsKeys.IS_CHEF)
        userDefaults.set(partnerId, forKey: UserDefaultsKeys.PARTNER_ID)
        //userDefaults.set(sessionId, forKey: UserDefaultsKeys.SESSION_ID)
    }
    
    private func subscribeToFirebaseTopics(_ partnerId: Int){
        Messaging.messaging().subscribe(toTopic: "alli")
        Messaging.messaging().subscribe(toTopic: "\(partnerId)i")
        if isChef{
            Messaging.messaging().subscribe(toTopic: "allchefi")
        }else{
            Messaging.messaging().subscribe(toTopic: "alluseri")
        }
    }
    
    private func showMessagePrompt(_ message: String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: false, completion: nil)
    }
    
    private func showProgressAlert() -> UIAlertController{
        let alert = UIAlertController(title: "Signing in", message: "Please wait...", preferredStyle: .alert)
        
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(indicator)
        
        let views = ["pending" : alert.view, "indicator" : indicator]
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[indicator]-(-50)-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[indicator]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: views)
        alert.view.addConstraints(constraints)
        
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        
        present(alert, animated: true, completion: nil)
        
        return alert
    }
    
    // MARK: UITextFieldDelegate
    
    @objc private func textFieldDidChange(_ sender: UITextField){
        switch sender{
        case emailTextField:
            let email = emailTextField.text ?? ""
            if Verification.isValidEmail(email){
                emailVerifyImageView.tintColor = UIColor.colorPrimary
                emailVerified = true
            }else{
                emailVerifyImageView.tintColor = UIColor.silver
                emailVerified = false
            }
        case passwordTextField:
            let password = passwordTextField.text ?? ""
            if Verification.isValidLoginPassword(password){
                passwordVerifyImageView.tintColor = UIColor.colorPrimary
                showPass.setImage(#imageLiteral(resourceName: "open_eye"), for: .normal)
                showPass.isEnabled = true
                passwordVerified = true
            }else{
                
                showPass.isEnabled = false
                passwordVerifyImageView.tintColor = UIColor.silver
                showPass.setImage(UIImage(named: "close_eye_grey.png"), for: .normal)
                passwordVerified = false
            }
        default:
            print("TextField doenn't exist")
        }
        updateLoginButtonState()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: GIDSignInUIDelegate
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        print("Error")
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: GIDSignInDelegate
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        do{
        
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
            
//        }
//        catch e{
//            print("\(error.localizedDescription)")
//        }
        
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
