//
//  User.swift
//  Walayem
//
//  Created by MAC on 4/18/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation

struct UserDefaultsKeys{
    static let NAME: String = "name"
    static let EMAIL: String = "email"
    static let PHONE: String = "phone"
    static let IMAGE: String = "image"
    static let SESSION_ID: String = "sessionId"
    static let PARTNER_ID: String = "partnerId"
    static let IS_CHEF: String = "isChef"
    static let ORDER_FIRST_TIME: String = "orderFirstTime"
    static let IS_CHEF_VERIFIED: String = "isChefVerified"
    static let FIREBASE_VERIFICATION_ID = "firebaseVerificationID"
    static let FOOD_QUANTITY = "foodQuantity"
    static let USER_AREA_FILTER = "user_area_filter"
    static let USER_AREA_TITLE = "user_area_title"
    static let REGULAR_RUN = "regularRun"
    static let AUTH_TOKEN = "authToken"
    static let CHEF_COVERAGE_AREA = "ChefCoverageArea"
    static let CHEF_LOCATION = "ChefLocation"
	static let CHEF_DESCRIPTION: String = "chefDescription"
}

class User{
    var name: String?
    var email: String?
    var phone: String?
    var session_id: String?
    var partner_id: Int?
    var image: String?
	var chefDescription: String?
    var isChef: Bool = false
    var isChefVerified: Bool = false
    var firebaseToken: String?
    
    init(){}
    
    init(record : [String : Any]){
        self.name = record["name"] as? String
        self.email = record["email"] as? String
        self.phone = record["phone"] as? String ?? ""
        self.isChef = record["is_chef"] as! Bool
        self.isChefVerified = record["is_chef_verified"] as! Bool
        self.image = record["image"] as? String ?? ""
		self.chefDescription = record["chef_description"] as? String ?? ""
    }
    
    func getUserDefaults() -> User{
        let userDefaults = UserDefaults.standard
        
        self.name = userDefaults.string(forKey: UserDefaultsKeys.NAME)
        self.email = userDefaults.string(forKey: UserDefaultsKeys.EMAIL)
        self.phone = userDefaults.string(forKey: UserDefaultsKeys.PHONE)
        self.session_id = userDefaults.string(forKey: UserDefaultsKeys.SESSION_ID)
        self.partner_id = userDefaults.integer(forKey: UserDefaultsKeys.PARTNER_ID)
        self.image = userDefaults.string(forKey: UserDefaultsKeys.IMAGE)
        self.isChef = userDefaults.bool(forKey: UserDefaultsKeys.IS_CHEF)
        self.isChefVerified = userDefaults.bool(forKey: UserDefaultsKeys.IS_CHEF_VERIFIED)
		self.chefDescription = userDefaults.string(forKey: UserDefaultsKeys.CHEF_DESCRIPTION)

        return self
    }
    
    func clearUserDefaults(){
        let userDefaults = UserDefaults.standard
        
        userDefaults.removeObject(forKey: UserDefaultsKeys.NAME)
        userDefaults.removeObject(forKey: UserDefaultsKeys.EMAIL)
        userDefaults.removeObject(forKey: UserDefaultsKeys.PHONE)
        userDefaults.removeObject(forKey: UserDefaultsKeys.SESSION_ID)
        userDefaults.removeObject(forKey: UserDefaultsKeys.PARTNER_ID)
        userDefaults.removeObject(forKey: UserDefaultsKeys.IMAGE)
        userDefaults.removeObject(forKey: UserDefaultsKeys.IS_CHEF)
        userDefaults.removeObject(forKey: UserDefaultsKeys.IS_CHEF_VERIFIED)
        userDefaults.removeObject(forKey: UserDefaultsKeys.AUTH_TOKEN)
        userDefaults.removeObject(forKey: UserDefaultsKeys.USER_AREA_FILTER)
        userDefaults.removeObject(forKey: UserDefaultsKeys.USER_AREA_TITLE)
        userDefaults.removeObject(forKey: UserDefaultsKeys.CHEF_COVERAGE_AREA)
        userDefaults.removeObject(forKey: UserDefaultsKeys.CHEF_LOCATION)
		userDefaults.removeObject(forKey: UserDefaultsKeys.CHEF_DESCRIPTION)
        userDefaults.removeObject(forKey: "authToken")
        userDefaults.synchronize()
    }
    
}
