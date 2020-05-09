//
//  PickChefAreaMap.swift
//  Walayem
//
//  Created by Creative Empire on 4/29/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PickChefAreaMap: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var ChefMapView: MKMapView!
    //MARK:- Variable Declarations

        var locationManager:CLLocationManager!
        var currentLocationStr = "Current location"

        //MARK:- ViewController LifeCycle Methods

        override func viewDidLoad() {
            super.viewDidLoad()
        }

        override func viewDidAppear(_ animated: Bool) {
            determineCurrentLocation()
        }

        //MARK:- CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           let mUserLocation:CLLocation = locations[0] as CLLocation
           let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
           let mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
           ChefMapView.setRegion(mRegion, animated: true)

           // Get user's Current Location and Drop a pin
       let mkAnnotation: MKPointAnnotation = MKPointAnnotation()
           mkAnnotation.coordinate = CLLocationCoordinate2DMake(mUserLocation.coordinate.latitude, mUserLocation.coordinate.longitude)
           mkAnnotation.title = self.setUsersClosestLocation(mLattitude: mUserLocation.coordinate.latitude, mLongitude: mUserLocation.coordinate.longitude)
           ChefMapView.addAnnotation(mkAnnotation)
       }
//        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//            let mUserLocation:CLLocation = locations[0] as CLLocation
//
//            let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
//            let mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//
//           ChefMapView.setRegion(mRegion, animated: true)
//        }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Error - locationManager: \(error.localizedDescription)")
        }
    //MARK:- Intance Methods

    func determineCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }

}
    
 
    //MARK:- Intance Methods

    func setUsersClosestLocation(mLattitude: CLLocationDegrees, mLongitude: CLLocationDegrees) -> String {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: mLattitude, longitude: mLongitude)

        geoCoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in

            if let mPlacemark = placemarks{
                if let dict = mPlacemark[0].addressDictionary as? [String: Any]{
                    if let Name = dict["Name"] as? String{
                        if let City = dict["City"] as? String{
                            self.currentLocationStr = Name + ", " + City
                        }
                    }
                }
            }
        }
        return currentLocationStr
    }
    
}
