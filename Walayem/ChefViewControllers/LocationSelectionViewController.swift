//
//  LocationSelectionViewController.swift
//  Walayem
//
//  Created by D4ttatraya on 30/05/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

protocol LocationSelectionDelegate: class {
    func locationSelected(_: Location, title: String, address: UserAddress)
}

fileprivate let MapZoomLevel: Float = 15

class LocationSelectionViewController: UIViewController, GMSMapViewDelegate {

    var isPush = false
    weak var delegate: LocationSelectionDelegate?
    
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var locationBottomView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        setupUI()
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setUpNavigationBar(setGreen: true)
	}
	
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.firstTimeAppeared {
            checkLocationPermission()
            setupMap()
        }
        self.firstTimeAppeared = false
    }
    
    @IBAction func doneBtnClicked(_ sender: Any) {
		validateLocation()
    }
    
    @IBAction func searchButtonClicked() {
        let autocompleteController = GMSAutocompleteViewController()
        if #available(iOS 13.0, *) {
            autocompleteController.tableCellBackgroundColor = .systemBackground
        }
        autocompleteController.delegate = self

        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue:
            UInt(GMSPlaceField.name.rawValue) |
                UInt(GMSPlaceField.placeID.rawValue) |
                UInt(GMSPlaceField.coordinate.rawValue))!
        autocompleteController.placeFields = fields

        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        filter.country = "AE"//"AE","IN"
        autocompleteController.autocompleteFilter = filter

        autocompleteController.modalPresentationStyle = .fullScreen
        present(autocompleteController, animated: false, completion: nil)
    }
    
    @IBAction func closeBtnClicked(_ sender: Any) {
        if self.isPush {
            self.navigationController?.popViewController(animated: false)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.locationLabel.text = "Fetching..."
        self.selectedLocation = nil
        self.selectedLocationTitle = nil
        self.selectedAddress = nil
    }
    
	func setUpNavigationBar(setGreen: Bool) {
		if setGreen {
			self.navigationController?.navigationBar.barTintColor = .colorPrimary
			self.navigationController?.navigationBar.isTranslucent = false
			self.navigationController?.navigationBar.tintColor = .white
		} else {
			self.navigationController?.navigationBar.barTintColor = .white
			self.navigationController?.navigationBar.isTranslucent = true
			self.navigationController?.navigationBar.tintColor = .colorPrimary
		}
	}
	
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        GMSGeocoder().reverseGeocodeCoordinate(position.target) { response, error in
            guard error == nil, let address = response?.firstResult() else {
                self.selectedLocation = position.target
                self.selectedLocationTitle = position.target.title
                self.locationLabel.text = "Location name not found"
                self.selectedAddress = UserAddress(street: "Not found", city: "Not found")
                return
            }
            self.selectedLocation = address.coordinate
            var title = address.subLocality
            if title.nilOrEmpty {
                title = address.locality
            }
            if title.nilOrEmpty {
                title = address.administrativeArea
            }
            if title.nilOrEmpty {
                title = address.lines?.joined(separator: ", ")
            }
            if title.nilOrEmpty {
                title = address.country
            }
            if title.nilOrEmpty {
                title = "Location name not found"
            }
            self.locationLabel.text = address.lines?.joined(separator: ", ") ?? title
            self.selectedLocationTitle = address.lines?.joined(separator: ", ") ?? title
            
            let adminArea = address.administrativeArea ?? ""
            let country = address.country ?? ""
            let city = [adminArea, country].joined(separator: ", ")
            self.selectedAddress = UserAddress(street: address.thoroughfare,
                                               city: city)
        }
    }
    
    //MARK: - Privates -
    private var selectedLocation: Location?
    private var selectedLocationTitle: String?
    private var selectedAddress: UserAddress?
    private var defaultLocation = Location(latitude: 24.468, longitude: 54.375)
    private var mapView: GMSMapView?
    private let locationManager = CLLocationManager()
    private var firstTimeAppeared = true
    
    private func setupUI() {
        self.locationBottomView.layer.shadowColor = UIColor.black.cgColor
        self.locationBottomView.layer.shadowOpacity = 0.5
        self.locationBottomView.layer.shadowOffset = .zero
        self.locationBottomView.layer.shadowRadius = 5
        
        
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = .white
        }
        
