//
//  RemoteConfigFetcher.swift
//  Walayem
//
//  Created by ITRS-348 on 09/07/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig

protocol RemoteConfigProtocol: class {
    func fetched(data: RemoteConfigModel)
}

class RemoteConfigFetcher {
    
    var configDelegate: RemoteConfigProtocol?
    
    init(_ configDelegate: RemoteConfigProtocol) {
        self.configDelegate = configDelegate
        RemoteConfig.remoteConfig().setDefaults(RemoteConfigModel().asDictionary())
        fetchCloudValues()
    }
    
    func fetchCloudValues() {
        // WARNING: Don't actually do this in production!
        let fetchDuration: TimeInterval = 0
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) {
            [weak self] (status, error) in
            
            if status == .success {
                RemoteConfig.remoteConfig().activate(completionHandler: { (error) in
                    var configValue = RemoteConfigModel()
                    //                    if let error = error {
                    //                        DLog(message: error)
                    //                    } else {
                    configValue = RemoteConfigModel(ios_min_beta_version: RemoteConfig.remoteConfig()["ios_min_beta_version"].stringValue ?? "", ios_min_prod_version: RemoteConfig.remoteConfig()["ios_min_prod_version"].stringValue ?? "", ios_prod_force_update_required: RemoteConfig.remoteConfig()["ios_prod_force_update_required"].boolValue , ios_beta_force_update_required: RemoteConfig.remoteConfig()["ios_beta_force_update_required"].boolValue , ios_store_url: RemoteConfig.remoteConfig()["ios_store_url"].stringValue ?? "")
                    //                    }
                    self?.configDelegate?.fetched(data: configValue)
                })
                
            } else {
                print ("Uh-oh. Got an error fetching remote values \(error?.localizedDescription ?? "")")
                return
            }
            print ("Retrieved values from the cloud!")
        }
    }
}
