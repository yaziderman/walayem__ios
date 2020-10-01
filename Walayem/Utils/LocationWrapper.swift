//
//  LocationWrapper.swift
//  Walayem
//
//  Created by maple on 10/06/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import Foundation
import GooglePlaces
import GoogleMaps

protocol LocationDelegate: class {
	func getLocation(location: Location, address: UserAddress, title: String)
	func locationPermissionDenied()
}

class LocationWrapper: NSObject, CLLocationManagerDelegate {
	
	var locationManager: CLLocationManager?
	weak var locationDelegate: LocationDelegate?
	weak var viewController: UIViewController?
	
	@discardableResult
	required convenience init(locationDelegate: LocationDelegate, vc: UIViewController) {
		self.init()
		self.locationDelegate = locationDelegate
		self.viewController = vc
		locationManager = CLLocationManager()
		locationManager?.delegate = self
		checkLocationAvailability()
	}
	
	func checkLocationAvailability () {
		if CLLocationManager.locationServicesEnabled() {
			switch CLLocationManager.authorizationStatus() {
				case .restricted, .denied:
					showSettingsPopup()
					locationDelegate?.locationPermissionDenied()
				case .notDetermined :
					locationManager?.requestWhenInUseAuthorization()
					locationDelegate?.locationPermissionDenied()
				case .authorizedAlways, .authorizedWhenInUse:
					locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
					locationManager?.startUpdatingLocation()
				@unknown default:
					break
			}
		} else {
			print("Location services are not enabled")
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = manager.location else { return }
		locationManager?.stopUpdatingLocation()
		print("locations = \(location.coordinate.latitude) \(location.coordinate.longitude)")
		
		GMSGeocoder().reverseGeocodeCoordinate(location.coordinate) { [weak self] response, error in
			guard error == nil, let address = response?.firstResult() else {
				self?.locationDelegate?.getLocation(location: Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), address: UserAddress(street: "", city: ""), title: "")
				return
			}
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
			
			let adminArea = address.administrativeArea ?? ""
			let country = address.country ?? ""
			let city = [adminArea, country].joined(separator: ", ")
			let selectedAddress = UserAddress(street: address.locality,
											   city: city)
			self?.locationDelegate?.getLocation(location: Location(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), address: selectedAddress, title: address.lines?.joined(separator: ", ") ?? (title ?? ""))
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		DLog(message: error)
		locationDelegate?.locationPermissionDenied()
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedWhenInUse || status == .authorizedAlways || status == .notDetermined{
			locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
			locationManager?.startUpdatingLocation()
		} else {
			showSettingsPopup()
		}
	}
	
	func showSettingsPopup() {
		StaticLinker.shouldGetLocation = true
		let alert = UIAlertController.init(title: "Permission Required", message: "Please turn on location to proceed.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
			if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!) {
				UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
			}
		}))
		viewController?.present(alert, animated: true, completion: nil)
	}
	
}
