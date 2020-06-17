//
//  BaseTabViewController.swift
//  Walayem
//
//  Created by D4ttatraya on 10/05/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit
import CoreLocation

typealias Location = CLLocationCoordinate2D

class BaseTabViewController: UIViewController, DeliverySelectionDelegate, DeliveryLocationViewDelegate {

    @IBOutlet weak var locationView: DeliveryLocationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationView.locationUpdated()
    }
    
    func deliveryLocationSelected(_: Location?, title: String) {
        locationView.locationUpdated()
    }
    
    func locationButtonClicked() {
        let selectionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeliverySelectionVCId") as! DeliverySelectionViewController
        selectionVC.delegate = self
        selectionVC.modalPresentationStyle = .overFullScreen
		self.navigationController?.pushViewController(selectionVC, animated: true)
    }
}
