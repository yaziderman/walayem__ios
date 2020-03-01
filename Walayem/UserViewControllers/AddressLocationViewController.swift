//
//  AddressLocationViewController.swift
//  Walayem
//
//  Created by Ramzi Shadid on 2/23/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AddressLocationViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var userAnnotation = MKPointAnnotation()
    
    var progressAlert: UIAlertController?


    override func viewDidLoad() {
        super.viewDidLoad()

        Utils.setupNavigationBar(nav: self.navigationController!)

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways){
            locationManager.requestLocation()
        }

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.01
        self.mapView.addGestureRecognizer(longPressGesture)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {

        if gesture.state == .ended {
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            print(coordinate)
            self.mapView.removeAnnotation(userAnnotation)
            userAnnotation.coordinate = coordinate
            self.mapView.addAnnotation(userAnnotation)
        }
    }


    @IBAction func next(_ sender: UIButton){
        self.performSegue(withIdentifier: "AddressLocationSegue", sender: self)
    }
    @IBAction func back(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "AddressLocationSegue" {
               if let destinationVC = segue.destination as? AddressViewController {
                destinationVC.userCoordinate = userAnnotation.coordinate
               }
           }
       }
}



extension AddressLocationViewController: CLLocationManagerDelegate {
    
      func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
      {
        if(status == .authorizedWhenInUse || status == .authorizedAlways){
          manager.requestLocation()
        }

        print("location manager authorization status changed")
        
        switch status {
        case .authorizedAlways:
            print("user allow app to get location data when app is active or in background")
            locationManager.requestLocation()

        case .authorizedWhenInUse:
            print("user allow app to get location data only when app is active")
            locationManager.requestLocation()
        case .denied:
            let alert = UIAlertController(title: "Location", message: "Please allow your location from settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
            } ))
            present(alert, animated: true, completion: nil)

            
        case .restricted:
            print("parental control setting disallow location data")
        case .notDetermined:
            print("the location permission dialog haven't shown before, user haven't tap allow/disallow")
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
                 
         let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
         let region = MKCoordinateRegion(center: location.coordinate, span: span)
             mapView.setRegion(region, animated: true)
             
        userAnnotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                           longitude: location.coordinate.longitude)
         userAnnotation.title = "Your location"
         mapView.addAnnotation(userAnnotation)

        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           print(error)
    }

}

