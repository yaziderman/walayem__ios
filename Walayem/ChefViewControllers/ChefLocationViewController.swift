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
import FirebaseMessaging
import FirebaseAuth

class ChefLocationViewController: UIViewController {
    var params: [String : Any] = [:]

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var userAnnotation = MKPointAnnotation()
    
    var progressAlert: UIAlertController?


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
        progressAlert = showProgressAlert()
        
        let locationParams: [String : Any] = ["lat":userAnnotation.coordinate.latitude,"lon":userAnnotation.coordinate.longitude]

        let phone = params["phone"] as? String ?? ""
        params["location"] = locationParams
        params.removeValue(forKey: "phone")
        
        RestClient().request(WalayemApi.signup, params) { (result, error) in
            if error != nil{
                self.progressAlert?.dismiss(animated: false, completion: {
                    let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                    self.showMessagePrompt(errmsg)
                })
                return
            }
            let record = result!["result"] as! [String: Any]
            if let errmsg = record["error"] as? String{
                self.progressAlert?.dismiss(animated: false, completion: {
                    self.showMessagePrompt(errmsg)
                })
                return
            }
            else{

                PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil, completion: { (verificationID, error) in
                    if let error = error {
                        self.progressAlert?.dismiss(animated: false, completion: {
                            self.showMessagePrompt(error.localizedDescription)
                        })
                        return
                    }
                    UserDefaults.standard.set(verificationID, forKey: UserDefaultsKeys.FIREBASE_VERIFICATION_ID)

                })

            }

            let data = record["data"] as! [String: Any]
            let sessionId: String = data["session_id"] as! String
            UserDefaults.standard.set(sessionId, forKey: UserDefaultsKeys.SESSION_ID)
            self.loadUserDetails()
        }

    }
    @IBAction func back(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }


    private func showMessagePrompt(_ message: String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: false, completion: nil)
    }
    
    private func showProgressAlert() -> UIAlertController{
        let alert = UIAlertController(title: "Signing up", message: "Please wait...", preferredStyle: .alert)
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        alert.view.addSubview(indicator)
        
        let views = ["pending" : alert.view, "indicator" : indicator]
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[indicator]-(-50)-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views as [String : Any])
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[indicator]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: views as [String : Any])
        alert.view.addConstraints(constraints)
        
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        
        present(alert, animated: false, completion: nil)
        
        return alert
    }
    
    private func loadUserDetails(){
        let fields = ["id", "name", "is_chef", "is_chef_verified", "kitchen_id", "email", "is_image_set"]
        
        OdooClient.sharedInstance().searchRead(model: "res.partner", domain: [], fields: fields, offset: 0, limit: 1, order: "name ASC") { (result, error) in
            if error != nil{
                self.progressAlert?.dismiss(animated: false, completion: {
                    let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
                    print (errmsg)
                })
                return
            }
            
            let records = result!["records"] as! [Any]
         
                if let record = records[0] as? [String : Any]{
                    let partnerId = record["id"] as! Int
                    let user = User(record: record)
                    self.subscribeToFirebaseTopics(partnerId)
                    self.saveUserInDevice(user: user, partnerId: partnerId)
                }
            

        }
    }

    private func subscribeToFirebaseTopics(_ partnerId: Int){
        Messaging.messaging().subscribe(toTopic: "alli")
        Messaging.messaging().subscribe(toTopic: "\(partnerId)i")
        Messaging.messaging().subscribe(toTopic: "alluseri")
    }
    
      private func saveUserInDevice(user: User, partnerId: Int){
          let userDefaults = UserDefaults.standard
          
          userDefaults.set(user.name, forKey: UserDefaultsKeys.NAME)
          userDefaults.set(user.email, forKey: UserDefaultsKeys.EMAIL)
          userDefaults.set(user.isChef, forKey: UserDefaultsKeys.IS_CHEF)
          userDefaults.set(partnerId, forKey: UserDefaultsKeys.PARTNER_ID)
    
          userDefaults.synchronize()
          
          
              self.progressAlert?.dismiss(animated: false, completion: {
                  self.performSegue(withIdentifier: "VerifyPhoneSegue", sender: self)
              })
          
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