//        searchBar.isHidden = true
    }
    
    private func setupMap() {
        DispatchQueue.main.async {
            let camera = GMSCameraPosition(target: self.defaultLocation, zoom: MapZoomLevel)
            let frame = CGRect(x: 0, y: 0, width: self.mapContainerView.bounds.width, height: self.mapContainerView.bounds.height)
            self.mapView = GMSMapView.map(withFrame: frame, camera: camera)
            self.mapView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.mapView!.delegate = self
            self.mapView!.isMyLocationEnabled = true
            self.mapView!.settings.myLocationButton = true
            self.mapContainerView.addSubview(self.mapView!)
            self.mapContainerView.sendSubviewToBack(self.mapView!)
        }
    }
    
    private func checkLocationPermission() {
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
    
    private func callDelegateForLocationSelection() {
        guard let location = self.selectedLocation else {
            return
        }
        let title = self.selectedLocationTitle ?? ""
        let address = self.selectedAddress ?? UserAddress(street: "", city: "")
        self.delegate?.locationSelected(location, title: title, address: address)
    }
	
	func validateLocation(){
		guard let location = self.selectedLocation else {
			return
		}
		
		let params = ["lat": location.latitude, "long": location.longitude]
		
		RestClient().request(WalayemApi.areaCovered, params, self) { (result, error) in
			
			if let error = error{
				self.handleNetworkError(error)
				return
			}
			
			if error != nil{
				let errmsg = error?.userInfo[NSLocalizedDescriptionKey] as! String
				print (errmsg)
				return
			}
			let value = result!["result"] as! [String: Any]
			guard let status = value["status"] as? Bool else{
				return
			}
			
			if status {
				self.callDelegateForLocationSelection()
				self.closeBtnClicked(UIButton())
			} else {
				if let message = value["message"] as? String {
					self.showSorryAlertWithMessage(message)
				} else {
					self.showSorryAlertWithMessage("Something went wrong...")
				}
			}
		}
	}
	
	private func handleNetworkError(_ error: NSError){
		if error.userInfo[NSLocalizedDescriptionKey] != nil{
			let errmsg = error.userInfo[NSLocalizedDescriptionKey] as! String
			if error.domain == NSURLErrorDomain && error.code == URLError.notConnectedToInternet.rawValue{
				let alert = UIAlertController(title: "Cannot get Foods", message: errmsg, preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
				present(alert, animated: true, completion: nil)
			}else if errmsg == OdooClient.SESSION_EXPIRED{
				self.onSessionExpired()
			} else {
				showSorryAlertWithMessage("Some thing wrong in backend ...!")
			}
		}
		else{
			showSorryAlertWithMessage("Some thing wrong in backend ...!")
		}
	}
	
	private func showSorryAlertWithMessage(_ msg: String){
		let alert = UIAlertController(title: "Sorry", message: msg, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		setUpNavigationBar(setGreen: false)
	}
	
}

extension LocationSelectionViewController: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    dismiss(animated: false, completion: nil)
    DispatchQueue.main.async {
        let camera = GMSCameraPosition(target: place.coordinate, zoom: MapZoomLevel)
        self.mapView?.animate(to: camera)
    }
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: false, completion: nil)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }

}

extension LocationSelectionViewController: CLLocationManagerDelegate {
    
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
        self.defaultLocation = location.coordinate
        let camera = GMSCameraPosition(target: location.coordinate, zoom: MapZoomLevel)
        self.mapView?.animate(to: camera)
        locationManager.stopUpdatingLocation()
        
    }
    
}
