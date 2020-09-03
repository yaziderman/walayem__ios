//
//  OrderDelayViewController.swift
//  Walayem
//
//  Created by Hafiza Seemab on 20/08/2020.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

class OrderDelayViewController: UIViewController , UITextFieldDelegate {

    // MARK: Properties
    
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var nameVerifyIcon: UIImageView!
    @IBOutlet weak var nameView: UIStackView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var orderDelayLabel: UILabel!
    
    @IBOutlet weak var day1Btn: UIButton!
    @IBOutlet weak var day2Btn: UIButton!
    @IBOutlet weak var hours12Btn: UIButton!
    @IBOutlet weak var customTimeBtn: UIButton!
    
    
    var user = User()
    var nameVerified = true
    var selectedDelayTime = 0
    var delayText = "Customers can order"
    
    // MARK: Actions
    
    @IBAction func updateTime(_ sender: UIBarButtonItem) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        print(selectedDelayTime)
        if(selectedDelayTime > 0){
            let values: [String: Any] = ["fixed_delay": "\(selectedDelayTime)"]
            let userId = UserDefaults.standard.integer(forKey: UserDefaultsKeys.PARTNER_ID)
            OdooClient.sharedInstance().write(model: "res.partner", ids: [userId], values: values) { (result, error) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error{
                    let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
                    let alert = UIAlertController(title: "Cannot save time", message: errmsg, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                UserDefaults.standard.set(self.selectedDelayTime, forKey: UserDefaultsKeys.FIXED_DELAY)
                self.user.fixedDelay = Int(self.selectedDelayTime)
                self.performSegue(withIdentifier: "unwindToChefProfileVC", sender: self)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        let uTime = UserDefaults.standard.integer(forKey: UserDefaultsKeys.FIXED_DELAY)
        
        // uTime is the USER'S Predefined DELAY TIME in Minutes.
        
        
        if user != nil{
            timeTextField.text = "\(uTime / 60)"
            nameVerifyIcon.tintColor = UIColor.colorPrimary
        }
        
        
        setButtonsView()
        timeTextField.delegate = self
        timeTextField.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        timeTextField.becomeFirstResponder()
//        Utils.setupNavigationBar(nav: self.navigationController!)
        
        timeTextField.textColor = UIColor.textColor
        timeTextField.placeHolderColor = UIColor.placeholderColor
        
        
        setDelayTextLabel(time: uTime / 60)
    }
    
    override func viewWillLayoutSubviews() {
        nameView.addBottomBorderWithColor(color: UIColor.silver, width: 1)
    }
    
    
    @IBAction func day1BtnTapped(_ sender: Any) {
        setBackgrounds(sender: day1Btn)
        orderDelayLabel.text = delayText + " 4 hours before."
        selectedDelayTime = 4*60
    }
    @IBAction func day2BtnTapped(_ sender: Any) {
        setBackgrounds(sender: day2Btn)
        orderDelayLabel.text = delayText + " 8 hours before."
        selectedDelayTime = 8*60
    }
    @IBAction func hours12BtnTapped(_ sender: Any) {
        setBackgrounds(sender: hours12Btn)
        orderDelayLabel.text =  delayText + " 12 hours before."
        selectedDelayTime = 12*60
    }
    @IBAction func customTimeBtnTapped(_ sender: Any) {
        setBackgrounds(sender: customTimeBtn)
        guard let time = Int(timeTextField.text ?? "") else { return }
        if(time > 0){
            setDelayTextLabel(time: time)
        }
        
        
        
    }
    
    func setDelayTextLabel(time: Int) {
        

        var days = 0
            days = time/24
        let hours = time%24
        

        
        
        
        if(days > 0 && days == 1){
            if(hours > 0){

                
                orderDelayLabel.text = delayText + " \(days) " + "day and" + " \(hours)" + " hours before."
            }else{
                orderDelayLabel.text = delayText + " \(days) " + "day before."
            }
        }
        else if(days > 1){
        
            if(hours > 0){
                
                orderDelayLabel.text = delayText + " \(days) " + "days and" + " \(hours)" + " hours before."
            }else{
                orderDelayLabel.text = delayText + " \(days) " + "days before."
            }
        }else{
            orderDelayLabel.text = delayText +  " \(time) " + "hours before."
        }
        
        selectedDelayTime = time*60
        
        if !(time > 0){
            
            orderDelayLabel.text = delayText + " directly."
//            timeTextField.text = ""
//
//        }else{
//            if(time == 1){
//                timeTextField.text = "\(time)" + " hour"
//            }else if (time > 1){
//                timeTextField.text = "\(time)" + " hours"
//            }
        }
        
    }
    
    
    func setBackgrounds(sender: UIButton){
        
        switch sender {
            case day1Btn:
                day1Btn.backgroundColor = #colorLiteral(red: 0.3695109785, green: 0.9020742774, blue: 0.7998521924, alpha: 1)
                day2Btn.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                hours12Btn.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                customTimeBtn.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                nameView.isHidden = true
                doneButton.isEnabled = true
                self.timeTextField.resignFirstResponder()
            case day2Btn:
            day1Btn.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                day2Btn.backgroundColor = #colorLiteral(red: 0.3695109785, green: 0.9020742774, blue: 0.7998521924, alpha: 1)
                hours12Btn.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                customTimeBtn.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                nameView.isHidden = true
                doneButton.isEnabled = true
                self.timeTextField.resignFirstResponder()
            case hours12Btn:
                day1Btn.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                day2Btn.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                hours12Btn.backgroundColor = #colorLiteral(red: 0.3695109785, green: 0.9020742774, blue: 0.7998521924, alpha: 1)
                customTimeBtn.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                nameView.isHidden = true
                doneButton.isEnabled = true
                self.timeTextField.resignFirstResponder()
            case customTimeBtn:
                day1Btn.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                day2Btn.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                hours12Btn.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                customTimeBtn.backgroundColor = #colorLiteral(red: 0.3695109785, green: 0.9020742774, blue: 0.7998521924, alpha: 1)
                nameView.isHidden = false
                self.timeTextField.becomeFirstResponder()
        default:
            return
        }
    }
    
    func setButtonsView() {
        day1Btn.layer.cornerRadius = 12
        day2Btn.layer.cornerRadius = 12
        hours12Btn.layer.cornerRadius = 12
        customTimeBtn.layer.cornerRadius = 12
    }

    // MARK: Private methods
    
    private func setupViews(){
        timeTextField.addImageAtLeft(UIImage(named: "user"))
        let userImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 + 10 , height: 20))
        userImageView.image = UIImage(named: "timer")
        userImageView.contentMode = .left
        userImageView.tintColor = UIColor.colorPrimary
        
        timeTextField.frame.size.width = 100
        timeTextField.leftViewMode = .always
        timeTextField.leftView = userImageView
        timeTextField.tintColor = UIColor.silver
    }
    
    @objc private func textFieldDidChange(sender: UITextField){
        let time = timeTextField.text ?? ""
        if Verification.isValidDelayTime(time){
            nameVerifyIcon.tintColor = UIColor.colorPrimary
            nameVerified = true
        }else{
            nameVerifyIcon.tintColor = UIColor.silver
            nameVerified = false
        }
        updateDoneButtonState()
        setDelayTextLabel(time: Int(time) ?? 0)
    }
    
    private func updateDoneButtonState(){
        doneButton.isEnabled = nameVerified
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

}
