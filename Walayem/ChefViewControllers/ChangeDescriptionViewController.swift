//
//  ChangeDescriptionViewController.swift
//  Walayem
//
//  Created by maple on 23/06/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

protocol DescriptionChangedProtocol: class {
	func onDescriptionChanged(description: String)
}

class ChangeDescriptionViewController: UIViewController {
	
	var descriptionText = ""
	@IBOutlet weak var descriptionTextView: UITextView!
	@IBOutlet weak var saveDescriptionButton: UIButton!
	
	weak var descriptionChangedProtocol: DescriptionChangedProtocol?
	
    override func viewDidLoad() {
        super.viewDidLoad()

		descriptionTextView.text = descriptionText
        // Do any additional setup after loading the view.
    }
    
	@IBAction func saveBtnAction(_ sender: Any) {
		descriptionChangedProtocol?.onDescriptionChanged(description: descriptionTextView.text)
		navigationController?.popViewController(animated: true)
	}

}
