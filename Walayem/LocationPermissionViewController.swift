//
//  LocationPermissionViewController.swift
//  Walayem
//
//  Created by MAC on 4/16/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import UIKit
import CoreLocation

class LocationPermissionViewController: UIViewController {

    // MARK: Properties
    
	let locationManager = CLLocationManager()
	
    @IBOutlet weak var acceptButton: UIButton!
    
    // MARK: Actions
    
    @IBAction func skip(_ sender: UIButton) {
        
    }
    
    @IBAction func acceptAndSignup(_ sender: UIButton) {
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestAlwaysAuthorization()
//		locationManager.requestLocation()
//		view.backgroundColor = .gray
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LocationPermissionViewController: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedWhenInUse || status == .authorizedAlways {
//			if #available(iOS 13.0, *) {
////				let sceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
//				sceneDelegate.setUpDashboard()
//			} else {
				let appDelegate = UIApplication.shared.delegate as! AppDelegate
				appDelegate.shouldMoveToMainPage()
//			}
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		DLog(message: error)
	}
	
}
