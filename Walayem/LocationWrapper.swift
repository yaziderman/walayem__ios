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
	
	@discardableResult
	required convenience init(locationDelegate: LocationDelegate) {
		self.init()
		self.locationDelegate = locationDelegate
		locationManager = CLLocationManager()
		locationManager?.delegate = self
		checkLocationAvailability()
	}
	
	func checkLocationAvailability () {
		if CLLocationManager.locationServicesEnabled() {
			switch CLLocationManager.authorizationStatus() {
				case .notDetermined, .restricted, .denied:
					locationManager?.requestAlwaysAuthorization()
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
		if status == .authorizedWhenInUse || status == .authorizedAlways {
			locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
			locationManager?.startUpdatingLocation()
		}
	}
	
}
