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
    
    private var headers: HTTPHeaders
    
    // MARK: Initialization
    init(){
        guard let sessionId = UserDefaults.standard.string(forKey: "sessionId") else{
            headers = [:]
            return
        }
        headers = [
            "Accept": "application/json",
            "Cookie": "session_id=\(sessionId)"
        ]
    }
    
    
    func request(_ url: String, _ params: [String: Any], _ completionHandler: @escaping(_ result: [String: Any]?, _ error: NSError?) -> Void){
        
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
                completionHandler(nil, response.result.error as NSError?)
            }
        }
    }
//
//    func requestNewApi(_ url: String, _ params: [String: Any], _ completionHandler: @escaping(_ result: [String: Any]?, _ error: NSError?) -> Void){
//
//           let jsonParam : [String: Any] = ["jsonrpc": "2.0",
//                                            "id": Int(Date().timeIntervalSince1970),
//                                            "params": params]
//
//        headers = ["Content-Type": "application/json"]
//
//        Alamofire.request(WalayemApi.homeRecommendation, headers: headers).responseJSON { response in
//            print(response.request)   // original url request
//            print(response.response) // http url response
//            print(response.result)  // response serialization result
//            if let json = response.result.value {
//                print("JSON: \(json)") // serialized json response
//            }
//        }
        
//
//           Alamofire.request(url, method: .post, parameters: jsonParam, encoding: JSONEncoding.default, headers: headers)
//           .validate()
//           .responseJSON { (response) in
//               if response.result.isSuccess{
//                   let value: [String: Any] = response.result.value as! [String: Any]
//                   if let error = value["error"] as? [String: Any]{
//                       completionHandler(nil, NSError(domain: "", code: error["code"] as! Int, userInfo: [NSLocalizedDescriptionKey: error["message"] as! String]))
//                   }else{
//                       completionHandler(value, nil)
//                   }
//               }else{
//                   completionHandler(nil, response.result.error as NSError?)
//               }
//           }
//       }
       
    
    
//    func requestHomeApis(_ url: String, _ params: [String: Any], _ completionHandler: @escaping(_ result: [String: Any]?, _ error: NSError?) -> Void){
//
//        let jsonParam : [String: Any] = ["":""]
//
//         headers = ["Content-Type": "application/json"]
//
//        Alamofire.request(url, method: .get, parameters: jsonParam, encoding: JSONEncoding.default, headers: headers)
//        .validate()
//        .responseJSON { (response) in
//            if response.result.isSuccess{
//                let value: [String: Any] = response.result.value as! [String: Any]
//                if let error = value["error"] as? [String: Any]{
//                    completionHandler(nil, NSError(domain: "", code: error["code"] as! Int, userInfo: [NSLocalizedDescriptionKey: error["message"] as! String]))
//                }else{
//                    completionHandler(value, nil)
//                }
//            }else{
//                completionHandler(nil, response.result.error as NSError?)
//            }
//        }
//    }
//
}
