//
//  LocationPermissionViewController.swift
//  Walayem
//
//  Created by MAC on 4/16/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit

class LocationPermissionViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var acceptButton: UIButton!
    
    // MARK: Actions
    
    @IBAction func skip(_ sender: UIButton) {
        
    }
    
    @IBAction func acceptAndSignup(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        acceptButton.layer.cornerRadius = 12
        acceptButton.layer.masksToBounds = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
