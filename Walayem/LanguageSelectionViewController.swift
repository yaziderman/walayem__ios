//
//  ViewController.swift
//  Walayem
//
//  Created by Hafiza Seemab on 3/9/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

class LanguageSelectionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        mClose.layer.cornerRadius = 10
        mView.layer.cornerRadius = 8
        showAnimate()
    }
    
    @IBOutlet var mView: UIView!
    @IBOutlet var mClose: UIButton!
    let engContact = "+971585934540"
    
    
    
    @IBAction func en_btn_Tapped(_ sender: Any) {
    var phone = UserDefaults.standard.string(forKey: "ContactNumber")
           if(phone == nil)
           {
               phone = "+971 58 566 8800";
           }

        phone = phone!.replacingOccurrences( of:"[^0-9]", with: "", options: .regularExpression)

           if let phoneNumber = phone{
               if let url = URL(string: "tel://\(engContact)") {
                UIApplication.shared.open(url, options: [:], completionHandler: { (Success) in
                    print("Make call \(Success)")
                })
            }
           }
           
           removeAnimate()
    }
    
    
    @IBAction func ar_button_tapped(_ sender: Any) {
        var phone = UserDefaults.standard.string(forKey: "ContactNumber")
        if(phone == nil)
        {
            phone = "+971 58 566 8800";
        }

        phone = phone!.replacingOccurrences( of:"[^0-9]", with: "", options: .regularExpression)

        if let phoneNumber = phone{
            if let url = URL(string: "tel://\(phoneNumber)") {
             UIApplication.shared.open(url, options: [:], completionHandler: { (Success) in
                 print("Make call \(Success)")
             })
         }
        }
        
        removeAnimate()
    }
    
    
    
    
    
    @IBAction func closeView(_ sender: Any) {
        removeAnimate()
    }

    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.55, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }

    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
                self.willMove(toParentViewController: nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
        })
        dismiss(animated: true, completion: nil)
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
