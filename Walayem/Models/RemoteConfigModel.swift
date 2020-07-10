//
//  RemoteConfigModel.swift
//  Walayem
//
//  Created by ITRS-348 on 09/07/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import Foundation

struct RemoteConfigModel: Codable {
    
    var ios_min_beta_version = "4.2.2"
    var ios_min_prod_version = "4.2.2"
    var ios_prod_force_update_required = false
    var ios_beta_force_update_required = false
    var ios_store_url = "itms-apps://apps.apple.com/us/app/id1385676754"
}
