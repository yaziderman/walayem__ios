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
    
    
    func requestNewApi(_ url: String, _ params: [String: Any], _ completionHandler: @escaping(_ result: [String: Any]?, _ error: NSError?) -> Void){

        
        let parameters = "{}"
        let postData = parameters.data(using: .utf8)
        
        var request = URLRequest(url: URL(string:WalayemApi.homeRecommendation)!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard data != nil else {
            print(String(describing: error))
            return
          }
            print(response as Any)
        }

        task.resume()
        
//
//        let mUrl = URL(string: "http://app.walayem.com/walayem/image/product.template/674/image")
//        URLSession.shared.dataTask(with: mUrl!){data,response,error in
//            let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
//            print(json)
//        }().resume()
        
        
//        let msession = URLSession.shared
//        let mtask = URLSession.dataTask(with: request, completionHandler: { data, response, error -> Void in
//
//            let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
//            print(json)
//
//        })
//        mtask.resume()
        
        
        let headers = ["Content-Type": "application/json"]
               let params : [String: Any] = ["body": "{}"]
               
       let url = "http://18.139.224.233/api/promoted"
       Alamofire.request(url, method: .get, parameters: params, encoding: JSONEncoding.default,  headers: headers).responseJSON { (response) in
             switch response.result {
             case .success:
                 print("SUKCES with \(response)")
                 print((String.init(data: response.data!, encoding: .utf8))!)
             case .failure(let error):
                 print("ERROR with '\(error)")
             }
         }
        
        
//        let jsonParam : [String: Any] = ["jsonrpc": "2.0",
//                                            "id": Int(Date().timeIntervalSince1970),
//                                            "params": params]
//        guard let sessionId = UserDefaults.standard.string(forKey: "sessionId") else{
//            headers = [:]
//            return
//        }
        
//        var request = URLRequest(url: URL(string: WalayemApi.recommendation)!)
//        request.httpMethod = "POST"
//        request.httpBody = try? JSONSerialization.data(withJSONObject: jsonParam , options: [])
//        request.addValue("session_id=\(sessionId)", forHTTPHeaderField: "Cookie")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//
//
//        let session = URLSession.shared
//        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
//            print(response!)
//            do {
//                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
//                print(json)
//            } catch {
//                print("error")
//            }
//        })
//
//        task.resume()
        
        
        
//        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue(), completionHandler:{ (response:URLResponse!, data: NSData!, error: NSError!) -> Void in
//            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
//            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
//
//            if (jsonResult != nil) {
//                // process jsonResult
//            } else {
//               // couldn't load JSON, look at error
//            }
//
//
//        })
        
        
        
//        var headers: HTTPHeaders = ["Content-Type": "application/json"]
//             let url = "http://18.139.224.233/api/promoted"
//             Alamofire.request(url, method: .get, parameters: "{\n\t\n}", encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
//
//                   switch response.result {
//                   case .success:
//                       print("SUKCES with \(response)")
//                   case .failure(let error):
//                       print("ERROR with '\(error)")
//                   }
//            }
//        let semaphore = DispatchSemaphore (value: 0)
//
//        let parameters = "{\n\t\n}"
//        let postData = parameters.data(using: .utf8)
//
//        var request = URLRequest(url: URL(string: "http://18.139.224.233/api/promoted/recommend")!,timeoutInterval: Double.infinity)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        request.httpMethod = "GET"
//        request.httpBody = postData
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//          guard let data = data else {
//            print(String(describing: error))
//            return
//          }
//          print(String(data: data, encoding: .utf8)!)
//          semaphore.signal()
//        }
//
//        task.resume()
//        semaphore.wait()

        
       
        
        
        
//        headers = ["Content-Type": "application/json"]
//        let parameters = "{\n\t\n}"
//        let postData = parameters.data(using: .utf8)
//
//        Alamofire.request(WalayemApi.homeRecommendation, headers: headers).responseJSON { response in
//            print(response.request)   // original url request
//            print(response.response) // http url response
//            print(response.result)  // response serialization result
//            if let json = response.result.value {
//                print("JSON: \(json)") // serialized json response
//            }
//        }
        
        
        
    }
    
    
        
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
       
    
    
    func requestHomeApis(_ url: String, _ params: [String: Any], _ completionHandler: @escaping(_ result: [String: Any]?, _ error: NSError?) -> Void){

        let jsonParam : [String: Any] = ["":""]

         headers = ["Content-Type": "application/json"]

        Alamofire.request(url, method: .get, parameters: jsonParam, encoding: JSONEncoding.default, headers: headers)
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
}
