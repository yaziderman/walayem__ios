//
//  WalayemApi.swift
//  Walayem
//
//  Created by MAC on 4/17/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation

class WalayemApi{
    
<<<<<<< HEAD
//    http://app.walayem.com/api/promoted
    
    
    static let BASE_URL: String = "http://18.139.224.233"
//static let BASE_URL: String = "http://app.walayem.com"
=======
//    static let BASE_URL: String = "http://18.139.224.233"
static let BASE_URL: String = "http://app.walayem.com"
>>>>>>> origin/dan
//static let BASE_URL: String = "http://192.168.1.103:8073"
    static let DB_NAME: String = "walayem"
    
    
    // Customer Api
    static let signup: String = "\(BASE_URL)/api/signup"
    static let recommendation: String = "\(BASE_URL)/api/recommended"
    static let homeRecommendation: String = "\(BASE_URL)/api/promoted"
    static let mealsOfDay: String = "\(BASE_URL)/api/recommended"
    static let discoverFood: String = "\(BASE_URL)/api/discover/food"
    static let searchFood: String = "\(BASE_URL)/api/food/search"
    static let discoverChef: String = "\(BASE_URL)/api/discover/chef"
    static let searchChef: String = "\(BASE_URL)/api/chef/search"
    static let rateChef: String = "\(BASE_URL)/api/rate"
    static let address: String = "\(BASE_URL)/api/readAddress"
    static let createAddress: String = "\(BASE_URL)/api/createAddress"
    static let editAddress: String = "\(BASE_URL)/api/editAddress"
    static let deleteAddress: String = "\(BASE_URL)/api/deleteAddress"
    static let checkFav: String = "\(BASE_URL)/api/check/favorite"
    static let addFav: String = "\(BASE_URL)/api/favorite/add"
    static let removeFav: String = "\(BASE_URL)/api/favorite/remove"
    static let favChefs: String = "\(BASE_URL)/api/favorite/chefs"
    static let favFoods: String = "\(BASE_URL)/api/favorite/foods"
    static let orderHistory: String = "\(BASE_URL)/api/user/vieworder"
    static let orderDetail: String = "\(BASE_URL)/api/orderdetail"
    static let placeOrder: String = "\(BASE_URL)/api/order"
    static let viewTerms: String = "\(BASE_URL)/api/viewTerms"
    static let viewPrivacy: String = "\(BASE_URL)/api/viewPrivacy"
    static let orderedFoods: String = "\(BASE_URL)/api/orderedFoods"
    static let getActiveFoodIds: String = "\(BASE_URL)/api/getActiveProductIds"

    // Chef Api
    static let chefOrders: String = "\(BASE_URL)/api/chef/vieworder"
    static let changeOrderState: String = "\(BASE_URL)/api/changeOrderState"
    static let chefFood: String = "\(BASE_URL)/api/readChefProduct"
    static let createFood: String = "\(BASE_URL)/api/product/create"
    static let pauseRemoveFood: String = "\(BASE_URL)/api/pauseremove/food"
    static let chefAccountsHistory: String = "\(BASE_URL)/api/viewAccountHistory"
    static let viewAmountForMonth: String = "\(BASE_URL)/api/viewAmountForMonth"
    static let viewWalletAmount: String = "\(BASE_URL)/api/viewWalletAmount"
    static let viewKitchenStatus: String = "\(BASE_URL)/api/getKitchenStatus"
    static let changeKitchenStatus: String = "\(BASE_URL)/api/changeKitchenStatus"
    
    static let changePassword: String = "\(BASE_URL)/api/reset_password/json"
    static let invite: String = "\(BASE_URL)/api/invite"
    static let chefImage: String = "\(BASE_URL)/api/viewChefImage"
    static let contact: String = "\(BASE_URL)/api/viewContactDetails"
    static let getChefSettings: String = "\(BASE_URL)/api/getChefSettings"
}
