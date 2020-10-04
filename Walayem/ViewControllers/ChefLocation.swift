//
//  ChefLocation.swift
//  Walayem
//
//  Created by deya on 10/3/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit

import GoogleMaps
import GooglePlaces
import WebKit

class ChefLocationViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    let locationManager = CLLocationManager()

    func checkLocationPermission() {
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .denied {
                let msg =
                """
                Please allow this app to access the current location to better serve you.
                To allow access, go to Setting and then to Privacy.
                """
                let alert = UIAlertController(title: "Location Access", message: msg, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let msg = "Turn on location services from settings."
            let alert = UIAlertController(title: "Location Services", message: msg, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        checkLocationPermission()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        // Do any additional setup after loading the view.
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


extension ChefLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
//        self.defaultLocation = location.coordinate
        //let camera = GMSCameraPosition(target: location.coordinate, zoom: MapZoomLevel)
        //self.mapView?.animate(to: camera)
        locationManager.stopUpdatingLocation()
        
    }
    
}

