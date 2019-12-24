//
//  ChangeNameViewController.swift
//  Walayem
//
//  Created by Inception on 6/1/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class ChangeNameViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameVerifyIcon: UIImageView!
    @IBOutlet weak var nameView: UIStackView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var user: User?
    var nameVerified = true
    
    // MARK: Actions
    
    @IBAction func updateName(_ sender: UIBarButtonItem) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let name = nameTextField.text ?? ""
        let values: [String: Any] = ["name": name]
        OdooClient.sharedInstance().write(model: "res.partner", ids: [user!.partner_id!], values: values) { (result, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let error = error{
                let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
                let alert = UIAlertController(title: "Cannot save name", message: errmsg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            UserDefaults.standard.set(name, forKey: UserDefaultsKeys.NAME)
            self.user?.name = name
            
            self.performSegue(withIdentifier: "UpdateProfileUnwindSegue", sender: self)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        if let user = user{
            nameTextField.text = user.name
            nameVerifyIcon.tintColor = UIColor.colorPrimary
        }
        
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        nameTextField.becomeFirstResponder()
        Utils.setupNavigationBar(nav: self.navigationController!)
        
        nameTextField.textColor = UIColor.textColor
        nameTextField.placeHolderColor = UIColor.placeholderColor
    }
    
    override func viewWillLayoutSubviews() {
        nameView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
    }

    // MARK: Private methods
    
    private func setupViews(){
        let userImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 10, height: 20))
        userImageView.image = UIImage(named: "user")
        userImageView.contentMode = .left
        userImageView.tintColor = UIColor.colorPrimary
        nameTextField.leftViewMode = .always
        nameTextField.leftView = userImageView
        nameVerifyIcon.tintColor = UIColor.silver
    }
    
    @objc private func textFieldDidChange(sender: UITextField){
        let name = nameTextField.text ?? ""
        if Verification.isValidName(name){
            nameVerifyIcon.tintColor = UIColor.colorPrimary
            nameVerified = true
        }else{
            nameVerifyIcon.tintColor = UIColor.silver
            nameVerified = false
        }
        updateDoneButtonState()
    }
    
    private func updateDoneButtonState(){
        doneButton.isEnabled = nameVerified
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
