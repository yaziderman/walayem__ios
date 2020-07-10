//
//  AppleLoginWrapper.swift
//  Walayem
//
//  Created by ITRS-348 on 08/07/20.
//  Copyright © 2020 Inception Innovation. All rights reserved.
//

import Foundation
import AuthenticationServices

@available(iOS 13, *)
class AppleLoginWrapper: NSObject {
    
    static var shared: AppleLoginWrapper?
    
    static func setLoginWrapper() {
        if AppleLoginWrapper.shared == nil {
            shared = AppleLoginWrapper()
        }
    }
    
    var viewController: UIViewController?
    var isCheckRequest = false
    
    private override init() {}
    
    func setUpWrapper(viewController: UIViewController) {
        self.viewController = viewController
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        
        appleIDProvider.getCredentialState(forUserID: KeyChainWrapper.shared?.getValue(key: KeychainKeys.USER_KEY) ?? "") { [weak self] (credentialState, error) in
            switch credentialState {
            case .authorized:
                // The Apple ID credential is valid.
                self?.isCheckRequest = true
                self?.authorizationRequest()
                break
            case .revoked, .notFound:
                self?.authorizationRequest()
                break
            default:
                break
            }
        }
    }
    
    func authorizationRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
//    func authorizationCheckRequest() {
//        isCheckRequest = true
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        var requestArray = [ASAuthorizationRequest]()
//        request.requestedScopes = [.fullName, .email]
//        requestArray.append(request)
//        let passwordRequest = ASAuthorizationPasswordProvider().createRequest()
//        requestArray.append(passwordRequest)
//
//        let authorizationController = ASAuthorizationController(authorizationRequests: requestArray)
//        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
//        authorizationController.performRequests()
//    }
    
}

@available(iOS 13.0, *)
extension AppleLoginWrapper: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Get user data with Apple ID credentitial
            
            let userId = appleIDCredential.user
            let userFirstName = appleIDCredential.fullName?.givenName
            let userLastName = appleIDCredential.fullName?.familyName
            let userEmail = appleIDCredential.email
            
            print("User ID: \(userId)")
            print("User First Name: \(userFirstName ?? "")")
            print("User Last Name: \(userLastName ?? "")")
            print("User Email: \(userEmail ?? "")")
            
            if isCheckRequest {
                //            let applePassword = passwordCredential.password
                do {
                    let jsonText = KeyChainWrapper.shared?.getValue(key: userId) ?? ""
                    let data = jsonText.data(using: .utf8)!
                    let userObject = try JSONDecoder().decode(UserKeychainObject.self, from: data)
                    
                    let alert = UIAlertController.init(title: "Login Data Retrieved", message: jsonText, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    viewController?.present(alert, animated: true, completion: nil)
                    
                } catch {
                    print(error.localizedDescription)
                }
                
            } else {
                let userKeychainObject: [String: String] = UserKeychainObject(email: userEmail ?? "", firstName: userFirstName ?? "", lastName: userLastName ?? "").asDictionary()
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: userKeychainObject, options: .prettyPrinted)
                    let theJSONText = String(data: jsonData, encoding: .utf8) ?? ""
                    KeyChainWrapper.shared?.setKeychainValue(key: userId, value: theJSONText)
                    
                    let alert = UIAlertController.init(title: "Login Data Initial", message: theJSONText, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    viewController?.present(alert, animated: true, completion: nil)
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
            // Write your code here
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if isCheckRequest {
            isCheckRequest = false
            authorizationRequest()
        }
        
        DLog(message: error.localizedDescription)
    }
    
}

@available(iOS 13.0, *)
extension AppleLoginWrapper: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return (viewController?.view.window!)!
    }
}

