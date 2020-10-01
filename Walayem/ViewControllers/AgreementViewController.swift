//
//  AggrementViewController.swift
//  Walayem
//
//  Created by maple on 11/09/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

class AgreementViewController: UIViewController {

	@IBOutlet weak var agreementTextView: UITextView!
	@IBOutlet weak var btnAgree: UIButton!
	@IBOutlet weak var btnContinue: UIButton!
	
	var agreementText = NSAttributedString(string: "")
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		if #available(iOS 12.0, *) {
			if self.traitCollection.userInterfaceStyle == .dark {
				let mutableString = NSMutableAttributedString(attributedString: agreementText)
				let attrs = [NSAttributedString.Key.foregroundColor : UIColor.white]
				
				mutableString.addAttributes(attrs, range: NSRange(location: 0, length: mutableString.length))
				agreementText = mutableString
			}
		}
		
		agreementTextView.attributedText = agreementText
        // Do any additional setup after loading the view.
    }

	@IBAction func agreeBtnAction(_ sender: Any) {
		btnContinue.isHidden = false
		btnAgree.isHidden = true
	}
	
	@IBAction func continueBtnAction(_ sender: Any) {
		Utils.setUserDefaults(value: true, key: UserDefaultsKeys.IS_AGGREEMENT_ACCEPTED)
		self.dismiss(animated: true, completion: nil)
	}
	

}
