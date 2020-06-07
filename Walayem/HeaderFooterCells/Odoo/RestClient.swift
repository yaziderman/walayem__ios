//
//  RestClient.swift
//  Walayem
//
//  Created by MAC on 4/18/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation
import Alamofire

class RestClient{
    
    private var headers: HTTPHeaders {
        guard let sessionId = UserDefaults.standard.string(forKey: UserDefaultsKeys.SESSION_ID) else{
            return [:]
        }
        return [
            "Accept": "application/json",
            "Cookie": "session_id=\(sessionId)"
        ]
    }
    
    func request(_ url: String, _ params: [String: Any], _ completionHandler: @escaping(_ result: [String: Any]?, _ error: NSError?) -> Void){
        print("API-- \(url) \nparams: \(params)")
        let jsonParam : [String: Any] = ["jsonrpc": "2.0",
                                         "id": Int(Date().timeIntervalSince1970),
                                         "params": params]
        
        Alamofire.request(url, method: .post, parameters: jsonParam, encoding: JSONEncoding.default, headers: headers)
        .validate()
        .responseJSON { (response) in
            if response.result.isSuccess{
                let value: [String: Any] = response.result.value as! [String: Any]
                if let error = value["error"] as? [String: Any]{
                    completionHandler(nil, NSError(domain: "", code: error["code"] as! Int, userInfo: [NSLocalizedDescriptionKey: error["message"] as! String]))
                }else{
                    completionHandler(value, nil)
                }
            }else{
                completionHandler(["error": "Something wrong in backend...!"], response.result.error as NSError?)
            }
        }
    }
    
    
    func requestPromotedApi(_ url: String, _ params: [String: Any], _ completionHandler: @escaping(_ result: [String: Any]?, _ error: NSError?) -> Void){
        print("API-- \(url) \nparams: \(params)")
        
        let header = ["Content-Type":"application/json"]
        let parameter = [String:AnyObject]()
        
            Alamofire.request(url, method: .post, parameters: parameter , encoding: JSONEncoding.default, headers: header).validate()
            .responseJSON { (response) in
                
                if response.result.isSuccess{
                    let value: [String: Any] = response.result.value as? [String: Any] ?? ["error": "Something went wrong...!"]
                    if let error = value["error"] as? [String: Any]{
                        completionHandler(nil, NSError(domain: "", code: error["code"] as! Int, userInfo: [NSLocalizedDescriptionKey: error["message"] as! String]))
                    }else{
                        completionHandler(value, nil)
                    }
                }else{
                    completionHandler( ["Sorry": "No Internet Connection...!"], response.result.error as NSError?)
            }
        }
            
    }
        
    
}
