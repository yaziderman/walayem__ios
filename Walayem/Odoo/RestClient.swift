//
//  RestClient.swift
//  Walayem
//
//  Created by MAC on 4/18/18.
//  Copyright © 2018 Inception Innovation. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

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
	
	
	func request(_ url: String, _ params: [String: Any], _ vc: UIViewController?, _ completionHandler: @escaping(_ result: [String: Any]?, _ error: NSError?) -> Void){
		
		let jsonParam : [String: Any] = ["jsonrpc": "2.0",
										 "id": Int(Date().timeIntervalSince1970),
										 "params": params]
		if NetworkReachabilityManager()!.isReachable {
			Alamofire.request(url, method: .post, parameters: jsonParam, encoding: JSONEncoding.default, headers: headers)
				.validate(
			)
				.responseJSON { (response) in
					if response.result.isSuccess{
						let value: [String: Any] = response.result.value as! [String: Any]
						if let error = value["error"] as? [String: Any]{
							completionHandler(nil, NSError(domain: "", code: error["code"] as! Int, userInfo: [NSLocalizedDescriptionKey: error["message"] as! String]))
						}else{
							completionHandler(value, nil)
						}
					}else{
						print(response.result.error as NSError?)
						completionHandler(["error": "Something wrong in backend...!"], response.result.error as NSError?)
					}
			}
		} else {
			showSorryAlertWithMessage("No internet connection...!", vc: vc)
		}
	}
	
	
	func requestPromotedApi(_ url: String, _ params: [String: Any], _ vc: UIViewController?, _ completionHandler: @escaping(_ result: [String: Any]?, _ error: NSError?) -> Void){
		
		headers = [
			"Content-Type":"application/json"
		]
		
		var parameters = [String: Any]()
		parameters["params"] = params
		parameters["jsonrpc"] = "2.0"
		parameters["id"] = "0"
		
		if NetworkReachabilityManager()!.isReachable {
			
			Alamofire.request(url, method: .post, parameters: parameters , encoding: JSONEncoding.default, headers: headers).validate()
				.responseJSON { (response) in
					
					if response.result.isSuccess{
						let value: [String: Any] = response.result.value as? [String: Any] ?? ["error": "Something went wrong...!"]
						if let error = value["error"] as? [String: Any]{
							completionHandler(nil, NSError(domain: "", code: error["code"] as! Int, userInfo: [NSLocalizedDescriptionKey: error["message"] as! String]))
						}else{
							completionHandler(value, nil)
						}
					}else{
						completionHandler( ["Sorry": "Something went wrong...!"], response.result.error as NSError?)
					}
			}
		} else {
			showSorryAlertWithMessage("No internet connection...!", vc: vc)
		}
		
	}
	
	private func showSorryAlertWithMessage(_ msg: String, vc: UIViewController?){
		let alert = UIAlertController(title: "Sorry", message: msg, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
		vc?.present(alert, animated: true, completion: nil)
	}
	
}
