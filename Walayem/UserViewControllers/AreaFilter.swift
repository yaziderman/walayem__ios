//
//  AreaFilter.swift
//  Walayem
//
//  Created by D4ttatraya on 16/05/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import Foundation

struct UserAddress {
    var street: String?
    var city: String?
}

protocol ChefCoverageAreaDelegate: class {
    func didSelectMultipleAreas(selectedAreas: [Int], selectedEmirates: [Int], title: String)
}

final class AreaFilter {
    
    static var shared: AreaFilter!
    
    static func setSharedFilter() {
        if AreaFilter.shared == nil {
            shared = AreaFilter()
        }
    }
    private (set) var selectedLocation: Location?
    var selectedCoverageTitle: String?
	var userAddress: UserAddress?
	var addressId: Int = 0
    var selectedArea = 0
    var isAddress = false
    
    private init() {
        self.getSavedFilter()
    }
    private func getSavedFilter() {
        addressId = UserDefaults.standard.value(forKey: UserDefaultsKeys.USER_ADDRESS_ID) as? Int ?? 0
        selectedArea = UserDefaults.standard.value(forKey: UserDefaultsKeys.USER_AREA_ID) as? Int ?? 0
        self.selectedCoverageTitle = UserDefaults.standard.string(forKey: UserDefaultsKeys.USER_AREA_TITLE) ?? ""
        
        isAddress = (addressId != 0 && selectedArea == 0)
        
        guard let dict = UserDefaults.standard.dictionary(forKey: UserDefaultsKeys.USER_AREA_FILTER),
            let location = Location(dict: dict) else {
            return
        }
        self.selectedLocation = location
        
    }
    
    var coverageParams: [String: Any] {
        guard let location = self.selectedLocation else {
            return [:]
        }
        return ["location": location.dict]
    }
    
    var areaParams: [String: Any] {
        return ["area_id": self.selectedArea]
    }
    
    var addressParams: [String: Any] {
        return ["address_id": self.addressId]
    }
    
	func setselectedLocation(_ location: Location?, title: String, addressId: Int = 0) {
        self.selectedLocation = location
        self.selectedCoverageTitle = title
		self.addressId = addressId
		UserDefaults.standard.set(location?.dict, forKey: UserDefaultsKeys.USER_AREA_FILTER)
        UserDefaults.standard.set(title, forKey: UserDefaultsKeys.USER_AREA_TITLE)
    }
    
	func setselectedLocation(_ location: Location, title: String, userAddress: UserAddress, addressId: Int = 0) {
		self.selectedLocation = location
		self.selectedCoverageTitle = title
		self.userAddress = userAddress
		self.addressId = addressId
		UserDefaults.standard.set(location.dict, forKey: UserDefaultsKeys.USER_AREA_FILTER)
		UserDefaults.standard.set(title, forKey: UserDefaultsKeys.USER_AREA_TITLE)
	}
    
    func setSelectedArea(selectedArea: Int, title: String) {
        isAddress = false
        self.addressId = 0
        self.selectedArea = selectedArea
        self.selectedCoverageTitle = title
        UserDefaults.standard.set(title, forKey: UserDefaultsKeys.USER_AREA_TITLE)
        UserDefaults.standard.set(addressId, forKey: UserDefaultsKeys.USER_ADDRESS_ID)
        UserDefaults.standard.set(selectedArea, forKey: UserDefaultsKeys.USER_AREA_ID)
    }
    
    func setSelectedAddress(addressId: Int, title: String) {
        isAddress = true
        self.selectedArea = 0
        self.addressId = addressId
        self.selectedCoverageTitle = title
        UserDefaults.standard.set(title, forKey: UserDefaultsKeys.USER_AREA_TITLE)
        UserDefaults.standard.set(addressId, forKey: UserDefaultsKeys.USER_ADDRESS_ID)
        UserDefaults.standard.set(selectedArea, forKey: UserDefaultsKeys.USER_AREA_ID)
    }
	
	
    func resetAreaFilter() {
        self.selectedLocation = nil
		self.userAddress = nil
        if self.selectedArea == 0 {
            self.addressId = 0
            self.selectedArea = 0
            self.selectedCoverageTitle = nil
        }
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.USER_AREA_FILTER)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.USER_AREA_TITLE)
    }
    
}

struct ChefAreaCoverage: Codable {
    var areaIds: [Int]
    var areaTitles: [String]
    
    init(areaIds: [Int], areaTitles: [String]) {
        self.areaIds = areaIds
        self.areaTitles = areaTitles
    }
    
    init?(dictArray: [[String: Any]]) {
        guard dictArray.count > 0 else { return nil }
        var ids: [Int] = []
        var titles: [String] = []
        for coverage in dictArray {
            guard let areas = coverage["areas"] as? [[String: Any]] else { continue }
            for area in areas {
                if let id = area["id"] as? Int {
                    ids.append(id)
                }
                if let title = area["name"] as? String {
                    titles.append(title)
                }
            }
        }
        guard ids.count > 0, titles.count > 0 else { return nil}
        
        self.areaIds = ids
        self.areaTitles = titles
    }
    
    func saveToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.CHEF_COVERAGE_AREA)
        }
    }
    
    static func loadFromUserDefaults() -> ChefAreaCoverage? {
        if let savedData = UserDefaults.standard.object(forKey: UserDefaultsKeys.CHEF_COVERAGE_AREA) as? Data {
            let decoder = JSONDecoder()
            return try? decoder.decode(ChefAreaCoverage.self, from: savedData)
        }
        return nil
    }
}
struct ChefLocation: Codable {
    var lat: Double
    var long: Double
    var title: String
    
    init(lat: Double, long: Double, title: String) {
        self.lat = lat
        self.long = long
        self.title = title
    }
    
    init?(dict: [String: Any]) {
        guard let latStr = dict["lat"] as? String, let lat = Double(latStr) else { return nil }
        guard let longStr = dict["lon"] as? String, let long = Double(longStr) else { return nil }
        
        self.lat = lat
        self.long = long
        self.title = Location(latitude: lat, longitude: long).title
    }
    
    func saveToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.CHEF_LOCATION)
        }
    }
    
    static func loadFromUserDefaults() -> ChefLocation? {
        if let savedData = UserDefaults.standard.object(forKey: UserDefaultsKeys.CHEF_LOCATION) as? Data {
            let decoder = JSONDecoder()
            return try? decoder.decode(ChefLocation.self, from: savedData)
        }
        return nil
    }
}

extension Location {
    var title: String {
        return String(format: "%.2f", latitude) + ", " + String(format: "%.2f", longitude)
    }
    var dict: [String: Any] {
        return ["lat": "\(latitude)", "long": "\(longitude)"]
    }
    init?(dict: [String: Any]) {
        guard let lat = dict["lat"] as? Double else { return nil }
        guard let long = dict["long"] as? Double else { return nil }
        self = Location(latitude: lat, longitude: long)
    }
}