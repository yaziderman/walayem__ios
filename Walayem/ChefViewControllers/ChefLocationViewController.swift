//
//  ChefLocationViewController.swift
//  Walayem
//
//  Created by Ramzi Shadid on 2/19/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ChefLocationViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var userAnnotation = MKPointAnnotation()

    override func viewDidLoad() {
        super.viewDidLoad()


        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways){
            locationManager.requestLocation()
        }

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longPressGesture)
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
        
    }


}

extension ChefLocationViewController: CLLocationManagerDelegate {
    
      func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
      {
        if(status == .authorizedWhenInUse || status == .authorizedAlways){
          manager.requestLocation()
        }

        print("location manager authorization status changed")
        
        switch status {
        case .authorizedAlways:
            print("user allow app to get location data when app is active or in background")
        case .authorizedWhenInUse:
            print("user allow app to get location data only when app is active")
        case .denied:
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
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


