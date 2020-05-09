//
//  OdooClient.swift
//  Walayem
//
//  Created by MAC on 4/17/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation
import Alamofire

class OdooClient{
    
    // Odoo Error Messages
    static let SESSION_EXPIRED: String = "Odoo Session Expired"
    
    private static var odooClient : OdooClient?
    private let headers: HTTPHeaders
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> OdooClient {
        guard let client = odooClient else {
            odooClient = OdooClient()
            return odooClient!
        }
        return client
    }
    
    class func destroy(){
        odooClient = nil
    }
    
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
    
    func authenticate(email: String, password: String, database: String, completionHandler: @escaping(_ result: [String : Any]?, _ error: NSError?) -> Void){
        let url = "\(WalayemApi.BASE_URL)/web/session/authenticate/"
        
        let params : [String : Any] = [
            "login": email,
            "password": password,
            "db": database
        ]
        call(url: url, params: params) { (result, error) in
            if error == nil{
                let result : [String : Any] = result!["result"] as! [String : Any]
                completionHandler(result, error)
            }else{
                completionHandler(result, error)
            }
        }
    }
    
    /**
     * Change current user password. Old password must be provided explicitly
     * to prevent hijacking an existing user session, or for cases where the cleartext
     * password is not used to authenticate requests.
     *
     * @param oldPassword old password
     * @param newPassword new password to set
     * @param callback    result response callback
     */
    func change_password(oldPassword: String, newPassword: String, completionHandler: @escaping(_ result: [String : Any]?, _ error: NSError?) -> Void) {
        let url = "\(WalayemApi.BASE_URL)/web/session/change_password"
        
        let fields = [["name" : "old_pwd", "value" : oldPassword],
                      ["name" : "new_password", "value" : newPassword],
                      ["name" : "confirm_pwd", "value" : newPassword]]
        let params = ["fields" : fields]
        
        call(url: url, params: params) { (result, error) in
            completionHandler(result, error)
        }
    }
    
    func logout(completionHandler: @escaping(_ result: [String : Any]?, _ error: NSError?) -> Void){
        let url = "\(WalayemApi.BASE_URL)/web/session/destroy"
        
        call(url: url, params: [:]) { (result, error) in
            completionHandler(result, error)
        }
    }
    
    func read(model: String, ids: [Int], fields: [String], completionHandler: @escaping(_ result: [String : Any]?, _ error: NSError?) -> Void){
        
        let arguments: [Any] = [ids, fields]
        call_kw(model: model, method: "read", arguments: arguments){ (result, error) in
            completionHandler(result, error)
        }
        
    }
    
    func searchRead(model: String, domain: [Any], fields: [String], offset: Int, limit: Int, order: String, completionHandler: @escaping(_ result: [String : Any]?, _ error: NSError?) -> Void){
        
        let url = "\(WalayemApi.BASE_URL)/web/dataset/search_read"
        
        let params: [String : Any] = [
            "model" : model,
            "fields" : fields,
            "domain" : domain,
            "offset" : offset,
            "limit" : limit,
            "sort" : order
        ]
        
        call(url: url, params: params) { (result, error) in
            if error == nil{
                let result : [String : Any] = result!["result"] as! [String : Any]
                completionHandler(result, error)
            }else{
                completionHandler(result, error)
            }
        }
    }
    
    /**
     * Writes/Update record on server for given ids and values
     *
     * @param model    model required on which to update record
     * @param ids      list of ids on which updating record
     * @param values   new values to update on record
     * @param callback result callback response
     */
    func write(model: String, ids: [Int], values: [String : Any], completionHandler: @escaping(_ result: [String : Any]?, _ error: NSError?) -> Void){
        let arguments : [Any] = [ids, values]
        call_kw(model: model, method: "write", arguments: arguments) { (result, error) in
            completionHandler(result, error)
        }
    }
    
    /**
     * Create record on the server with given values on model
     *
     * @param model    required model name to which record need to create
     * @param values   values data for model
     * @param callback result callback response
     */
    func create(model: String, values: [String : Any], completionHandler: @escaping(_ result: [String : Any]?, _ error: NSError?) -> Void){
        let arguments : [Any] = [values]
        
        call_kw(model: model, method: "create", arguments: arguments) { (result, error) in
            completionHandler(result, error)
        }
    }
    
    func call_kw(model: String, method: String, arguments: [Any], completionHandler: @escaping(_ result: [String : Any]?, _ error: NSError?) -> Void){
        let url = "\(WalayemApi.BASE_URL)/web/dataset/call_kw/\(model)/\(method)"
        
        let params: [String : Any] = [
            "model": model,
            "method": method,
            "args": arguments,
            "kwargs": [:]
        ]
        
        call(url: url, params: params) { (result, error) in
            completionHandler(result, error)
        }
    }
    
    func call(url: String, params: [String : Any], completionHandler: @escaping(_ result: [String : Any]?, _ error: NSError?) -> Void){
        let jsonParam : [String : Any] = [
            "jsonrpc": "2.0",
            "id": Int(Date().timeIntervalSince1970),
            "params": params
        ]
        
        Alamofire.request(url, method: .post, parameters: jsonParam, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { (response) in
                if response.result.isSuccess{
                    let value : [String : Any] = response.result.value as! [String : Any]
                    if value["error"] != nil{
                        let error = value["error"] as! [String : Any]
                        completionHandler(nil, NSError(domain:"", code: error["code"] as! Int, userInfo: [NSLocalizedDescriptionKey: error["message"] as! String]))
                    }else{
                        completionHandler(value, nil)
                    }
                }else{
                    completionHandler(nil, response.result.error as NSError?)
                }
        }
        
    }
    
}

