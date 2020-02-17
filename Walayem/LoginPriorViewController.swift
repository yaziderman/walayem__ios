//
//  LoginPriorViewController.swift
//  Walayem
//
//  Created by MAC on 4/16/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import os.log

class LoginPriorViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var userSwitch: UISwitch!
    // MARK: Actions
    
    @IBOutlet weak var btnSkip: UIButton!
    
    
//    @IBAction func skipAction(_ sender: UIButton){
//        StaticLinker.mainVC?.selectedIndex = 0
//    }
    
    
    @IBAction func signup(_ sender: UIButton) {
        performSegue(withIdentifier: "SignupVCSegue", sender: sender)

//        if userSwitch.isOn{
//            performSegue(withIdentifier: "ChefSignupVCSegue", sender: sender)
//        }else{
//            performSegue(withIdentifier: "SignupVCSegue", sender: sender)
//        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        signupButton.layer.cornerRadius = 12
        signupButton.layer.masksToBounds = false
        userSwitch.setOn(false, animated: false)
        // Do not show onboarding screen
        
        StaticLinker.loginVC = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(StaticLinker.showSkip)
        {
            self.btnSkip.isHidden = false
        }
        else
        {
            self.btnSkip.isHidden = true
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "LoginVCSegue":
            guard let destinationVC = segue.destination as? LoginViewController else {
                fatalError("Unexpected ViewController")
            }
            destinationVC.isChef = userSwitch.isOn
        default:
            os_log("Sign up segue", log: .default, type: .debug)
        }
    }
    @IBAction func onSkep(_ sender: Any) {        
        self.dismiss(animated: true) {
//            StaticLinker.mainVC?.selectedIndex = 0
            StaticLinker.mainVC?.selectedIndex = StaticLinker.previosSeletedTab
//            print("--------oooooooooooooooooo-------\(StaticLinker.previosSeletedTab)")
        }
    }
}
